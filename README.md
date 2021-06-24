
#Application Concept 
In many instances board/video games are not being used because there are not enough players to play them in a household or that during the restrictions of the pandemic people have suffered from being confined in their homes and cannot meet their family and friends who live far away, therefore we wanted to allow people to be able to meet others and socialise at home using board/video games. Games can make people get used to each other easily and form bonds effectively.

The proposed application is a web service application that provides a platform for users with similar interests to interact with each other and allow users to host game sessions at their homes. The concept behind this application was to encourage people to meet new people that are also interested in playing specific board or video games. 

The main goal of the application is to appeal to people of all ages that like board games and video games, however, the main target audience would generally be of the younger generation from the age of 18 to 35. The minimum age to be registered on the application is 18. If a person under 18 is interested in joining a game session a guardian must be the one registering and be present during the game.
Key functionalities:
- Log in/Sign up: users can sign up with either their email address
- Manage account information: Location, favourite games, board/video games owned
-	Create/remove game session: Users are free to create their own game. To create a new game, they are required to input the time and location of the hosted event, as well as the number of players they require for the event.
-	Search for close-by board game/video gaming sessions: users who would like to join a game session can 
-	Can see other games around in MapView(filter by the game)
-	Request to join a session: when someone wants to join a game session, they can just press a button for a join request, that will notify 
-	Get notified when someone wants to join a session: the owner of the game session is going to be notified when someone has sent a request to join the session
-	Chatting with other users: to get to know players who are interested in joining a session, people can have a chat beforehand
-	Approve/reject join request: owners of the sessions have the option to accept or reject a person request to join the session
-	Group chat among players who are going to the same gaming session
-	Get notified when there is a new game ad around you(for all games or particular games)(also can choose the radius)
-	Add/change the base location of the user.

# Feasibility and Technology
![alt text](https://github.com/knet0003/Assessment2/blob/main/firebase_architecture.png)
Architecture with Firebase handling all backend activities

![alt text](https://github.com/knet0003/Assessment2/blob/main/web_service_architecture.png)
Brief Overview of Web Service Architecture

## Technical feasibility:

To deploy the web service or the backend services of the application we can use the Firebase services which are present for IOS applications. Firebase provides a real-time database which can be used for maintaining all the data we need for our application. It also has an authentication feature which can be utilised. As the users in the app may increase there is a way to use cocoa pods with Firebase to make it scalable. Thereby most of the backend services of the application can be done through Firebase. As the database provided by Firebase is real-time this can be easily used for the messaging service provided in the application. 
To get the messaging service UI elements we can use MessageKit. Also, we will need to have a connection to a game(board & video) database API, as an option, we recommend Board Game Atlas and The Game Database (TGDB), as they are free and easy to use.

