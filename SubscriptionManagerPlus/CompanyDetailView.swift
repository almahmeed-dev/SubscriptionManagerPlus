//
//  CompanyDetailView.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 18/11/2024.
//

import SwiftUI

struct CompanyDetailView: View {
    let company: Company

    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: company.logoURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }

            Text(company.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(company.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Link("Visit Website", destination: URL(string: company.websiteURL)!)
                .font(.headline)
                .foregroundColor(.blue)

            Link("Cancellation Guide", destination: URL(string: company.cancellationGuideURL)!)
                .font(.headline)
                .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .navigationTitle(company.name)
    }
}

#Preview {
    let sampleCompany = Company(
        name: "Netflix",
        websiteURL: "https://www.netflix.com",
        hexColor: "#E50914",
        description: "Netflix is a streaming platform for movies and TV shows.",
        category: "Streaming",
        cancellationGuideURL: "https://www.netflix.com/cancel",
        logoURL: "https://logo.clearbit.com/netflix.com"
    )

    return NavigationStack {
        CompanyDetailView(company: sampleCompany)
    }
}
