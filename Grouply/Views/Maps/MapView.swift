//
//  MapView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/24/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//


import SwiftUI
import Observation
import MapKit

struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let locationManager = CLLocationManager()
    
    @Namespace var map
    
    @State private var model: MapViewModel = MapViewModel()
    
    var onSelect: (String, String) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: self.$model.cameraPosition, selection: self.$model.selectedFeature, scope: self.map) {
                UserAnnotation()
                
                // TODO: ADD A WAY FOR USERS TO SEARCH MAP ITEMS
            }
            .onAppear {
                self.locationManager.requestWhenInUseAuthorization()
            }
            .sheet(item: self.$model.mapItem, onDismiss: {
                self.model.selectedFeature = nil
            }) { item in
                MapItemDetailsSheet(item: item.mapItem) {
                    if let address = item.mapItem.address?.fullAddress,
                       let url = self.model.generateAppleMapsURL(for: item.mapItem) {
                        
                        self.onSelect(address, url)
                    }
                    
                    dismiss()
                }
            }
            
            Button {
                self.model.center()
            } label: {
                Image(systemName: self.model.cameraPosition.followsUserLocation ? "location.fill" : "location")
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .padding(12)
                    .background(.regularMaterial)
                    .foregroundColor(.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
        .mapScope(self.map)
        .navigationTitle("Select Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
            }
        }
    }
}

struct IdentifiableMapItem: Identifiable {
    let id: UUID = .init()
    let mapItem: MKMapItem
}

@Observable
class MapViewModel {
    var selectedFeature: MapFeature? {
        didSet {
            if let feature = self.selectedFeature {
                Task {
                    if let item = await self.fetchMapItem(for: feature) {
                        await MainActor.run {
                            self.mapItem = IdentifiableMapItem(mapItem: item)
                        }
                    }
                }
            }
        }
    }
    
    var mapItem: IdentifiableMapItem? = nil
    var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    func center() {
        withAnimation(.easeInOut(duration: 1.0)) {
            self.cameraPosition = .userLocation(fallback: .automatic)
        }
    }
    
    func fetchMapItem(for feature: MapFeature) async -> MKMapItem? {
        do {
            let request = MKMapItemRequest(feature: feature)
            
            return try await request.mapItem
        } catch {
            print("Failed to fetch map item: \(error)")
            return nil
        }
    }
    
    func generateAppleMapsURL(for mapItem: MKMapItem) -> String? {
        let coordinate = mapItem.location.coordinate
        
        guard let name = mapItem.name else { return nil }
        
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        return "https://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(encodedName)"
    }
}
