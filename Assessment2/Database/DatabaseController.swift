//
//  DatabaseController.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/24.
//

import Foundation


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var gamesessionRef: CollectionReference?
    var userRef: CollectionReference?
    var gamesessionList: [GameSession]
    var userList: [User]
    var currentUser: User?
    var handle: AuthStateDidChangeListenerHandle?
  
    override init() {
        authController = Auth.auth()
        database = Firestore.firestore()
        gamesessionList = [GameSession]()
        userList = [User]()
        super.init()
      //  authController.signInAnonymously() { (authResult, error) in
       //  guard authResult != nil else {
       //  fatalError("Firebase authentication failed")
       //  }
      //  self.currentUser = self.getUserByID(authController.currentUser?.uid)
        self.setUpUsersListener()
        self.setUpGameSessionListener()
    }
    
    func cleanup() {
        
    }
    
    func addGameSession(game: String, sessionname: String, playersneeded: Int, latitude: Double, longitude: Double, sessiontime: Date, sessionowner: String, gameimage: String) -> GameSession {
            let gamesession = GameSession()
            gamesession.gamename = game
            gamesession.sessionname = sessionname
            gamesession.playersneeded = playersneeded
            gamesession.latitude = latitude
            gamesession.longitude = longitude
            gamesession.sessiontime = sessiontime
            gamesession.sessionowner = sessionowner
            gamesession.gameimage = gameimage
            gamesession.players = [String]()
            do {
                if let gameRef = try gamesessionRef?.addDocument(from: gamesession) {
                    gamesession.sessionid = String(gameRef.documentID)
                    gameRef.setData(["sessionid": gamesession.sessionid ?? "nil"], merge: true)
                }
            } catch {
                print("Failed to serialize hero")
         }

         return gamesession
    }
    
    func addUser(uid: String, name: String, latitude: Double, longitude: Double, DoB: Date, email: String) -> User {
        let user = User()
        user.uid = uid
        user.name = name
        user.latitude = latitude
        user.longitude = longitude
        user.DoB = DoB
        user.email = email
        
        do {
            try userRef?.document(user.uid!).setData(from: user)
        } catch {
            print("Failed to serialize hero")
     }

     return user
    }
    
    func deleteGameSession(gamesession: GameSession) {
        if let gameId = gamesession.sessionid {
            gamesessionRef?.document(gameId).delete()
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.users ||
         listener.listenerType == ListenerType.all {
         listener.onUserChange(change: .update, users: userList)
         }
        if listener.listenerType == ListenerType.games ||
         listener.listenerType == ListenerType.all {
         listener.onGameListChange(change: .update, games: gamesessionList)
         }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK:- Setup code for Firestore listeners
    
    func setUpUsersListener() {
        userRef =  database.collection("users")
        userRef?.addSnapshotListener {(querySnapshot, error) in
         guard let querySnapshot = querySnapshot else {
         print("Error fetching documents: \(error!)")
         return
         }
         self.parseUsersSnapshot(snapshot: querySnapshot)
         }
      //  self.setUpGameSessionListener()
    }
    
    func setUpGameSessionListener() {
        gamesessionRef = database.collection("games")

        gamesessionRef?.addSnapshotListener {(querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseGamesSessionsSnapshot(snapshot: querySnapshot)
        }
     }
    
    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseUsersSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let userID = change.document.documentID
            //print(userID)

            let parsedUser = User()
            //timestamp conversion not working
            let sessiontimestamp = change.document.data()["DoB"] as? Timestamp
            parsedUser.DoB = sessiontimestamp!.dateValue()
            parsedUser.latitude = change.document.data()["latitude"] as? Double
            parsedUser.longitude = change.document.data()["longitude"] as? Double
            parsedUser.name = change.document.data()["name"] as? String
            parsedUser.uid = change.document.data()["uid"] as? String
            parsedUser.email = change.document.data()["email"] as? String
    
            if change.type == .added {
                userList.append(parsedUser)
            }
            else if change.type == .modified {
                let index = getUserIndexByID(userID)!
                userList[index] = parsedUser
            }
            else if change.type == .removed {
                if let index = getUserIndexByID(userID) {
                    userList.remove(at: index)
                }
            }
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.users ||
                    listener.listenerType == ListenerType.all {
                    listener.onUserChange(change: .update, users: userList)
                }
            }
    }
    
    func parseGamesSessionsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
        let gameId = change.document.documentID
        
        var gameSession = GameSession()
        
       /* do {
            gameSession = try change.document.data(as: GameSession.self)
         } catch {
         print("Unable to decode gamesession. Is the gamesession malformed?")
         return
         } */
      //      do {
            gameSession.gamename =  change.document.data()["gamename"] as? String
            gameSession.sessionname = change.document.data()["sessionname"] as? String
            gameSession.sessionowner = change.document.data()["sessionowner"] as? String
            //timestamp conversion not working
            let sessiontimestamp = change.document.data()["sessiontime"] as? Timestamp
            gameSession.sessiontime = sessiontimestamp?.dateValue()
            gameSession.gameimage =  change.document.data()["gameimage"] as? String
            gameSession.longitude = change.document.data()["longitude"] as? Double
            gameSession.latitude = change.document.data()["latitude"] as? Double
            gameSession.playersneeded = change.document.data()["playersneeded"] as? Int
            gameSession.sessionid = change.document.documentID as? String
                
         //   } catch {
          //      print("Unable to decode gamesession. Is the gamesession malformed?")
              //  return
            //}
//            if let playersReferences = change.document.data()["players"] as? [DocumentReference] {
//                for reference in playersReferences {
//                    print("references")
//                    print(reference)
//                    //if let user = getUserByID(reference.documentID) {
//                    gameSession.players?.append(reference)
//                    //}
//                }
//        }
            if gameSession.players == nil{
                gameSession.players = [String]()
            }
                if let players = change.document.data()["players"] as? [String]{
                    for player in players{
                        gameSession.players?.append(player)
                    }
                }
            

       //  guard let game = gameSession else {
        // print("Document doesn't exist")
        // return;
        // }
       // game.sessionid = gameId
        
        if change.type == .added {
            gamesessionList.append(gameSession)
         }
         else if change.type == .modified {
            guard let index = getGameIndexByID(gameId) else{
                return
            }
            gamesessionList[index] = gameSession
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
    }
    
    
    //Utility functions
    func getGameIndexByID(_ id: String) -> Int? {
        if let game = getGameByID(id) {
         return gamesessionList.firstIndex(of: game)
         }
         return nil
        
    }
    
    func getGameByID(_ id: String) -> GameSession? {
        for game in gamesessionList {
            if game.sessionid == id {
                return game
            }
        }
        return nil
     }
    
    func getUserIndexByID(_ id: String) -> Int? {
        if let user = getUserByID(id) {
         return userList.firstIndex(of: user)
         }

         return nil
        
    }
    
    func getUserByID(_ id: String) -> User? {
        for user in userList {
            if user.uid == id {
                return user
            }
        }
        return nil
     }
    
    
    func addUserToGameSession(user: User, gameSession: GameSession) -> Bool {

    let numberofplayers = gameSession.players?.count ?? 0
     guard let userID = user.uid, let gameID = gameSession.sessionid,
      numberofplayers < gameSession.playersneeded! else {
     return false
     }
    if gameSession.players != nil {
        for player in gameSession.players! {
                if player == userID {
                    return false
                }
            }
    }

     
    gamesessionRef?.document(gameID).updateData(
        ["players" : FieldValue.arrayUnion([userID]), "playersneeded": (gameSession.playersneeded! - 1)]
     )
     return true
     }
    
    func removeUserFromGameSession(user: User, gameSession: GameSession) {
        if ((gameSession.players?.contains(user.uid!)) != nil), let gameID = gameSession.sessionid, let userID = user.uid {
        gamesessionRef?.document(gameID).updateData(
     ["players": FieldValue.arrayRemove([userID])]
     )
     }
     }
}

