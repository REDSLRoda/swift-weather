import Foundation

class WeatherFetcher: ObservableObject {
    @Published var cityWeatherList: [CityWeather] = []

    private let apiKey = "2c626ca39982920c91314cd3092f5c6d" // Replace with your actual API key

    struct CityWeather: Identifiable {
        let id = UUID()
        let cityName: String
        let temperature: Double
        let weatherDescription: String
        let icon: String
    }

    // Fetch weather data for a list of cities
    func fetchWeather(for cities: [String]) {
        cityWeatherList.removeAll() // Clear the list before fetching new data
        for city in cities {
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric") else { continue }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    do {
                        let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.cityWeatherList.append(CityWeather(
                                cityName: city,
                                temperature: weatherData.main.temp,
                                weatherDescription: weatherData.weather.first?.description ?? "No Description",
                                icon: self.mapWeatherIcon(icon: weatherData.weather.first?.icon ?? "")
                            ))
                        }
                    } catch {
                        print("Error decoding data: \(error)")
                    }
                }
            }
            task.resume()
        }
    }

    // Map the weather icon to a system image name
    private func mapWeatherIcon(icon: String) -> String {
        switch icon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d", "10n": return "cloud.sun.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
}

// Weather API Response Model
struct WeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
}
