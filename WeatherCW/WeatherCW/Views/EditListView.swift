import SwiftUI

struct EditListView: View {
    @Binding var cities: [String] // Binding to the cities array
    @State private var cityInput: String = "" // For the input field
    
    var body: some View {
        ZStack {
            BackgroundView(topColor: Color("lightblue"), bottomColor: .blue)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search bar and Add button
                VStack {
                    HStack {
                        TextField("Enter city name", text: $cityInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Add") {
                            addCity(cityInput)
                        }
                        .padding(.trailing)
                    }
                    
                    Button("Fetch Weather") {
                        // This button is not doing anything in this view
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // List of cities with remove button
                List {
                    ForEach(cities, id: \.self) { city in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(city)
                                    .font(.headline)
                            }
                            Spacer()
                            HStack{
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        removeCity(city)
                                    }
                                VStack{
                                    Text("Swipe")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.red)
                                    
                                }
                                
                            }
                            
                        }
                        .padding()
                        .background(gradientBackground(for: city)) // Apply gradient background here
                        .cornerRadius(10)
                    }
                    .onDelete(perform: deleteCity) // Swipe-to-delete
                    .listRowInsets(EdgeInsets()) // Removes default padding
                    .listRowBackground(Color.clear) // Ensures no default background
                }
                .scrollContentBackground(.hidden) // Hides default List background
                .background(Color.blue.opacity(0.2)) // Background color for the entire List
                .listStyle(PlainListStyle()) // Removes separators and default styling
            }
        }
        .navigationTitle("Edit Cities")
    }
    
    // MARK: - Helper Functions
    private func addCity(_ city: String) {
        guard !city.isEmpty, !cities.contains(city) else { return }
        cities.append(city) // Add city to list
        cityInput = ""  // Reset input field
    }
    
    private func removeCity(_ city: String) {
        if let index = cities.firstIndex(of: city) {
            cities.remove(at: index) // Remove city from the list
        }
    }
    
    private func deleteCity(at offsets: IndexSet) {
        withAnimation {
            cities.remove(atOffsets: offsets) // Handle delete swipe action with animation
        }
    }
    
    // MARK: - Gradient Background for List Items
    private func gradientBackground(for city: String) -> LinearGradient {
        // A single gradient for all cities
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    EditListView(cities: .constant(["London", "New York", "Paris"]))
}
