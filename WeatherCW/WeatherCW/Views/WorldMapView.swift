import SwiftUI
import MapKit

struct TouristLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct WorldMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 80, longitudeDelta: 80)
    )
    @State private var selectedCity: String? = nil
    @State private var newCityName: String = ""
    @State private var locations: [TouristLocation] = [
        TouristLocation(name: "London", coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)),
        TouristLocation(name: "New York", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)),
        TouristLocation(name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)),
        TouristLocation(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)),
        TouristLocation(name: "Berlin", coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)),
        TouristLocation(name: "Moscow", coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)),
        TouristLocation(name: "Toronto", coordinate: CLLocationCoordinate2D(latitude: 43.6511, longitude: -79.3837))
    ]
    @State private var showLocationNotFoundAlert = false
    @State private var locationNotFoundMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Button(action: {
                                selectedCity = location.name
                            }) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                            }
                            Text(location.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(5)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    // Optional Overlay UI
                    VStack {
                        Text("Famous Tourist Locations")
                            .font(.headline)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .padding()

                        HStack {
                            TextField("Enter new city", text: $newCityName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            Button("Add") {
                                addCity()
                            }
                            .padding()
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(width: 80, height: 80)
                        }
                        .padding(.bottom)
                    }
                }

                // Navigation Link to CityDetailView
                NavigationLink(
                    destination: selectedCity.map { CityDetailView(city: $0) },
                    tag: selectedCity ?? "",
                    selection: $selectedCity
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("World Map")
            .alert(isPresented: $showLocationNotFoundAlert) {
                Alert(
                    title: Text("Location Not Found"),
                    message: Text(locationNotFoundMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func addCity() {
        guard !newCityName.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(newCityName) { (placemarks, error) in
            if let error = error {
                // Handle geocoding errors (e.g., network issues)
                print("Error during geocoding: \(error.localizedDescription)")
                locationNotFoundMessage = "The location '\(newCityName)' could not be found due to an error. Please try again."
                showLocationNotFoundAlert = true
                return
            }
            
            guard let placemark = placemarks?.first,
                  let locationName = placemark.locality ?? placemark.administrativeArea ?? placemark.name else {
                // No meaningful location data was found
                locationNotFoundMessage = "The location '\(newCityName)' does not exist. Please try a different name."
                showLocationNotFoundAlert = true
                return
            }
            
            // Check if location already exists in the list
            if locations.contains(where: { $0.name.lowercased() == locationName.lowercased() }) {
                locationNotFoundMessage = "The location '\(locationName)' already exists in the list."
                showLocationNotFoundAlert = true
                return
            }
            
            // Proceed with adding the location
            let newLocation = TouristLocation(
                name: locationName,
                coordinate: placemark.location!.coordinate
            )
            locations.append(newLocation)
            newCityName = ""  // Reset the input field
        }
    }

}



#Preview {
    WorldMapView()
}
