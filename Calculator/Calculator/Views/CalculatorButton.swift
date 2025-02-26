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

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .frame(width: 80, height: 80)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(40)
        }
    }

}

// MARK: Previews
#Preview("Light Mode") {
    CalculatorButton(title: <#T##String#>, action: <#T##() -> Void#>)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CalculatorButton(title: <#T##String#>, action: <#T##() -> Void#>)
        .preferredColorScheme(.dark)
}
