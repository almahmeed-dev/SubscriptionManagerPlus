//
//  SubscriptionDetailView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import CoreData
import EventKit

struct SubscriptionDetailView: View {
    let subscription: Subscription
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(subscription.serviceName ?? "Unknown Service")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Cost: $\(subscription.cost, specifier: "%.2f")")
                .font(.headline)
            
            Text("Billing Cycle: \(subscription.billingCycle ?? "Unknown")")
                .font(.subheadline)
            
            Text("Next Billing Date: \(subscription.nextBillingDate ?? Date(), style: .date)")
                .font(.subheadline)
            
            if let notes = subscription.notes, !notes.isEmpty {
                Text("Notes:")
                    .font(.headline)
                Text(notes)
                    .font(.body)
            }
            
            Spacer()
            
            // Button alignment fix
            VStack(spacing: 16) {
                Button(action: {
                    addToCalendar(subscription: subscription)
                }) {
                    Text("Add to Calendar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                }
                
                NavigationLink(destination: CancellationGuideView()) {
                    Text("How to Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddSubscriptionView(editingSubscription: subscription)
        }
    }
    
    private func addToCalendar(subscription: Subscription) {
        let eventStore = EKEventStore()
        guard let billingDate = subscription.nextBillingDate else { return }
        
        eventStore.requestFullAccessToEvents { granted, error in
            if granted {
                let event = EKEvent(eventStore: eventStore)
                event.title = "\(subscription.serviceName ?? "Subscription") Billing Date"
                event.startDate = billingDate
                event.endDate = billingDate.addingTimeInterval(3600) // 1-hour duration
                event.calendar = eventStore.defaultCalendarForNewEvents
                // Add an alarm 1 day before the event
                event.addAlarm(EKAlarm(relativeOffset: -86400)) // 1 day before (in seconds)
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event added to calendar")
                } catch {
                    print("Error saving event: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Error requesting access: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleSubscription = Subscription(context: context)
    sampleSubscription.id = UUID()
    sampleSubscription.serviceName = "Sample Service"
    sampleSubscription.cost = 9.99
    sampleSubscription.billingCycle = "Monthly"
    sampleSubscription.nextBillingDate = Date()
    sampleSubscription.reminder = true
    sampleSubscription.notes = "Sample notes for the subscription."
    
    return NavigationStack {
        SubscriptionDetailView(subscription: sampleSubscription)
    }
}
