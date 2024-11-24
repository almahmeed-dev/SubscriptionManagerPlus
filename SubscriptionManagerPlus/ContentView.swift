import SwiftUI
import CoreData
import Lottie
import EventKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Subscription.nextBillingDate, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<Subscription>
    
    @State private var isAddingSubscription = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Color("AppPrimaryBackground")
                    .edgesIgnoringSafeArea(.all)
                
                Group {
                    if subscriptions.isEmpty {
                        EmptyStateView()
                            .transition(.opacity) // Fades in when displayed
                            .padding(.top, 50)
                    } else {
                        List {
                            Section(header: Text("Your Subscriptions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("AppPrimaryText"))
                                .padding(.bottom, 8)) {
                                    ForEach(subscriptions) { subscription in
                                        SubscriptionRow(subscription: subscription, onAddToCalendar: addToCalendar)
                                    }
                                    .onDelete(perform: deleteItems)
                                }
                        }
                        .listStyle(.plain)
                        .searchable(text: $searchText, prompt: "Search Subscriptions")
                    }
                }
                .navigationTitle("Active Subscriptions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddingSubscription.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color("AppAccentColor"))
                                .font(.title2)
                        }
                        .accessibilityLabel("Add Subscription")
                        .accessibilityHint("Opens a form to add a new subscription")
                        .padding(8)
                        .background(Color("PrimaryButtonBackground"))
                        .clipShape(Circle())
                        .scaleEffect(isAddingSubscription ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isAddingSubscription)
                    }
                }
            }
            .sheet(isPresented: $isAddingSubscription) {
                AddSubscriptionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { subscriptions[$0] }.forEach { subscription in
                cancelNotification(for: subscription)
                viewContext.delete(subscription)
            }
            do {
                try viewContext.save()
            } catch {
                print("Error deleting subscription: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotification(for subscription: Subscription) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [subscription.id?.uuidString ?? ""]
        )
    }
    
    private func addToCalendar(subscription: Subscription) {
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
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    var body: some View {
        VStack {
            LottieView(name: "empty_state_animation", loopMode: .loop)
                .frame(width: 200, height: 200)
                .padding(.bottom, 20)
            Text("No Active Subscriptions")
                .font(.title)
                .foregroundColor(Color("AppSecondaryText"))
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No active subscriptions available")
    }
}

// MARK: - LottieView
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
