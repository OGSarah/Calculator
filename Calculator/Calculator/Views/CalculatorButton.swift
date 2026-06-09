//
//  CalculatorButton.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct CalculatorButton: View {
    let title: String
    let action: () -> Void

    // Scales the button size with the user's Dynamic Type setting so the
    // tappable area grows alongside the title text.
    @ScaledMetric(relativeTo: .title) private var buttonSize: CGFloat = 80

    private var isOperation: Bool {
        ["÷", "×", "−", "+", "="].contains(title)
    }

    private var backgroundColor: Color {
        switch title {
        case "AC": return .gray
        case "÷", "×", "−", "+", "=": return .blue.opacity(0.8)
        default: return .blue.opacity(0.3)
        }
    }

    private var textColor: Color {
        title == "AC" ? .white : .primary
    }

    // A human-readable name VoiceOver speaks in place of the raw symbol,
    // which would otherwise be announced poorly or not at all.
    private var accessibilityName: String {
        switch title {
        case "AC": return "All clear"
        case "+": return "Plus"
        case "−": return "Minus"
        case "×": return "Multiply"
        case "÷": return "Divide"
        case "=": return "Equals"
        default: return title
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .foregroundColor(textColor)
                // The square size scales with Dynamic Type so the tappable
                // area grows alongside the title text.
                .frame(width: buttonSize, height: buttonSize)
                .background(backgroundColor)
                .cornerRadius(buttonSize / 2)
        }
        .accessibilityLabel(accessibilityName)
        // Keep the raw symbol as the identifier so UI tests can locate
        // buttons regardless of the spoken VoiceOver label.
        .accessibilityIdentifier(title)
    }
}

// MARK: Previews
#Preview("Light Mode") {
    CalculatorButton(title: "1", action: { print("Button pressed") })
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CalculatorButton(title: "1", action: { print("Button pressed") })
        .preferredColorScheme(.dark)
}
