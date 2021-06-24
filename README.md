
# Application Concept 

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
Frameworks to be used for this application:
- EventKit – This framework will be used to send notifications to the user and later maybe add any upcoming game to their calendar.
-	MapKit – This framework is needed to be able to accept location when creating a game session, also it is used to give the same information to the attendees.
-	CoreLocation – This framework is going to be used to determine the location of the user and get the exact coordinates.
-	CoreData – This framework is going to be used to save user information so they don’t have to log in every time the application is being opened. Also, it can be used to cache data so the basic information in the application is already present in the device.
-	Security – This framework is going to secure the data that the application uses and to use for authentication and authorisation
-	AdSupport – To generate revenue later we will have to use this framework to be able to show targeted ads to the user.


## Legal feasibility:
To avoid underage being under risk, all users must be over 18 when registering for the application. There is also a considerable amount of privacy issues because there is sensitive information being shared on the application such as location.

## Economic Feasibility:
As all the services and API being used are free in the start model, we do not have to incur any significant costs. As the number of users increases, we will have to give proper support using Cocoa-pods which is already available to be easily integrated with Firebase service. Also, we can have targeted ads in-app to later get revenue to be able to support multiple users as well as doing cross-promotion with other applications.

# Interface Design and Storyboard Mock-ups 
## Colours:


To achieve high clarity, we use high contrasting colours. Most of the text is light grey coloured which is easily distinguishable from the black background as well as from the dark grey of tab bar at the bottom. 
Green in the colour being used to indicate interactivity as well as a highlight colour. For example, the link colour at the sign-in and the register page and all the buttons in the application, are green. It is also used as a visual aid, to achieve hierarchy on how the information is being shown to the user, the more important pieces of information are green coloured. In the tab bar, the green highlighted icons indicate at which page the user is at.

## Navigation:
The main point of navigation is the tab bar at the bottom. We used a tab bar to flatten the information hierarchy and to provide users with access to different pieces of information at once. It provides a consistent experience for users as they can always access this bar and toggle between the pages.

![alt text](https://github.com/knet0003/Assessment2/blob/main/signIn.png)

There are 4 tabs the users can choose from Home, Games, Messages and Notifications.

![alt text](https://github.com/knet0003/Assessment2/blob/main/gameflow.png)

In the Home page, users can see their top played games as well as an option for them to join a new game session. When they click on the button they are navigated to a new page where they can see all the game sessions that are available in their area. Upon clicking on a game from the table view they are directed to the Game Info page where they can view general information about the game session as well an option to join the game. When they click the “Join game” button there is feedback whether the request to join was successful or not.

![alt text](https://github.com/knet0003/Assessment2/blob/main/home.png)
![alt text](https://github.com/knet0003/Assessment2/blob/main/messages.png)
![alt text](https://github.com/knet0003/Assessment2/blob/main/notifications.png)

In the home page, the users can also click on the left of the navigation bar, which will display a navigation drawer. From the navigation drawer, users can manage their account information, they can change their settings and they can also log out of the application.
On the messages tab, in the navigation bar users can see how many unread messages they have. They can also create a new message or click on any message to open the message history with the other user.
In the notification tab, users can see all the notification they have received. Users get notifications if there are any join request to their game sessions or if their join requests have been accepted or rejected by the host.


![alt text](https://github.com/knet0003/Assessment2/blob/main/add_game.png)


In the games tab, users can see all the games they are part of. These include game sessions that they created as well as the ones that they have joined. From here they have an option to create a new game session.
In the add game tab users are asked to input details about the game session such as the name of the session, the number of players required, date and time and location.
When looking for the game users are searching for board/video games pulled from the API and being presented with the list of matching results.


# Scope and Limitations 
The feature mentioned below should give a good idea about the feasibility and the future scope of the product being proposed. If the outcome is positive, then the additional feature mentioned further below should be added to give a complete product.

## Features present for a Minimum Viable Product:
1.	Safe and Secure login/ Sign up feature with the help of firebase.
2.	User can add or join as many game sessions as they want.
3.	Game sessions can be deleted later by the owner.
4.	Game sessions can be joined or left anytime.
5.	Almost all types of board/video games supported.
6.	User can manage their account information with edit options for most of the information especially their home location as they may want to play a game when in a new location or if they move to a new location.
7.	User can adjust the radius of the search for game sessions near them.
8.	User can search for a particular game near them.
9.	Users have their favourite games, so it is easier for others to see the similarity between them.
10.	Owner of a game can send a message to the person requesting to join the game before adding them to the session.
11.	Message service between users so they can first get to know each other before meeting physically for a game.
12.	Location services will be needed and used to get the nearby games from the user base location.

## What can be added later to improve the scope of the game:
1.	Favourite games are given more priorities when searching for games.
2.	Notifications when a favourite game is being played around them.
3.	Users can make friends among them for easier connectivity and bonding.
4.	Users can have private games among friends or have the option to keep their games public to cater to anyone and everyone.
5.	Group chat option between friends or between all the players in a particular game session.
6.	A game session can be made reoccurring such as every week or every month with notifications to the users attending the game.
7.	Links to social media accounts can be added to make the friends in the app closer and know more about each other or to get to know a person before inviting or accepting them into a game session.
8.	Can support multiple platforms like android and web to increase the users in the application.
9.	Users can leave positive and negative comments about users they have already played with so to give better information and transparency. 

As the Time is limited for this project with only 2 developers only the minimum Viable product as mentioned above should be possible, the additional features to improve the scope and reach of the app can be added later. As this is using multiple APIs which are free and cannot be used for commercial purposes, in the future a paid commercial APIs integration would be needed to be able to generate revenue from the application. As many users start using the application the backend services must be scalable for which a scalable scheduling service will be needed like Cocoa-pods and integrate this with the firebase services already being used. As there is personal information such as a user’s home location being shared, and stored security concerns need to be taken much more seriously. We do not have a way to verify the age of a user when they are creating their account.





