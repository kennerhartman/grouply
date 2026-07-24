//
//  Group.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

struct Group: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String?
    
    let groupMembersCount: Int
    let groupMembers: [GroupMember]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case groupMembersCount = "group_members_count"
        case groupMembers = "group_members"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        
        let countContainers = try? container.decode([[String: Int]].self, forKey: .groupMembersCount)
        self.groupMembersCount = countContainers?.first?["count"] ?? 0
        
        self.groupMembers = try container.decodeIfPresent([GroupMember].self, forKey: .groupMembers) ?? []
    }
    
    init(id: String, name: String, description: String?, groupMembersCount: Int, groupMembers: [GroupMember]) {
        self.id = id
        self.name = name
        self.description = description
        self.groupMembersCount = groupMembersCount
        self.groupMembers = groupMembers
    }
}
