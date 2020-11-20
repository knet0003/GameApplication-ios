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
    func cleanup() {
        <#code#>
    }
    
    func deleteGameSession(gamesession: GameSession) {
        <#code#>
    }
    
    func addListener(listener: DatabaseListener) {
        <#code#>
    }
    
    func removeListener(listener: DatabaseListener) {
        <#code#>
    }
    
    var listeners = MulticastDelegate<DatabaseListener>()
     var authController: Auth
     var database: Firestore
    var gamesessionRef: CollectionReference?
    
    override init() {
     // To use Firebase in our application we first must run the
     // FirebaseApp configure method
     FirebaseApp.configure()
     // We call auth and firestore to get access to these frameworks
     authController = Auth.auth()
     database = Firestore.firestore()

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
    

}
