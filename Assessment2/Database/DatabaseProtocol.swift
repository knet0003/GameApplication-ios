//
//  DatabaseProtocol.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

enum DatabaseChange {
 case add
 case remove
 case update
}
enum ListenerType {
 case games
 case users
 case all
}
protocol DatabaseListener: AnyObject {
 var listenerType: ListenerType {get set}
// func onUserChange(change: DatabaseChange, teamHeroes: [SuperHero])
 func onGameListChange(change: DatabaseChange, games: [GameSession])
}
protocol DatabaseProtocol: AnyObject {
 func cleanup()
    func addGameSession(game: String, sessionname: String, playersneeded: Int, location: CLLocationCoordinates, sessiontime: Date) -> GameSession
// func addUser(userName: String) -> User
// func addUserToGame(user: User, gameSession: GameSession) -> Bool
 func deleteGameSession(gamesession: GameSession)
// func removeUserFromGame(user: User, gameSession: GameSession)
 func addListener(listener: DatabaseListener)
 func removeListener(listener: DatabaseListener)
}
