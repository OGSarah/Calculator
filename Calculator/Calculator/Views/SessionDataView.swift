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
    @State private var isLoading = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SessionDetailView(
                        title: "Current Session",
                        session: viewModel.getCurrentSessionData(),
                        dateFormatter: dateFormatter,
                        isCurrent: true
                    )
                    .listRowBackground(Color(.systemBackground))
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                Section(header: Text("Previous Sessions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .listRowBackground(Color(.systemBackground))
                        } else if sessions.filter({ $0.sessionId != viewModel.sessionId }).isEmpty {
                            ContentUnavailableView {
                                Label("No Previous Sessions", systemImage: "timer")
                            } description: {
                                Text("Previous sessions you have created will appear here.")
                            }
                        } else {
                            ForEach(sessions.filter { $0.sessionId != viewModel.sessionId }) { session in
                                SessionDetailView(
                                    title: "Session",
                                    session: session,
                                    dateFormatter: dateFormatter,
                                    isCurrent: false
                                )
                                .transition(.opacity)
                            }
                            .listRowBackground(Color(.systemBackground))
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        }
                    }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calculator Session History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                withAnimation {
                    isLoading = true
                }
                let coreDataSessions = viewModel.getAllSessions()
                let convertedSessions = coreDataSessions.map { entity in
                    SessionData(
                        sessionId: entity.sessionId ?? String(),
                        addCount: Int(entity.addCount),
                        subtractCount: Int(entity.subtractCount),
                        multiplyCount: Int(entity.multiplyCount),
                        divideCount: Int(entity.divideCount),
                        lastUpdated: entity.lastUpdated ?? Date()
                    )
                }
                withAnimation(.easeInOut) {
                    self.sessions = convertedSessions
                    self.isLoading = false
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
