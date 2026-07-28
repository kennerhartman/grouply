//
//  ActivityForm.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/23/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI
import Observation
import MapKit

struct ActivityForm: View {
    @Environment(\.dismiss) private var dismiss
    
    let groupId: String
    let activityToEdit: Activity?
    
    @State private var model: ActivityFormViewModel
    @State private var isMapPresented: Bool = false
    
    init(groupId: String, activityToEdit: Activity? = nil) {
        self.groupId = groupId
        self.activityToEdit = activityToEdit
        
        _model = State(initialValue: ActivityFormViewModel(activity: activityToEdit))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Details") {
                    TextField("Activity Name", text: self.$model.name)
                    TextField("Activity Description", text: self.$model.description)
                }
                
                Section {
                    DatePicker("Scheduled Time", selection: self.$model.scheduledTime)
                }
                
                Section("Location Details") {
                    Button {
                        self.isMapPresented.toggle()
                    } label: {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(self.model.locationAddress.isEmpty ? "Select on Map" : self.model.locationAddress)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    TextField("Address", text: self.$model.locationAddress)
                    TextField("URL", text: self.$model.locationUrl)
                }
            }
            .fullScreenCover(isPresented: self.$isMapPresented) {
                NavigationStack {
                    MapView() { address, url in
                        self.model.locationAddress = address
                        self.model.locationUrl = url
                    }
                }
            }
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
                            if let activity = self.activityToEdit {
                                do {
                                    try await ActivitiesAPI.shared.updateActivity(
                                        activity: Activity(
                                            id: activity.id,
                                            name: self.model.name,
                                            description: self.model.description,
                                            group_id: self.groupId,
                                            location_address: self.model.locationAddress,
                                            location_url: self.model.locationUrl,
                                            scheduled_at: self.model.scheduledTime
                                        )
                                    )
                                } catch {
                                    print("Failed to update activity: \(error)")
                                }
                            } else {
                                do {
                                    try await ActivitiesAPI.shared.createActivity(
                                        activity: Activity(
                                            name: self.model.name,
                                            description: self.model.description,
                                            group_id: self.groupId,
                                            location_address: self.model.locationAddress,
                                            location_url: self.model.locationUrl,
                                            scheduled_at: self.model.scheduledTime
                                        )
                                    )
                                } catch {
                                    print("Failed to create activity: \(error)")
                                }
                            }
                        }
                        
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
        }
    }
}

@Observable
class ActivityFormViewModel {
    var name: String = ""
    var description: String = ""
    var scheduledTime: Date = Date()
    var locationAddress: String = ""
    var locationUrl: String = ""
    
    init(activity: Activity? = nil) {
        if let activity = activity {
            self.name = activity.name
            self.description = activity.description
            self.scheduledTime = activity.scheduled_at
            self.locationAddress = activity.location_address
            self.locationUrl = activity.location_url
        }
    }
}

#Preview {
    ActivityForm(groupId: "dUn3DXs")
}
