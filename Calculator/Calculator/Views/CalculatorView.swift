//
//  CalculatorView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Session: \(viewModel.sessionId.prefix(8))...")
                .font(.caption)
                .foregroundColor(.gray)

            Text(viewModel.display)
                .font(.system(size: 60))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()

            ForEach(0..<4) { row in
                HStack(spacing: 10) {
                    ForEach(0..<4) { col in
                        if let button = buttonLayout[row][col] {
                            CalculatorButton(
                                title: button.title,
                                action: { viewModel.handleButtonPress(button.title) }
                            )
                        }
                    }
                }
            }
        }
        .padding()
    }

    private let buttonLayout: [[ButtonConfig?]] = [
        [.init(title: "7"), .init(title: "8"), .init(title: "9"), .init(title: "/")],
        [.init(title: "4"), .init(title: "5"), .init(title: "6"), .init(title: "*")],
        [.init(title: "1"), .init(title: "2"), .init(title: "3"), .init(title: "-")],
        [.init(title: "0"), .init(title: "C"), .init(title: "="), .init(title: "+")]
    ]
}

// MARK: - Previews
#Preview("Light Mode") {
    CalculatorView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CalculatorView()
        .preferredColorScheme(.dark)
}
