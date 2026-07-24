//
//  GroupsRepository.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import Supabase

protocol GroupsAPIProtocol {
    func fetchGroups() async throws -> [Group]
    func createGroup(name: String, description: String) async throws
    func joinGroup(groupId: String, userId: UUID) async throws
    func updateGroup(id: String, newName: String, newDescription: String) async throws
    func deleteGroup(id: String) async throws
    func leaveGroup(groupId: String, userId: UUID) async throws
    
    func generateId() -> String
}

class GroupsAPI: GroupsAPIProtocol {
    static var shared: GroupsAPI = GroupsAPI()
    
    private init() {}
    
    func fetchGroups() async throws -> [Group] {
        let groups: [Group] = try await supabase
            .from("groups")
            .select(
                """
                *,
                group_members_count:group_members(count),
                group_members(
                  user_id,
                  role,
                  profiles(
                    first_name,
                    last_name
                  )
                )
                """
            )
            .execute()
            .value
        
        return groups
    }
    
    func createGroup(name: String, description: String) async throws {
        let id: String = self.generateId()
        
        try await supabase
            .from("groups")
            .insert([
                "id": id,
                "name": name,
                "description": description
            ])
            .execute()
        
        try await supabase
            .from("group_members")
            .insert([
                "group_id": id,
                "user_id": supabase.auth.user().id.uuidString,
                "role": "owner"
            ])
            .execute()
    }
    
    func joinGroup(groupId: String, userId: UUID) async throws {
        try await supabase
            .from("group_members")
            .insert([
                "group_id": groupId,
                "user_id": userId.uuidString,
                "role": "member"
            ])
            .execute()
    }
    
    func updateGroup(id: String, newName: String, newDescription: String) async throws {
        try await supabase
            .from("groups")
            .update([
                "name": newName,
                "description": newDescription
            ])
            .eq("id", value: id)
            .execute()
    }
    
    func deleteGroup(id: String) async throws {
        try await supabase
            .from("groups")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    func leaveGroup(groupId: String, userId: UUID) async throws {
        try await supabase
            .from("group_members")
            .delete()
            .eq("group_id", value: groupId)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    
    func generateId() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789"
        
        var id = ""
        
        for _ in 1...7 {
            id.append(characters.randomElement()!)
        }
        
        return id
    }
}
