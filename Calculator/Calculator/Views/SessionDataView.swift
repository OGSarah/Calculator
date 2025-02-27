//
//  SessionDataView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct SessionDataView: View {
    let viewModel: CalculatorViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Current Session
                    Text("Current Session")
                        .font(.title)
                        .foregroundColor(.primary)

                    SessionDetailView(
                        sessionId: viewModel.sessionId,
                        addCount: viewModel.getCurrentOperationCounts()["+", default: 0],
                        subtractCount: viewModel.getCurrentOperationCounts()["−", default: 0],
                        multiplyCount: viewModel.getCurrentOperationCounts()["×", default: 0],
                        divideCount: viewModel.getCurrentOperationCounts()["÷", default: 0]
                    )
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Previous Sessions
                    Text("Previous Sessions")
                        .font(.title2)
                        .foregroundColor(.primary)

                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.getAllSessions().filter { $0.sessionId != viewModel.sessionId }) { session in
                                SessionDetailView(
                                    sessionId: session.sessionId ?? "",
                                    addCount: Int(session.addCount),
                                    subtractCount: Int(session.subtractCount),
                                    multiplyCount: Int(session.multiplyCount),
                                    divideCount: Int(session.divideCount)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Session Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

}

#Preview("Light Mode") {
    SessionDataView(viewModel: CalculatorViewModel())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SessionDataView(viewModel: CalculatorViewModel())
        .preferredColorScheme(.dark)
}
