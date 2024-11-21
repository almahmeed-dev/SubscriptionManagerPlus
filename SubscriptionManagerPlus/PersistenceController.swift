//
//  PersistenceController.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newSubscription = Subscription(context: viewContext)
            newSubscription.id = UUID()
            newSubscription.serviceName = "Service \(i)"
            newSubscription.cost = Double(i + 1) * 9.99
            newSubscription.billingCycle = "Monthly"
            newSubscription.nextBillingDate = Calendar.current.date(byAdding: .day, value: i * 30, to: Date())
            newSubscription.reminder = i % 2 == 0
            newSubscription.notes = "Sample notes for Service \(i)."
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
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
