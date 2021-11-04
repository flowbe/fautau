//
//  Modifiers.swift
//  Fautau
//
//  Created by Florentin BEKIER on 14/06/2021.
//

import SwiftUI

struct BarIcon: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .font(.body)
            .imageScale(.large)
    }
}

extension View {
    func barIcon(label: String) -> some View {
        modifier(BarIcon(label: label))
    }
}
