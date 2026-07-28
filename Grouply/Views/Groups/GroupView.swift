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
    @State private var isCreatingActivity = false
    @State private var activityToEdit: Activity? = nil
    
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
                        
                        GlassButton(
                            title: "Create Activity",
                            tint: .blue,
                            action: {
                                self.isCreatingActivity.toggle()
                            }
                        )
                        .buttonStyle(.glassProminent)
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
                            hasManageAccess: self.group.hasManageAccess(for: self.appState),
                            onEditAction: {
                                self.activityToEdit = activity
                            },
                            onDeleteAction: {
                                Task {
                                    await self.fetchActivites()
                                }
                            }
                        )
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                let inviterName = self.appState.currentUser?.first_name ?? "a friend"
                
                if let shareURL = URL(string: "grouply://join?id=\(self.group.id)") {
                    ShareLink(
                        item: shareURL,
                        subject: Text("Join \(self.group.name) on Grouply"),
                        message: Text("Join \(inviterName)'s group on Grouply and see upcoming plans!")
                    ) {
                        Label("Share Group", systemImage: "square.and.arrow.up")
                    }
                }
                
                if self.group.hasManageAccess(for: self.appState) {
                    Button {
                        self.isCreatingActivity = true
                    } label: {
                        Label("Create Activity", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: self.$isCreatingActivity, onDismiss: {
            Task { await self.fetchActivites() }
        }) {
            ActivityForm(groupId: self.group.id, activityToEdit: nil)
        }
        .sheet(item: self.$activityToEdit, onDismiss: {
            Task { await self.fetchActivites() }
        }) { activity in
            ActivityForm(groupId: self.group.id, activityToEdit: activity)
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
            print("Failed to fetch activites for group with ID '\(self.group.id)': \(error)")
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
