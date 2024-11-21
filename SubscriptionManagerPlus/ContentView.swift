//
//  ContentView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Subscription.nextBillingDate, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<Subscription>

    @State private var isAddingSubscription = false
    @State private var searchText = ""
    @State private var filterCriterion = "All"
    private let filterOptions = ["All", "Monthly", "Yearly"]

    var filteredSubscriptions: [Subscription] {
        subscriptions.filter { subscription in
            let matchesSearch = searchText.isEmpty || (subscription.serviceName?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesFilter = filterCriterion == "All" || (subscription.billingCycle ?? "") == filterCriterion
            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $filterCriterion) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Subscription List
                List {
                    ForEach(filteredSubscriptions) { subscription in
                        NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                            VStack(alignment: .leading) {
                                Text(subscription.serviceName ?? "Unknown Service")
                                    .font(.headline)
                                HStack {
                                    Text("$\(subscription.cost, specifier: "%.2f")")
                                    Spacer()
                                    Text(subscription.nextBillingDate ?? Date(), style: .date)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .searchable(text: $searchText, prompt: "Search Subscriptions")
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isAddingSubscription.toggle() }) {
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
