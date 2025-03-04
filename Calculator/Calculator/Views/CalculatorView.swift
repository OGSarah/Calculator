//
//  CalculatorView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct ButtonConfig {
    let title: String
}

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var showingSessionSheet = false

    private let buttonLayout: [[ButtonConfig?]] = [
        [.init(title: "7"), .init(title: "8"), .init(title: "9"), .init(title: "AC")],
        [.init(title: "4"), .init(title: "5"), .init(title: "6"), .init(title: "+")],
        [.init(title: "1"), .init(title: "2"), .init(title: "3"), .init(title: "−")],
        [.init(title: "0"), .init(title: "×"), .init(title: "÷"), .init(title: "=")]
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            sessionButton
            calculatorDisplay
        }
        .sheet(isPresented: $showingSessionSheet) {
            SessionHistorySheetView(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .padding(20)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("App is going to background - triggering sync")
            viewModel.postSessionDataToBackend()
        }
    }

    private var sessionButton: some View {
        Button("View Session Data") {
            showingSessionSheet = true
        }
        .font(.title2)
        .padding(20)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var calculatorDisplay: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                historyText
                displayText
                buttonGrid
            }
            .padding(15)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(10)
        }
    }

    private var historyText: some View {
        Text(viewModel.calculationHistory)
            .font(.system(size: 30))
            .foregroundColor(.gray)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var displayText: some View {
        Text(viewModel.display)
            .font(.system(size: 60))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
    }

    private var buttonGrid: some View {
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
