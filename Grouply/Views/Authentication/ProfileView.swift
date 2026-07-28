//
//  ProfileView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/22/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let user = self.appState.currentUser {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text("\(user.first_name) \(user.last_name)")
                    }
                    
                    Spacer()
                    
                    GlassButton(
                        title: "Sign Out",
                        role: .destructive,
                        action: {
                            Task {
                                self.appState.session = nil
                                try await supabase.auth.signOut()
                            }
                            
                            dismiss()
                        }
                    )
                    .buttonStyle(.glassProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
