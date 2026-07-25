//
//  GroupMember.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

struct GroupMember: Decodable {
    let user_id: String
    let role: String
    let profiles: User?
    
    init(user_id: String, role: String, profiles: User?) {
        self.user_id = user_id
        self.role = role
        self.profiles = profiles
    }
}
