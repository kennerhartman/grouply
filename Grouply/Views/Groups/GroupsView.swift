//
//  GroupsView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/22/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI

struct GroupsView: View {
    @Environment(AppState.self) private var appState
    
    @State private var isShowingGroupForm: Bool = false
    @State private var isShowingJoinGroupForm: Bool = false
    @State private var isShowingProfileSheet: Bool = false
    
    var body: some View {
        VStack {
            if self.appState.groups.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No Groups Yet")
                        .font(.headline)
                    
                    Text("Create your own group or join an existing one to get started.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        GlassButton(
                            title: "Create Group",
                            tint: .blue,
                            action: {
                                self.isShowingGroupForm.toggle()
                            }
                        )
                        .buttonStyle(.glassProminent)
                        
                        GlassButton(
                            title: "Join Group",
                            tint: .blue,
                            action: {
                                self.isShowingJoinGroupForm.toggle()
                            }
                        )
                        .buttonStyle(.glass)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                ScrollView {
                    ForEach(self.appState.groups, id: \.id) { group in
                        NavigationLink(destination: GroupView(group: group)) {
                            GroupCard(group: group)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .task {
            do {
                self.appState.groups = try await GroupsAPI.shared.fetchGroups()
            } catch {
                print("Failed to fetch groups: \(error)")
            }
        }
        .sheet(isPresented: self.$isShowingGroupForm) {
            GroupForm()
        }
        .sheet(isPresented: self.$isShowingJoinGroupForm) {
            JoinGroupForm()
        }
        .sheet(isPresented: self.$isShowingProfileSheet) {
            ProfileView()
        }
        .navigationTitle("Groups")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        self.isShowingGroupForm.toggle()
                    } label: {
                        Label("Create Group", systemImage: "plus.circle")
                    }
                    
                    Button {
                        self.isShowingJoinGroupForm.toggle()
                    } label: {
                        Label("Join with Code", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            ToolbarItem {
                Button {
                    self.isShowingProfileSheet.toggle()
                } label: {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
}

#Preview {
    GroupsView()
        .environment(AppState())
}
