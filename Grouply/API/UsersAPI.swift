//
//  UsersAPI.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/28/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Supabase

protocol UsersAPIProtocol {
    func fetchUser(userId: String) async throws -> User
}

class UsersAPI: UsersAPIProtocol {
    static let shared: UsersAPI = UsersAPI()
    
    private init() {}
    
    func fetchUser(userId: String) async throws -> User {
        let user: User = try await supabase
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return user
    }
}
