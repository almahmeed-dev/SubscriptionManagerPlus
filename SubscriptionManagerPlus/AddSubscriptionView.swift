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
    @State private var cost = ""
    @State private var billingCycle = "Monthly"
    @State private var nextBillingDate = Date()
    @State private var reminder = false
    @State private var notes = ""

    private let billingCycles = ["Monthly", "Yearly"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Service Name", text: $serviceName)
                TextField("Cost", text: $cost)
                    .keyboardType(.decimalPad)
                Picker("Billing Cycle", selection: $billingCycle) {
                    ForEach(billingCycles, id: \.self) { cycle in
                        Text(cycle)
                    }
                }
                DatePicker("Next Billing Date", selection: $nextBillingDate, displayedComponents: .date)
                Toggle("Set Reminder", isOn: $reminder)
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
            .navigationTitle(editingSubscription == nil ? "Add Subscription" : "Edit Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                }
            }
        }
        .onAppear {
            // Pre-fill fields if editing
            if let subscription = editingSubscription {
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
        guard !serviceName.isEmpty, let costValue = Double(cost) else { return }

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
}

#Preview {
    AddSubscriptionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
