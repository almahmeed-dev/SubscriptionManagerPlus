//
//  AddSubscriptionView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import UserNotifications

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
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.green.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Animated header
                    Text(editingSubscription == nil ? "Add Subscription" : "Edit Subscription")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .transition(.opacity)
                        .animation(.easeInOut, value: editingSubscription)

                    // Main form
                    Form {
                        // Subscription details
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
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 4)

                            TextField("Cost", text: $cost)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 4)

                            Picker("Billing Cycle", selection: $billingCycle) {
                                ForEach(billingCycles, id: \.self) { cycle in
                                    Text(cycle)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        // Notification options
                        Section(header: Text("Notification Reminder")) {
                            Toggle("Enable Reminder", isOn: $reminder)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 4)

                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        }
                    }
                    .scrollContentBackground(.hidden) // Removes default form background
                    .background(Color.clear)
                    .padding()
                }
                .padding()
            }
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

        // Schedule a notification if reminder is enabled
        if reminder {
            scheduleNotification(for: subscription)
        }

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

    private func scheduleNotification(for subscription: Subscription) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Billing Reminder"

        // Create a date formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        // Format the billing date
        let formattedDate = subscription.nextBillingDate.map { formatter.string(from: $0) } ?? "Unknown date"
        content.body = "\(subscription.serviceName ?? "Subscription") is due on \(formattedDate)."
        content.sound = .default

        guard let billingDate = subscription.nextBillingDate else { return }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: billingDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: subscription.id?.uuidString ?? UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(subscription.serviceName ?? "Subscription").")
            }
        }
    }
}
