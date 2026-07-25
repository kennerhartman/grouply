//
//  GroupForm.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Observation

struct GroupForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var model: GroupFormViewModel
    
    let isEditing: Bool
    
    init(model: GroupFormViewModel? = nil, isEditing: Bool = false) {
        if let model = model {
            _model = State(initialValue: model)
        } else {
            _model = State(initialValue: GroupFormViewModel())
        }
        
        self.isEditing = isEditing
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Group Name", text: self.$model.name)
                TextField("Group Description", text: self.$model.description)
            }
            .navigationTitle(self.isEditing ? "Edit Group Details" : "Create Group")
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
                            if self.isEditing {
                                if (self.model.id == nil) {
                                    return
                                }
                                
                                do {
                                    try await GroupsAPI.shared.updateGroup(
                                        id: self.model.id!,
                                        newName: self.model.name,
                                        newDescription: self.model.description
                                    )
                                } catch {
                                    print("Failed to update group: \(error)")
                                }
                                
                                await self.fetchGroups()
                            } else {
                                do {
                                    try await GroupsAPI.shared.createGroup(
                                        name: self.model.name,
                                        description: self.model.description
                                    )
                                } catch {
                                    print("Failed to create group: \(error)")
                                }
                                
                                await self.fetchGroups()
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
    
    private func fetchGroups() async {
        do {
            self.appState.groups = try await GroupsAPI.shared.fetchGroups()
        } catch {
            print("Failed to fetch groups: \(error)")
        }
    }
}

@Observable
class GroupFormViewModel {
    let id: String?
    
    var name: String = ""
    var description: String = ""
    
    init(id: String? = nil) {
        self.id = id
    }
    
    init(id: String? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

#Preview {
    GroupForm()
        .environment(AppState())
}

