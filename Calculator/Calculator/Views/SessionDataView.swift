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
                        addCount: viewModel.getCurrentSessionData().addCount,
                        subtractCount: viewModel.getCurrentSessionData().subtractCount,
                        multiplyCount: viewModel.getCurrentSessionData().multiplyCount,
                        divideCount: viewModel.getCurrentSessionData().divideCount,
                        lastUpdated: viewModel.getCurrentSessionData().lastUpdated
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
                                    addCount: session.addCount,
                                    subtractCount: session.subtractCount,
                                    multiplyCount: session.multiplyCount,
                                    divideCount: session.divideCount,
                                    lastUpdated: session.lastUpdated
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
