//
//  Card.swift
//  Project 17 FlashZilla
//
//  Created by Артем Волков on 19.03.2021.
//

import Foundation


struct Card: Codable  {
    let prompt: String
    let answer: String
    
    static var example: Card  {
        Card(prompt: "Who is it?", answer: "It is a cat")
    }
}
