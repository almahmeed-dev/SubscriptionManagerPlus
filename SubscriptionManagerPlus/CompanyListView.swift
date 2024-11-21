import SwiftUI

struct CompanyListView: View {
    let onCompanySelected: (Company) -> Void // Closure to handle company selection
    @State private var companies: [Company] = []
    @State private var searchText = ""

    var filteredCompanies: [Company] {
        companies.filter { company in
            searchText.isEmpty || company.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCompanies) { company in
                Button(action: {
                    onCompanySelected(company)
                }) {
                    HStack {
                        AsyncImage(url: URL(string: company.logoURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .leading) {
                            Text(company.name)
                                .font(.headline)
                            Text(company.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Companies")
            .navigationTitle("Select a Company")
            .onAppear {
                loadCompanies()
            }
        }
    }

    private func loadCompanies() {
        guard let url = Bundle.main.url(forResource: "revised_companies", withExtension: "json") else {
            print("Error: JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            companies = try JSONDecoder().decode([Company].self, from: data)
        } catch {
            print("Error loading companies: \(error.localizedDescription)")
        }
    }
}
