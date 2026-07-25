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
    
    @State private var model = ActivityFormViewModel()
    @State private var isMapPresented: Bool = false
    
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
}

#Preview {
    ActivityForm(groupId: "dUn3DXs")
    
//    MapView(model: .constant(ActivityFormViewModel()))
}
