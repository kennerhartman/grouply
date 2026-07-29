//
//  ActivitiesAPI.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import Supabase

protocol ActivitiesAPIProtocol {
    func fetchActivities(groupId: String) async throws -> [Activity]
    func createActivity(activity: Activity) async throws
    func updateActivity(activity: Activity) async throws
    func deleteActivity(activityId: String) async throws
    
    func fetchRsvpResponses(groupId: String, activityId: String) async throws -> [ActivityAttendee]
    func rsvpToActivity(activityId: String, userId: String, response: RsvpResponse) async throws
}



class ActivitiesAPI: ActivitiesAPIProtocol {
    static let shared = ActivitiesAPI()
    
    private init() {}
    
    func fetchActivities(groupId: String) async throws -> [Activity] {
        let activities: [Activity] = try await supabase
            .from("activities")
            .select("*")
            .eq("group_id", value: groupId)
            .execute()
            .value
        
        return activities
    }
    
    func createActivity(activity: Activity) async throws {
        try await supabase
            .from("activities")
            .insert([
                "id": activity.id,
                "name": activity.name,
                "description": activity.description,
                "group_id": activity.group_id,
                "location_address": activity.location_address,
                "location_url": activity.location_url,
                "scheduled_at": activity.scheduled_at.ISO8601Format()
            ])
            .execute()
    }
    
    func updateActivity(activity: Activity) async throws {
        try await supabase
            .from("activities")
            .update([
                "id": activity.id,
                "name": activity.name,
                "description": activity.description,
                "group_id": activity.group_id,
                "location_address": activity.location_address,
                "location_url": activity.location_url,
                "scheduled_at": activity.scheduled_at.ISO8601Format()
            ])
            .eq("id", value: activity.id)
            .execute()
    }
    
    func deleteActivity(activityId: String) async throws {
        try await supabase
            .from("activities")
            .delete()
            .eq("id", value: activityId)
            .execute()
    }
    
    func fetchRsvpResponses(groupId: String, activityId: String) async throws -> [ActivityAttendee] {
        let members: [ActivityAttendee] = try await supabase
            .from("group_members")
            .select(
                """
                user_id,
                role,
                profiles(
                    id, 
                    first_name, 
                    last_name
                )
                """
            )
            .eq("group_id", value: groupId)
            .execute()
            .value
        
        struct RawAttendee: Decodable {
            let user_id: String
            let response: String?
        }
        
        let rawAttendees: [RawAttendee] = try await supabase
            .from("activity_attendees")
            .select("user_id, response")
            .eq("activity_id", value: activityId)
            .execute()
            .value

        var responseMap: [String: RsvpResponse] = [:]
        for attendee in rawAttendees {
            if let responseStr = attendee.response, let rsvp = RsvpResponse(rawValue: responseStr) {
                responseMap[attendee.user_id] = rsvp
            }
        }

        return members.map { member in
            var updated = member
            updated.rsvpResponse = responseMap[member.id]
            return updated
        }
    }
    
    func rsvpToActivity(activityId: String, userId: String, response: RsvpResponse) async throws {
        try await supabase
            .from("activity_attendees")
            .upsert(
                [
                    "activity_id": activityId,
                    "user_id": userId,
                    "response": response.rawValue
                ],
                onConflict: "activity_id, user_id"
            )
            .execute()
    }
}
