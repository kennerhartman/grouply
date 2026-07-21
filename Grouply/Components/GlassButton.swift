//
//  GlassButton.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI

struct GlassButton: View {
    let title: String
    var role: ButtonRole? = nil
    var tint: Color
    var action: () -> Void
    
    var body: some View {
        Button(role: self.role, action: self.action) {
            Text(self.title)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .contentShape(Rectangle())
                .padding()
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(self.tint).interactive())
    }
}
