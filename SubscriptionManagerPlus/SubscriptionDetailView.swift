//
//  SubscriptionDetailView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import EventKit

struct SubscriptionDetailView: View {
    let subscription: Subscription
    
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
            
            Spacer()
            
            Button(action: { addToCalendar(subscription: subscription) }) {
                Text("Add to Calendar")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .navigationTitle("Details")
    }
    
    private func addToCalendar(subscription: Subscription) {
        let eventStore = EKEventStore()
        
        // Ensure a valid next billing date exists
        guard let billingDate = subscription.nextBillingDate else {
            print("No billing date found for this subscription.")
            return
        }
        
        // Request full access to the calendar
        eventStore.requestFullAccessToEvents { granted, error in
            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = "\(subscription.serviceName ?? "Subscription") Billing Date"
                    event.startDate = billingDate
                    event.endDate = billingDate.addingTimeInterval(3600) // 1-hour event duration
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    // Add an alarm 1 day before
                    event.addAlarm(EKAlarm(relativeOffset: -86400)) // 1 day before
                    
                    do {
                        try eventStore.save(event, span: .thisEvent)
                        print("Event added to calendar successfully!")
                    } catch {
                        print("Error saving event: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Calendar access not granted.")
            }
        }
    }
}
