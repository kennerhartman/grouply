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
        VStack {
            if (self.appState.isAuthenticated) {
                if (user != nil) {
                    Text("Welcome, \(self.user!.first_name)!")
                } else {
                    ProgressView()
                        .task {
                            await self.fetchUser()
                        }
                }
            } else {
                SignInView()
            }
        }
        .environment(self.appState)
    }
    
    func fetchUser() async {
        if let session = self.appState.session {
            let id = session.user.id
            
            do {
                let user: User = try await supabase
                    .from("profiles")
                    .select("first_name, last_name")
                    .eq("id", value: id)
                    .single()
                    .execute()
                    .value
                
                self.user = user
            } catch {
                print("Error fetching user: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
