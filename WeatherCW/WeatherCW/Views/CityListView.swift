import SwiftUI

struct CityListView: View {
    @State private var cityInput: String = "London"
    @State private var cities = ["London", "New York", "Berlin", "Paris", "Toronto"]
    @StateObject private var weatherFetcher = WeatherFetcher()

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(topColor: Color("lightblue"), bottomColor: .blue)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Search bar and Edit button
                    HStack {
                        TextField("Enter city name", text: $cityInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        NavigationLink(destination: EditListView(cities: $cities)) {
                            Text("Edit")
                                .frame(width: 60, height: 30)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    VStack {
                        List(weatherFetcher.cityWeatherList) { weather in
                            NavigationLink(destination: CityDetailView(city: weather.cityName)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(weather.cityName)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(weather.weatherDescription.capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Text("\(Int(weather.temperature))°C")
                                        .font(.body)
                                        .foregroundColor(.white)

                                    Image(systemName: weather.icon)
                                        .resizable()
                                        .renderingMode(.original)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 80)
                                }
                                .padding(.vertical, 10)
                                .background(gradientBackground(for: weather.weatherDescription))
                                .cornerRadius(10)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(PlainListStyle())
                        .onAppear {
                            weatherFetcher.fetchWeather(for: cities)
                        }
                    }
                    .navigationTitle("Major Cities Weather")
                }
            }
        }
    }

    // Determine the gradient background based on the weather description
    private func gradientBackground(for description: String) -> LinearGradient {
        let lowercasedDescription = description.lowercased()
        if lowercasedDescription.contains("clear") {
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lowercasedDescription.contains("rain") {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing

            )
        } else if lowercasedDescription.contains("snow") {
            return LinearGradient(
                gradient: Gradient(colors: [Color.cyan, Color.blue.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing

            )
        } else if lowercasedDescription.contains("cloud") {
            return LinearGradient(
                gradient: Gradient(colors: [Color.cyan, Color.gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    CityListView()
}
