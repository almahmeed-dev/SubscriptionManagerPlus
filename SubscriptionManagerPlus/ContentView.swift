//
//  ContentView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import CoreData
import Lottie

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Subscription.nextBillingDate, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<Subscription>

    @State private var isAddingSubscription = false
    @State private var searchText = ""
    @State private var filterCriterion = "All"
    @State private var costFilter: Double = 0.0 // New state for cost filter
    private let filterOptions = ["All", "Monthly", "Yearly"]

    var filteredSubscriptions: [Subscription] {
        subscriptions.filter { subscription in
            let matchesSearch = searchText.isEmpty || (subscription.serviceName?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesFilter = filterCriterion == "All" || (subscription.billingCycle ?? "") == filterCriterion
            let matchesCost = costFilter == 0.0 || subscription.cost <= costFilter
            return matchesSearch && matchesFilter && matchesCost
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Filter Picker
                Picker("Filter by Billing Cycle", selection: $filterCriterion) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Cost Slider
                HStack {
                    Text("Filter by Cost: $\(Int(costFilter))")
                    Slider(value: $costFilter, in: 0...100, step: 5)
                }
                .padding(.horizontal)

                // Subscription List or Empty State
                Group {
                    if filteredSubscriptions.isEmpty {
                        EmptyStateView() // Lottie animation for empty state
                            .padding(.top, 50)
                    } else {
                        List {
                            ForEach(filteredSubscriptions) { subscription in
                                NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                                    VStack(alignment: .leading) {
                                        Text(subscription.serviceName ?? "Unknown Service")
                                            .font(.headline)
                                            .transition(.slide)
                                            .animation(.easeInOut, value: filteredSubscriptions)
                                        HStack {
                                            Text("$\(subscription.cost, specifier: "%.2f")")
                                            Spacer()
                                            Text(subscription.nextBillingDate ?? Date(), style: .date)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground).opacity(0.9))
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search Subscriptions")
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddingSubscription.toggle()
                            let generator = UIImpactFeedbackGenerator(style: .medium) // Haptic feedback
                            generator.impactOccurred()
                        }) {
                            Label("Add Subscription", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                        }
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
            let generator = UINotificationFeedbackGenerator() // Haptic feedback
            generator.notificationOccurred(.success)

            offsets.map { subscriptions[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// MARK: - Empty State View with Lottie Animation
struct EmptyStateView: View {
    var body: some View {
        VStack {
            LottieView(name: "empty_state_animation", loopMode: .loop) // Replace with your Lottie animation file
                .frame(width: 200, height: 200)
            Text("No Subscriptions Found")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - LottieView Component
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
