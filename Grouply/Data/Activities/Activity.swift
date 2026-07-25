//
//  Activity.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/25/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import Supabase

struct Activity: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String
    let group_id: String
    let location_address: String
    let location_url: String
    let scheduled_at: Date
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case group_id
        case location_address
        case location_url
        case scheduled_at
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.group_id = try container.decode(String.self, forKey: .group_id)
        self.location_address = try container.decode(String.self, forKey: .location_address)
        self.location_url = try container.decode(String.self, forKey: .location_url)
        self.scheduled_at = try container.decode(Date.self, forKey: .scheduled_at)
    }
    
    init(name: String, description: String, group_id: String, location_address: String, location_url: String, scheduled_at: Date) {
        self.id = IDGenerator.generateId()
        self.name = name
        self.description = description
        self.group_id = group_id
        self.location_address = location_address
        self.location_url = location_url
        self.scheduled_at = scheduled_at
    }
}
