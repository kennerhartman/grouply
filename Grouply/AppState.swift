//
//  AppState.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Observation
import Supabase

@Observable
class AppState {
    var session: Session? = nil
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    init() {
        Task {
            await self.restoreSession()
        }
    }
    
    private func restoreSession() async {
        do {
            let session = try await supabase.auth.session
            
            self.session = session
        } catch {
            self.session = nil
        }
    }
}
