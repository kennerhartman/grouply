//
//  GroupCard.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Supabase

struct GroupCard: View {
    @Environment(AppState.self) private var appState
    
    @State private var isShowingGroupForm: Bool = false
    
    let group: Group
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(self.group.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                
            }
            .frame(maxWidth: .infinity)
            
            if let description = self.group.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    
                    Text(self.group.groupMembersCount.formatted())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text(self.role)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .glassEffect(in: .capsule)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .contextMenu {
            if self.hasManageAccess {
                Button {
                    self.isShowingGroupForm.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await GroupsAPI.shared.deleteGroup(id: self.group.id)
                        } catch {
                            print("Failed to delete group: \(error)")
                        }
                        
                        await self.fetchGroups()
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            
            if !self.isOwner {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await GroupsAPI.shared.leaveGroup(groupId: self.group.id, userId: self.appState.session!.user.id)
                        } catch {
                            print("Failed to leave group: \(error)")
                        }
                        
                        await self.fetchGroups()
                    }
                } label: {
                    Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .glassEffect(in: .rect(cornerRadius: 16))
        .sheet(isPresented: self.$isShowingGroupForm) {
            GroupForm(
                model: GroupFormViewModel(
                    id: self.group.id,
                    name: self.group.name,
                    description: self.group.description ?? ""
                ),
                isEditing: true
            )
        }
    }
    
    private func fetchGroups() async {
        do {
            self.appState.groups = try await GroupsAPI.shared.fetchGroups()
        } catch {
            print("Failed to fetch groups: \(error)")
        }
    }
}

extension GroupCard {
    var user: GroupMember? {
        guard let currentUserId = self.appState.session?.user.id.uuidString.lowercased() else {
            return nil
        }
        
        guard let member = self.group.groupMembers.first(where: { $0.user_id == currentUserId }) else {
            return nil
        }
        
        return member
    }
    
    var role: String {
        if let user = self.user {
            return user.role.capitalized
        }
        
        return "Unknown"
    }
    
    var isOwner: Bool {
        if let user = self.user {
            return user.role == "owner"
        }
        
        return false
    }
    
    var hasManageAccess: Bool {
        if let user = self.user {
            return user.role == "owner" || user.role == "editor"
        }
        
        return false
    }
}

#Preview {
    GroupCard(
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
