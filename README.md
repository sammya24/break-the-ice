CSE 438 FINAL PROJECT - Break The Ice

Ken Whitestone - Samantha Hong - Neziha Aktas - Yuri Liu - Elaine Choy

App description: A way to ‘break the ice’ for students in classes, and allow them an opportunity to meet new classmates. It is becoming increasingly difficult to meet new peers, and so our app will allow students to take a questionnaire in order to build a profile on them. Students can then join classes that are created by the instructor at the beginning of the semester. Students will then be matched and introduced to each other based on their likes and similarities. 

Users can register and login. Secure login and password storage system via FireBase authentication. Remembers user sessions, so user will stay logged in on the same account. 
Logged in users complete a questionnaire for which their responses are stored on database. 
Users can either create or join classes via class codes. 

	- If you create a class, you are the instructor and have the option to do grouping, naming, and code creation. 
		- As the instructor for a given class, you choose when to split the students into groups via matchmaking, and in which sizes, such as pairs or trios. 
	- otherwise, you join a class via a classes code, such as 'cse131fall2023'

Upon joining a class, or upon being assigned to a matchmaking group, users will join respective group chats. 

When the chat tab is accessed, the list of chats or groups that the user is a part of is displayed. Selecting any of these brings up the message history for that chat, as a messaging app would. Including sender names and scrolling. And of course ability to send messages in that respective chat. Almost all data is stored in FireStore in an organized and efficient manner. 

Intuitive UI design with comfortable backing in and out between difference chats. 

NOTE: Downloading the repo and immediately trying to run on Xcode will not work due to the use of FireBase. All members of our group had to manually install cocoa pods, 
And install the relevant dependencies via 'pod install'. After downloading the dependencies, you will also need to make sure that the Firebase file dependencies are set to run at 16.4.
Once this has been setup, it should run normally. 
