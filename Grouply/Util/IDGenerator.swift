//
//  IDGenerator.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

final class IDGenerator {
    static func generateId() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789"
        
        var id = ""
        
        for _ in 1...7 {
            id.append(characters.randomElement()!)
        }
        
        return id
    }
}
