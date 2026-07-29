//
//  ActivityDetailsView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/28/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import MapKit

struct ActivityDetailsView: View {
    @Environment(AppState.self) private var appState
    
    let activity: Activity
    
    @State private var attendees: [ActivityAttendee] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("RSVP") {
                    RsvpSection(activity: self.activity, currentResponse: self.currentResponse) {
                        Task {
                            await self.fetchResponses()
                        }
                    }
                }
                
                if self.goingMembers.count > 0 {
                    Section("Going (\(self.goingMembers.count))") {
                        ResponseSection(
                            attendees: self.goingMembers,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                    }
                }
                
                
                if self.maybeMembers.count > 0 {
                    Section("Maybe (\(self.maybeMembers.count))") {
                        ResponseSection(
                            attendees: self.maybeMembers,
                            color: .orange,
                            icon: "questionmark.circle.fill"
                        )
                    }
                }
                
                if self.notGoingMembers.count > 0 {
                    Section("Not Going (\(self.notGoingMembers.count))") {
                        ResponseSection(
                            attendees: self.notGoingMembers,
                            color: .red,
                            icon: "xmark.circle.fill"
                        )
                    }
                }
                
                if self.pendingMembers.count > 0  {
                    Section("No Response (\(self.pendingMembers.count))") {
                        ResponseSection(
                            attendees: self.pendingMembers,
                            color: .gray,
                            icon: "clock.fill"
                        )
                    }
                }
            }
            .navigationTitle(self.activity.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await self.fetchResponses()
            }
        }
    }
    
    private func fetchResponses() async {
        do {
            self.attendees = try await ActivitiesAPI.shared.fetchRsvpResponses(groupId: self.activity.group_id, activityId: self.activity.id)
        } catch {
            print("Failed to fetch activity's RSVP responses: \(error)")
        }
    }
}

extension ActivityDetailsView {
    private var goingMembers: [ActivityAttendee] {
        self.attendees.filter { $0.rsvpResponse == .yes }
    }
    
    private var maybeMembers: [ActivityAttendee] {
        self.attendees.filter { $0.rsvpResponse == .maybe }
    }
    
    private var notGoingMembers: [ActivityAttendee] {
        self.attendees.filter { $0.rsvpResponse == .no }
    }
    
    private var pendingMembers: [ActivityAttendee] {
        self.attendees.filter { $0.rsvpResponse == nil }
    }
    
    private var currentResponse: RsvpResponse? {
        self.attendees.first(where: {
            $0.profile?.id.uuidString.lowercased() == self.appState.currentUser?.id.uuidString.lowercased()
        })?.rsvpResponse
    }
}

private enum UserError: Error {
    case noUser(String)
}

private struct RsvpSection: View {
    @Environment(AppState.self) private var appState
    
    let activity: Activity
    let currentResponse: RsvpResponse?
    
    let onRsvpChange: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            GlassButton(
                title: "Yes",
                role: .confirm,
                tint: .blue,
                action: {
                    Task {
                        await self.sendRsvpResponse(response: .yes)
                    }
                }
            )
            .opacity(self.currentResponse == .yes ? 1.0 : 0.6)
            .buttonStyle(.glassProminent)
            
            GlassButton(
                title: "No",
                role: .destructive,
                tint: .red,
                action: {
                    Task {
                        await self.sendRsvpResponse(response: .no)
                    }
                }
            )
            .opacity(self.currentResponse == .no ? 1.0 : 0.6)
            .buttonStyle(.glassProminent)
            
            GlassButton(
                title: "Maybe",
                action: {
                    Task {
                        await self.sendRsvpResponse(response: .maybe)
                    }
                }
            )
            .opacity(self.currentResponse == .maybe ? 1.0 : 0.6)
            .buttonStyle(.glassProminent)
        }
    }
    
    private func sendRsvpResponse(response: RsvpResponse) async {
        do {
            guard let user: User = self.appState.currentUser else { throw UserError.noUser("Current user is nil.")  }
            
            try await ActivitiesAPI.shared.rsvpToActivity(
                activityId: self.activity.id,
                userId: user.id.uuidString.lowercased(),
                response: response
            )
            
            onRsvpChange()
        } catch {
            print("Failed to send RSVP responses: \(error)")
        }
    }
}

private struct ResponseSection: View {
    @Environment(AppState.self) private var appState
    
    let attendees: [ActivityAttendee]
    let color: Color
    let icon: String
    
    var body: some View {
        ForEach(self.attendees) { response in
            HStack {
                if let profile = response.profile {
                    Text("\(profile.first_name) \(profile.last_name) \(self.isCurrentUser(profile: profile) ? "(You)" : "")")
                }
                
                Spacer()
                
                Image(systemName: self.icon)
                    .foregroundColor(self.color)
            }
        }
    }
    
    private func isCurrentUser(profile: User) -> Bool {
        guard let user = self.appState.currentUser else { return false }
        
        return user.id.uuidString.lowercased() == profile.id.uuidString.lowercased()
    }
}

#Preview {
    ActivityDetailsView(
        activity: Activity(
            name: "Test",
            description: "This is a description.",
            group_id: "Js9d2sE",
            location_address: "One Apple Park Way, Cupertino, CA 95014",
            location_url: "",
            scheduled_at: .distantFuture
        ),
    )
    .environment(AppState())
}
