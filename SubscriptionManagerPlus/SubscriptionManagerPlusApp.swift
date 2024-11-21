//
//  SubscriptionManagerPlusApp.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI
import UserNotifications
import EventKit

@main
struct SubscriptionManagerPlusApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        requestNotificationPermissions()
        requestCalendarAccess()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            } else {
                print("Notification permissions granted: \(granted)")
            }
        }
    }
    func requestCalendarAccess() {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { granted, error in
            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
            } else {
                print("Calendar access granted: \(granted)")
            }
        }
    }
}
