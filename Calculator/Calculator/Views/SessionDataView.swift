//
//  SessionDataView.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import SwiftUI

struct SessionDataView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var sessions: [SessionData] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
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

                    Text("Previous Sessions")
                        .font(.title2)
                        .foregroundColor(.primary)

                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(sessions.filter { $0.sessionId != viewModel.sessionId }) { session in
                                SessionDetailView(
                                    sessionId: session.sessionId,
                                    addCount: session.operations["+", default: 0],
                                    subtractCount: session.operations["−", default: 0],
                                    multiplyCount: session.operations["×", default: 0],
                                    divideCount: session.operations["÷", default: 0]
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
            .onAppear {
                viewModel.fetchAndSyncSessions { fetchedSessions in
                    self.sessions = fetchedSessions
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
