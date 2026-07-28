//
//  ActivityCard.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/24/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI

struct ActivityCard: View {
    let activity: Activity
    let hasManageAccess: Bool
    
    var onEditAction: (() -> Void)?
    var onDeleteAction: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(self.activity.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            if !self.activity.description.isEmpty {
                Text(self.activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    
                    Text(self.activity.scheduled_at, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("at")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(self.activity.scheduled_at, style: .time)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
                
                if !self.activity.location_address.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                        
                        Text(self.activity.location_address)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if let url = URL(string: self.activity.location_url) {
                            Link(destination: url) {
                                Image(systemName: "map.fill")
                                    .font(.caption)
                                    .padding(6)
                                    .glassEffect(in: .circle)
                            }
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .glassEffect(in: .rect(cornerRadius: 16))
        .contextMenu {
            if self.hasManageAccess {
                Button {
                    self.onEditAction?()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    Task {
                        do {
                            try await ActivitiesAPI.shared.deleteActivity(activityId: self.activity.id)
                            
                            self.onDeleteAction?()
                        } catch {
                            print("Failed to delete activity: \(error)")
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    ActivityCard(
        activity: Activity(
            name: "Test",
            description: "This is a description.",
            group_id: "Js9d2sE",
            location_address: "",
            location_url: "One Apple Park Way, Cupertino, CA 95014",
            scheduled_at: .distantFuture
        ),
        hasManageAccess: true
    )
}
