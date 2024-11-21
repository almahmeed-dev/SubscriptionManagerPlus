//
//  CancellationGuideView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on [Today's Date].
//

import SwiftUI

struct CancellationGuideView: View {
    var body: some View {
        List {
            Section(header: Text("General Cancellation Steps")) {
                Text("1. Log in to the service's website or app.")
                Text("2. Go to the account or subscription settings.")
                Text("3. Find the 'Cancel Subscription' option.")
                Text("4. Follow the on-screen instructions.")
                Text("5. Save any cancellation confirmation emails.")
            }

            Section(header: Text("Service-Specific Links")) {
                Link("Netflix Cancellation Guide", destination: URL(string: "https://www.netflix.com/cancel")!)
                Link("Spotify Cancellation Guide", destination: URL(string: "https://support.spotify.com/cancel")!)
                Link("Hulu Cancellation Guide", destination: URL(string: "https://help.hulu.com/cancel")!)
                Link("Amazon Prime Cancellation Guide", destination: URL(string: "https://www.amazon.com/cancelprime")!)
            }
        }
        .navigationTitle("Cancellation Guide")
    }
}

#Preview {
    NavigationStack {
        CancellationGuideView()
    }
}
