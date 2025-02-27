//
//  SessionDetailView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct SessionDetailView: View {
    let sessionId: String
    let addCount: Int
    let subtractCount: Int
    let multiplyCount: Int
    let divideCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session ID: \(sessionId.prefix(8))...")
                .font(.headline)
            Text("Additions: \(addCount)")
            Text("Subtractions: \(subtractCount)")
            Text("Multiplications: \(multiplyCount)")
            Text("Divisions: \(divideCount)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
        )
    }

}
// MARK: - Previews
#Preview("Light Mode") {
    SessionDetailView(sessionId: "550e8400-e29b-41d4-a716-446655440000", addCount: 3, subtractCount: 2, multiplyCount: 6, divideCount: 0)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SessionDetailView(sessionId: "550e8400-e29b-41d4-a716-446655440000", addCount: 3, subtractCount: 2, multiplyCount: 6, divideCount: 0)
        .preferredColorScheme(.dark)
}
