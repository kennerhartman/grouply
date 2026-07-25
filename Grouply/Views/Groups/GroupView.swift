//
//  GroupView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Supabase

struct GroupView: View {
    @Environment(AppState.self) private var appState
    
    let group: Group
    
    @State private var activities: [Activity] = []
    @State private var isFormShowing: Bool = false
    
    var body: some View {
        VStack {
            if self.activities.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Activities Yet")
                        .font(.headline)
                    
                    if self.group.hasManageAccess(for: self.appState) {
                        Text("Create an activity to get started.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            GlassButton(
                                title: "Create Activity",
                                tint: .blue,
                                action: {
                                    self.isFormShowing.toggle()
                                }
                            )
                            .buttonStyle(.glassProminent)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    ForEach(self.activities) { activity in
                        ActivityCard(
                            activity: activity,
                            hasManageAccess: self.group.hasManageAccess(for: self.appState)
                        ) {
                            Task {
                                await self.fetchActivites()
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            if self.group.hasManageAccess(for: self.appState) {
                Button {
                    self.isFormShowing.toggle()
                } label: {
                    Label("Create Activity", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: self.$isFormShowing, onDismiss: {
            Task {
                await self.fetchActivites()
            }
        }) {
            ActivityForm(groupId: self.group.id)
        }
        .task {
            await self.fetchActivites()
        }
        .navigationTitle("Activities")
    }
    
    private func fetchActivites() async {
        do {
            self.activities = try await ActivitiesAPI.shared.fetchActivities(groupId: self.group.id)
        } catch {
            print("Failed to fetch activites for group with ID '\(self.group.id): \(error)'")
        }
    }
}

#Preview {
    GroupView(
        group:
            Group(
                id: "5wgREfD",
                name: "Group Name",
                description: "Group Desc.",
                groupMembersCount: 5,
                groupMembers: [
                    GroupMember(
                        user_id: "test",
                        role: "member",
                        profiles: nil
                    )
                ]
            )
    )
    .environment(AppState())
}
