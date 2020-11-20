//
//  FirebaseController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
     var authController: Auth
     var database: Firestore
    var gamesessionRef: CollectionReference?
    var gamesessionList: [GameSession]
    
    
    override init() {
     // To use Firebase in our application we first must run the
     // FirebaseApp configure method
   //  FirebaseApp.configure()
     // We call auth and firestore to get access to these frameworks
     authController = Auth.auth()
     database = Firestore.firestore()
    gamesessionList = [GameSession]()

     super.init()
        authController.signInAnonymously() { (authResult, error) in
         guard authResult != nil else {
         fatalError("Firebase authentication failed")
         }
         // Once we have authenticated we can attach our listeners to
         // the firebase firestore
         self.setUpGameSessionListener()
    }
    }
    
    
    
    func addGameSession(game: String, sessionname: String, playersneeded: Int, latitude: String, longitude: String, sessiontime: Date) -> GameSession {
        let gamesession = GameSession()
        gamesession.gamename = game
        gamesession.sessionname = sessionname
        gamesession.playersneeded = playersneeded
        gamesession.latitude = latitude
        gamesession.longitude = longitude
        gamesession.sessiontime = sessiontime
        do {
         if let gameRef = try gamesessionRef?.addDocument(from: gamesession) {
         gamesession.id = gameRef.documentID
         }
         } catch {
         print("Failed to serialize hero")
         }

         return gamesession
    }
    
    func cleanup() {
        
    }
    
    func deleteGameSession(gamesession: GameSession) {
        if let gameId = gamesession.id {
            gamesessionRef?.document(gameId).delete()
        }
        
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)

        if listener.listenerType == ListenerType.games ||
         listener.listenerType == ListenerType.all {
         listener.onGameListChange(change: .update, games: gamesessionList)
         }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK:- Setup code for Firestore listeners
    func setUpGameSessionListener() {
        gamesessionRef = database.collection("games")
        gamesessionRef?.addSnapshotListener { (querySnapshot, error) in
     guard let querySnapshot = querySnapshot else {
     print("Error fetching documents: \(error!)")
     return
     }
     self.parseGamesSessionsSnapshot(snapshot: querySnapshot)

     // Team listener references users, so we need to do it after we have parsed users.
    // self.setUpTeamListener()
     }
     }
    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseGamesSessionsSnapshot(snapshot: QuerySnapshot) {
    snapshot.documentChanges.forEach { (change) in
        let gameId = change.document.documentID
        
        var gameSession: GameSession?
        
        do {
            gameSession = try change.document.data(as: GameSession.self)
         } catch {
         print("Unable to decode hero. Is the hero malformed?")
         return
         }

         guard let game = gameSession else {
         print("Document doesn't exist")
         return;
         }
        
        game.id = gameId
        
        if change.type == .added {
            gamesessionList.append(game)
         }
         else if change.type == .modified {
         let index = getGameIndexByID(gameId)!
            gamesessionList[index] = game
         }
         else if change.type == .removed {
         if let index = getGameIndexByID(gameId) {
            gamesessionList.remove(at: index)
         }
         }
        
    }
        listeners.invoke{(listener) in
            if listener.listenerType == ListenerType.games ||
                                                        listener.listenerType == ListenerType.all {
                                                        listener.onGameListChange(change: .update, games: gamesessionList)
        }
    }
    
    //Utility functions
    func getGameIndexByID(_ id: String) -> Int? {
        if let gameSession = getGameSessionByID(id) {
         return gamesessionList.firstIndex(of: gameSession)
         }

         return nil
        
    }
    
    func getGameSessionByID(_ id: String) -> GameSession? {
     for game in gamesessionList {
     if game.id == id {
     return game
     }
     }
     return nil
     }
    
    
        
        
}
}
