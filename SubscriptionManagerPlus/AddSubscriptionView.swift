import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State var serviceName: String = ""
    @State var cost: String = ""
    @State var nextBillingDate: Date = Date()
    @State var notes: String = ""
    @State var isEditing: Bool = false // Indicates if we're editing an existing subscription

    // Subscription being edited (if any)
    var subscriptionToEdit: Subscription?

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Service Details Section
                    Section(header: Text("Service Details").foregroundColor(Color("AppPrimaryText"))) {
                        TextField("Service Name", text: $serviceName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(Color("AppPrimaryText"))
                            .accessibilityLabel("Service Name")
                            .accessibilityHint("Enter the name of the subscription service")

                        TextField("Cost", text: $cost)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(Color("AppPrimaryText"))
                            .accessibilityLabel("Cost")
                            .accessibilityHint("Enter the cost in dollars, e.g., 9.99")
                            .onChange(of: cost) { oldValue, newValue in
                                cost = newValue.filter { "0123456789.".contains($0) }
                            }


                        DatePicker("Next Billing Date", selection: $nextBillingDate, in: Date()..., displayedComponents: .date)
                            .foregroundColor(Color("AppPrimaryText"))
                            .accessibilityLabel("Next Billing Date")
                            .accessibilityHint("Select the next billing date")
                    }

                    // Additional Notes Section
                    Section(header: Text("Additional Notes").foregroundColor(Color("AppPrimaryText"))) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .cornerRadius(8)
                            .foregroundColor(Color("AppPrimaryText"))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("AppSecondaryText"), lineWidth: 1))
                            .accessibilityLabel("Additional Notes")
                            .accessibilityHint("Enter any additional information about the subscription")
                    }
                }
                .background(Color("AppPrimaryBackground"))
                .scrollContentBackground(.hidden)

                Spacer()

                // Save Button
                Button(action: {
                    validateAndSave()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryButtonBackground"))
                        .foregroundColor(Color("PrimaryButtonText"))
                        .cornerRadius(10)
                        .shadow(color: Color("AppSecondaryBackground").opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .accessibilityLabel("Save Subscription")
                .accessibilityHint("Saves the subscription details")
                .disabled(serviceName.isEmpty || cost.isEmpty)
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "Add Subscription")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismisses the form without saving")
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // Pre-fill fields if editing an existing subscription
                if let subscription = subscriptionToEdit {
                    serviceName = subscription.serviceName ?? ""
                    cost = String(subscription.cost)
                    nextBillingDate = subscription.nextBillingDate ?? Date()
                    notes = subscription.notes ?? ""
                    isEditing = true
                }
            }
        }
    }

    private func validateAndSave() {
        // Ensure cost and nextBillingDate are valid
        guard let costValue = Double(cost), costValue > 0 else {
            alertMessage = "Please enter a valid cost greater than 0."
            showAlert = true
            return
        }

        if nextBillingDate < Date() {
            alertMessage = "Next billing date cannot be in the past."
            showAlert = true
            return
        }

        saveSubscription()
    }

    private func saveSubscription() {
        if let subscription = subscriptionToEdit {
            // Update existing subscription
            subscription.serviceName = serviceName
            subscription.cost = Double(cost) ?? 0.0
            subscription.nextBillingDate = nextBillingDate
            subscription.notes = notes
        } else {
            // Create a new subscription
            let newSubscription = Subscription(context: viewContext)
            newSubscription.id = UUID()
            newSubscription.serviceName = serviceName
            newSubscription.cost = Double(cost) ?? 0.0
            newSubscription.nextBillingDate = nextBillingDate
            newSubscription.notes = notes
        }

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving subscription: \(error.localizedDescription)")
        }
    }
}

struct AddSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubscriptionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
