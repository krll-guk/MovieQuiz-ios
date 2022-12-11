//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kirill Guk on 7/12/22.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}
