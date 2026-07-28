//
//  ContentView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            VStack {
                if self.appState.isAuthenticated {
                    GroupsView()
                } else {
                    SignInView()
                }
            }
        }
        .onOpenURL { url in
            self.appState.handleUniversalLink(for: url)
        }
        .onChange(of: self.appState.isAuthenticated) { _, isAuthenticated in
            self.appState.processPendingJoin(isAuthenticated: isAuthenticated)
        }
        .onAppear {
            self.appState.processPendingJoin(isAuthenticated: self.appState.isAuthenticated)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
