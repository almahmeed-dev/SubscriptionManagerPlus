//
//  DataLoader.swift
//  SubscriptionManagerPlus
//
//  Created by Mubarak Almahmeed on 19/11/2024.
//

import Foundation

class DataLoader {
    static func loadCompanies() -> [Company] {
        guard let url = Bundle.main.url(forResource: "revised_companies", withExtension: "json") else {
            print("Error: JSON file not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let companies = try JSONDecoder().decode([Company].self, from: data)
            return companies
        } catch {
            print("Error loading or decoding JSON: \(error.localizedDescription)")
            return []
        }
    }
}
