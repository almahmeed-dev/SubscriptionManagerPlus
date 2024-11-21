//
//  SettingsView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("currency") private var selectedCurrency = "USD"
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let currencies = ["USD", "EUR", "BHD", "SAR"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: .constant(true))
                        .disabled(true)
                }

                Section(header: Text("Currency Preferences")) {
                                    Picker("Currency", selection: $selectedCurrency) {
                                        ForEach(currencies, id: \.self) { currency in
                                            Text(currency)
                                        }
                                    }
                                }

                                Section(header: Text("App Theme")) {
                                    Text("Current Theme: \(colorScheme == .dark ? "Dark" : "Light")")
                                }

                                Section(header: Text("About")) {
                                    Text("Subscription Manager Plus")
                                        .font(.headline)
                                    Text("Version 1.0")
                                        .font(.subheadline)
                                    Text("Designed to simplify managing subscriptions and reduce unnecessary costs.")
                                        .font(.body)
                                }
                            }
                            .navigationTitle("Settings")
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }

                #Preview {
                    SettingsView()
                }
