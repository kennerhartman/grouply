//
//  MapItemDetailsSheet.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/24/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


import SwiftUI
import Observation
import MapKit

struct MapItemDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: MKMapItem
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(item.name ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                        self.onConfirm()
                    } label: {
                        Label("Confirm", systemImage: "checkmark")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
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