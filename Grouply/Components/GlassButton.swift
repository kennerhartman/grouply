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
    var tint: Color = .clear
    var action: () -> Void
    
    var body: some View {
        Button(role: self.role, action: self.action) {
            Text(self.title)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
        }
        .glassEffect(.regular.tint(self.tint).interactive())
        .buttonStyle(.plain)
    }
}
