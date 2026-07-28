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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [.accentColor.opacity(0.8), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.3.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.group.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.caption2)
                        
                        Text(self.groupMemebrsString)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                Text(self.group.role(for: self.appState))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassEffect(in: .capsule)
            }
            
            Text(self.descriptionString)
                .font(.subheadline)
                .foregroundColor(self.group.description == nil || self.group.description?.isEmpty == true ? .secondary.opacity(0.5) : .secondary)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(height: 38, alignment: .topLeading)
            
            Spacer()
        }
        .padding(16)
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .glassEffect(in: .rect(cornerRadius: 16))
        .contextMenu {
            if self.group.hasManageAccess(for: self.appState) {
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
            
            if !self.group.isOwner(for: self.appState) {
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
    var descriptionString: String {
        guard let description = self.group.description, !description.isEmpty else {
            return "No description provided."
        }
        
        return description
    }
    
    var groupMemebrsString: String {
        let count = self.group.groupMembersCount
        
        if count == 1 {
            return "\(count) member"
        }
        
        return "\(count) members"
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
