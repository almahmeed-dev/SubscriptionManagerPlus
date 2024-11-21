//
//  SettingsView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("globalNotificationsEnabled") private var globalNotificationsEnabled = true
    @AppStorage("defaultBillingCycle") private var defaultBillingCycle = "Monthly"

    private let billingCycles = ["Monthly", "Yearly"]

    var body: some View {
        NavigationStack {
            Form {
                // Notification Settings
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $globalNotificationsEnabled)
                }

                // Default Values
                Section(header: Text("Defaults")) {
                    Picker("Default Billing Cycle", selection: $defaultBillingCycle) {
                        ForEach(billingCycles, id: \.self) { cycle in
                            Text(cycle)
                        }
                    }
                }

                // Links
                Section(header: Text("App Info")) {
                    Link("Privacy Policy", destination: URL(string: "https://www.example.com/privacy")!)
                    Link("Support", destination: URL(string: "https://www.example.com/support")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
