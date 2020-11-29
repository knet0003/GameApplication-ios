//
//  DatabaseProtocol.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//
import CoreLocation

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
    func onUserChange(change: DatabaseChange, users: [User])
    func onGameListChange(change: DatabaseChange, games: [GameSession])
}
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addGameSession(game: String, sessionname: String, playersneeded: Int, latitude: Double, longitude: Double, sessiontime: Date, sessionowner: String, gameimage: String) -> GameSession
    func addUser(uid: String, name: String, latitude: Double, longitude: Double, DoB: Date, email: String) -> User
     func addUserToGameSession(user: User, gameSession: GameSession) -> Bool
    func deleteGameSession(gamesession: GameSession)
     func removeUserFromGameSession(user: User, gameSession: GameSession)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
