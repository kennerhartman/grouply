//
//  AppState+Auth.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/28/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import Supabase

extension AppState {
    func handleUniversalLink(for url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        guard let queryItems = components.queryItems else { return }
        guard let groupId = queryItems.first(where: { $0.name == "id" })?.value else { return }
        
        if components.host == "join" {
            if self.isAuthenticated, let session = self.session {
                Task {
                    await self.performJoinGroup(groupId: groupId, session: session)
                }
            } else {
                self.pendingGroupJoinId = groupId
            }
        }
    }
    
    func processPendingJoin(isAuthenticated: Bool) {
        if isAuthenticated,
           let groupId = self.pendingGroupJoinId,
           let session = self.session {
                
            self.pendingGroupJoinId = nil
                
            Task {
                await performJoinGroup(groupId: groupId, session: session)
            }
        }
    }
        
    func performJoinGroup(groupId: String, session: Session) async {
        do {
            try await GroupsAPI.shared.joinGroup(
                groupId: groupId,
                userId: session.user.id
            )
            
            self.groups = try await GroupsAPI.shared.fetchGroups()
        } catch {
            print("Failed to join group: \(error)")
        }
    }
}
