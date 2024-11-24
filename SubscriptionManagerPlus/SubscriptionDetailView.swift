import SwiftUI
import EventKit

struct SubscriptionDetailView: View {
    let subscription: Subscription
    
    var body: some View {
        ZStack {
            // Background color
            Color("AppPrimaryBackground")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 16) {
                subscriptionDetails
                
                Spacer()
                
                actionButtons
            }
            .padding()
            .navigationTitle("Details")
        }
    }
    
    // MARK: - Subscription Details Section
    private var subscriptionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(subscription.serviceName ?? "Unknown Service")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("AppPrimaryText"))
            
            Text("Cost: $\(subscription.cost, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(Color("AppSecondaryText"))
            
            Text("Billing Cycle: \(subscription.billingCycle ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(Color("AppSecondaryText"))
            
            Text("Next Billing Date: \(subscription.nextBillingDate ?? Date(), style: .date)")
                .font(.subheadline)
                .foregroundColor(Color("AppSecondaryText"))
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                addToCalendar()
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title3)
                    Text("Add to Calendar")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("PrimaryButtonBackground"))
                .foregroundColor(Color("PrimaryButtonText"))
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Add to Calendar")
            .accessibilityHint("Adds the next billing date to your calendar")
            
            Button(action: {
                deleteSubscription()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("Delete Subscription")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("AppErrorColor"))
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: Color.red.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Delete Subscription")
            .accessibilityHint("Deletes this subscription")
        }
    }
    
    // MARK: - Add to Calendar Functionality
    private func addToCalendar() {
        guard let billingDate = subscription.nextBillingDate else {
            showAlert(title: "Error", message: "No billing date found for this subscription.")
            return
        }
        
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { granted, error in
            if let error = error {
                DispatchQueue.main.async {
                    showAlert(title: "Error", message: "Failed to access calendar: \(error.localizedDescription)")
                }
                return
            }
            
            guard granted else {
                DispatchQueue.main.async {
                    showAlert(title: "Permission Denied", message: "Calendar access is not enabled.")
                }
                return
            }
            
            DispatchQueue.main.async {
                let event = EKEvent(eventStore: eventStore)
                event.title = "\(subscription.serviceName ?? "Subscription") Billing Reminder"
                event.startDate = billingDate
                event.endDate = billingDate.addingTimeInterval(3600) // 1 hour duration
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    showAlert(title: "Success", message: "The billing date was added to your calendar.")
                } catch {
                    showAlert(title: "Error", message: "Failed to save the event: \(error.localizedDescription)")
                }
            }
        }
    }
    // MARK: - Delete Subscription
    private func deleteSubscription() {
        // Add your Core Data delete logic here
        print("Subscription deleted.")
    }
    
    // MARK: - Show Alert Function
    private func showAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("Unable to find the key window to present alert.")
            return
        }
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        keyWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    struct SubscriptionDetailView_Previews: PreviewProvider {
        static var previews: some View {
            let sampleSubscription = Subscription(context: PersistenceController.preview.container.viewContext)
            sampleSubscription.serviceName = "Netflix"
            sampleSubscription.cost = 9.99
            sampleSubscription.billingCycle = "Monthly"
            sampleSubscription.nextBillingDate = Date()
            
            return NavigationStack {
                SubscriptionDetailView(subscription: sampleSubscription)
            }
        }
    }
}
