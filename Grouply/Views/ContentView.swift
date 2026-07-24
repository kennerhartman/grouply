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
    @State private var appState = AppState()
    @State private var user: User? = nil
    
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
        .environment(self.appState)
    }
    
    
}



#Preview {
    ContentView()
}
