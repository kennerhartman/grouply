//
//  AppState.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Observation
import Supabase
import Foundation

@Observable
class AppState {
    var session: Session? {
        didSet {
            if session != nil {
                Task {
                    await self.fetchUser()
                }
            } else {
                self.currentUser = nil
            }
        }
    }
    
    var currentUser: User? = nil
    
    var isAuthenticated: Bool {
        self.session != nil
    }
    
    var pendingGroupJoinId: String? = nil
    
    var groups: [Group] = []
    
    init() {
        Task {
            await self.restoreSession()
        }
    }
}
