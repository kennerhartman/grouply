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
    func deleteActivity(activityId: String) async throws
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
    
    func deleteActivity(activityId: String) async throws {
        try await supabase
            .from("activities")
            .delete()
            .eq("id", value: activityId)
            .execute()
    }
}
