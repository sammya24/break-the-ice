//
//  Questions.swift
//  break-the-ice-438
//
//  Created by Sam Hong on 11/13/23.
//

import Foundation

struct Question { // struct for one question
    var qID: Int
    var text: String
    var answerOptions: [String]
}

struct UserResponse {
    var qID: Int
    var selectedOptionIndex: Int
}

// TODO: add ability to personalize things like number of questions, question genres and add more questions
// TODO: should we match based on pesonality or to balance technical skills?

var questions: [Question] = [
    Question(qID: 0, text: "What do you do in your free time?", answerOptions: ["Reading a book", "Trying out a new recipe", "Hikeing in nature", "Going to a party"]),
    Question(qID: 1, text: "How do you handle stress?", answerOptions: ["Reflecting in solitude", "Distract myself with hobbies", "Exercise", "Talking with friends"]),
    Question(qID: 2, text: "What kind of movies do you enjoy the most??", answerOptions: ["Documentaries", "Thoughtful dramas", "Romantic comedies", "Action-packed advertures"]),
    Question(qID: 3, text: "In a group project, what role do you take on?", answerOptions: ["Executing and doing hands-on work", "Planning and organizing", "Motivating the team", "Encouraging collaboration"]),
    Question(qID: 4, text: "What is your preferred social setting?", answerOptions: ["Enjoying time alone", "One-on-one conversations", "Small outing with close friends", "Large social gatherings"]),
    Question(qID: 5, text: "How do you approach decision making?", answerOptions: ["Carefully weighing pros and cons", "Trusting your instincts and intuition", "Seeking out advice from others", "Having meal points left over"]),
    Question(qID: 6, text: "How do you feel about change?", answerOptions: ["I prefer stability", "I relecutantly adapt", "I embrace change", "I actively seek it out"]),
]
