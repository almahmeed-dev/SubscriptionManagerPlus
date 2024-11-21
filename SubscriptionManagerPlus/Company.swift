//
//  Company.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 19/11/2024.
//

import Foundation

struct Company: Identifiable, Codable {
    var id = UUID() // Auto-generate unique IDs
    let name: String
    let websiteURL: String
    let hexColor: String
    let description: String
    let category: String
    let cancellationGuideURL: String
    let logoURL: String
}
