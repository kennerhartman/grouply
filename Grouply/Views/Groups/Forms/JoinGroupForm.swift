//
//  GroupForm.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Observation
import Supabase

struct JoinGroupForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var model: JoinGroupFormViewModel = JoinGroupFormViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Group Invite Code", text: self.$model.id)
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            do {
                                try await GroupsAPI.shared.joinGroup(
                                    groupId: self.model.id,
                                    userId: self.appState.session!.user.id
                                )
                            } catch {
                                print("Failed to join group with id of \(self.model.id): \(error)")
                            }
                            
                            do {
                                self.appState.groups = try await GroupsAPI.shared.fetchGroups()
                            } catch {
                                print("Failed to fetch groups: \(error)")
                            }
                            
                            dismiss()
                        }
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }
}

@Observable
class JoinGroupFormViewModel {
    var id: String = ""
}

#Preview {
    JoinGroupForm()
}

