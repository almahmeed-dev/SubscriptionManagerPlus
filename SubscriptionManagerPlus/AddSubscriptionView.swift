//
//  AddSubscriptionView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var editingSubscription: Subscription? // Optional for editing mode

    @State private var serviceName = ""
    @State private var selectedCompany: Company? // New state for selected company
    @State private var cost = ""
    @State private var billingCycle = "Monthly"
    @State private var nextBillingDate = Date()
    @State private var reminder = false
    @State private var notes = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    private let billingCycles = ["Monthly", "Yearly"]

    var body: some View {
        NavigationStack {
            Form {
                // Section for subscription details
                Section(header: Text("Subscription Details")) {
                    NavigationLink(destination: CompanyListView(onCompanySelected: { company in
                        selectedCompany = company
                        serviceName = company.name // Automatically set the service name
                    })) {
                        HStack {
                            Text("Select Company")
                                .foregroundColor(.blue)
                            Spacer()
                            if let company = selectedCompany {
                                Text(company.name)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    TextField("Service Name", text: $serviceName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(billingCycles, id: \.self) { cycle in
                            Text(cycle)
                        }
                    }
                    DatePicker("Next Billing Date", selection: $nextBillingDate, displayedComponents: .date)
                }

                // Section for additional options
                Section(header: Text("Additional Options")) {
                    Toggle("Set Reminder", isOn: $reminder)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                }
            }
            .navigationTitle(editingSubscription == nil ? "Add Subscription" : "Edit Subscription")
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            if let subscription = editingSubscription {
                // Pre-fill fields if editing
                serviceName = subscription.serviceName ?? ""
                cost = String(subscription.cost)
                billingCycle = subscription.billingCycle ?? "Monthly"
                nextBillingDate = subscription.nextBillingDate ?? Date()
                reminder = subscription.reminder
                notes = subscription.notes ?? ""
            }
        }
    }

    private func saveSubscription() {
        guard !serviceName.isEmpty else {
            showAlert(message: "Service name cannot be empty.")
            return
        }

        guard let costValue = Double(cost), costValue > 0 else {
            showAlert(message: "Please enter a valid cost greater than 0.")
            return
        }

        let subscription = editingSubscription ?? Subscription(context: viewContext)
        subscription.id = subscription.id ?? UUID() // Retain the same ID for edits
        subscription.serviceName = serviceName
        subscription.cost = costValue
        subscription.billingCycle = billingCycle
        subscription.nextBillingDate = nextBillingDate
        subscription.reminder = reminder
        subscription.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    AddSubscriptionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
