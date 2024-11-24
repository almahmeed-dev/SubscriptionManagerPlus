//
//  SubscriptionRow.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 23/11/2024.
//

import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription
    let onAddToCalendar: (Subscription) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.serviceName ?? "Unknown Service")
                    .font(.headline)
                    .foregroundColor(Color("AppPrimaryText"))
                Text(String(format: "$%.2f", subscription.cost))
                    .font(.subheadline)
                    .foregroundColor(Color("AppSecondaryText"))
            }
            Spacer()
            Text(subscription.nextBillingDate ?? Date(), style: .date)
                .font(.subheadline)
                .foregroundColor(Color("AppSecondaryText"))
            Button(action: {
                onAddToCalendar(subscription)
            }) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title3)
                    .foregroundColor(Color("AppAccentColor"))
            }
            .accessibilityLabel("Add to Calendar")
            .accessibilityHint("Adds the next billing date to your calendar")
        }
        .padding()
        .background(Color("AppSecondaryBackground"))
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}
