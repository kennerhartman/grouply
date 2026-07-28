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
    func restoreSession() async {
        do {
            let session = try await supabase.auth.session
            
            self.session = session
        } catch {
            self.session = nil
        }
    }

    func fetchUser() async {
        guard let session = self.session else { return }
        
        do {
            let user: User = try await UsersAPI.shared.fetchUser(userId: session.user.id.uuidString.lowercased())
            
            self.currentUser = user
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}
