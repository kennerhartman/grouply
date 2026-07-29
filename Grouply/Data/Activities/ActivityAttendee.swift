//
//  ActivityAttendee.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/28/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

struct ActivityAttendee: Decodable, Identifiable {
    var id: String
    var role: String
    var profile: User?
    var rsvpResponse: RsvpResponse?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case role
        case profile = "profiles"
        case rsvpResponse
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.role = try container.decode(String.self, forKey: .role)
        self.profile = try container.decodeIfPresent(User.self, forKey: .profile)
        self.rsvpResponse = try container.decodeIfPresent(RsvpResponse.self, forKey: .rsvpResponse)
    }
}

enum RsvpResponse: String, Codable, Sendable {
    case yes = "yes"
    case no = "no"
    case maybe = "maybe"
}
