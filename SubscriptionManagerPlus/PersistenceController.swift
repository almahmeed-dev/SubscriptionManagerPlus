//
//  PersistenceController.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Provide a preview instance for SwiftUI Previews
    @MainActor
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample data for preview
        for i in 0..<10 {
            let newSubscription = Subscription(context: viewContext)
            newSubscription.id = UUID()
            newSubscription.serviceName = "Sample Service \(i)"
            newSubscription.cost = Double(i) * 9.99
            newSubscription.billingCycle = i % 2 == 0 ? "Monthly" : "Yearly"
            newSubscription.nextBillingDate = Calendar.current.date(byAdding: .day, value: i, to: Date())
            newSubscription.reminder = i % 2 == 0
            newSubscription.notes = "Sample notes for subscription \(i)."
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SubscriptionManagerPlus")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
