//
//  Article.swift
//  PracticeLibrary
//
//  Created by riku on 2022/01/21.
//

import Foundation

struct Article: Codable {
    let title: String
    var user: User
    
    struct User: Codable {
        var name: String
    }
}
