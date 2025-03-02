//
//  SessionDetailView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct SessionDetailView: View {
    let title: String
    let session: SessionData
    let dateFormatter: DateFormatter
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isCurrent ? .purple.opacity(0.6) : .primary)
                Spacer()
                // Use postedToBackend for previous sessions, lastUpdated for current
                let displayDate = isCurrent
                ? (dateFormatter.date(from: session.lastUpdated) ?? Date())
                : (session.postedToBackend.flatMap { dateFormatter.date(from: $0) } ?? dateFormatter.date(from: session.lastUpdated) ?? Date())
                Text(dateFormatter.string(from: displayDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                GridRow {
                    statView(label: "Additions", value: session.addCount, symbol: "+")
                    statView(label: "Subtractions", value: session.subtractCount, symbol: "−")
                }
                GridRow {
                    statView(label: "Multiplications", value: session.multiplyCount, symbol: "×")
                    statView(label: "Divisions", value: session.divideCount, symbol: "÷")
                }
            }
            .padding(.vertical, 4)

            Text("Session ID: \(session.sessionId)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 14)
    }

    private func statView(label: String, value: Int, symbol: String) -> some View {
        HStack(spacing: 4) {
            Text(symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    SessionDetailView(
        title: "Session",
        session: SessionData(
            sessionId: "550e8400-e29b-41d4-a716-446655440000",
            addCount: 3,
            subtractCount: 2,
            multiplyCount: 6,
            divideCount: 0,
            lastUpdated: Date()
        ),
        dateFormatter: {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }(),
        isCurrent: true
    )
    .preferredColorScheme(.light)
    .frame(maxWidth: 400)
}

#Preview("Dark Mode") {
    SessionDetailView(
        title: "Session",
        session: SessionData(
            sessionId: "550e8400-e29b-41d4-a716-446655440000",
            addCount: 3,
            subtractCount: 2,
            multiplyCount: 6,
            divideCount: 0,
            lastUpdated: Date()
        ),
        dateFormatter: {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }(),
        isCurrent: false
    )
    .preferredColorScheme(.dark)
    .frame(maxWidth: 400)
}
