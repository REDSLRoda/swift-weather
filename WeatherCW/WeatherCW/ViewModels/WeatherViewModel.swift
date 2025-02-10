import Foundation

class WeatherViewModel: ObservableObject {
    @Published var locationName: String = "Loading..."
    @Published var temperature: String = "--"
    @Published var feelsLikeTemperature: String = "--"
    @Published var weatherDescription: String = "N/A"
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var dailyForecast: [DailyForecast] = []
    @Published var airQualityScore: Int = 0
    @Published var airQualityLevel: String = "N/A"
    @Published var airQualityDescription: String = "N/A"
    @Published var uvIndex: Int = 0
    @Published var sunriseTime: String = "--:--"
    @Published var sunsetTime: String = "--:--"
    @Published var isLoading: Bool = false
    @Published var selectedDayForecast: DailyForecast? = nil
    @Published var averageTemperature: String = "--" // New field for average temperature
    @Published var humidity: String = "--" // New field for humidity
    @Published var cities: [String] = ["London", "New York", "Tokyo", "Sydney", "Paris"]
    @Published var windSpeed: String = "0"  // Wind speed in km/h
    @Published var windDirection: String = "N"  // Wind direction (e.g. "N", "NE", "E")
    private let apiKey = "2c626ca39982920c91314cd3092f5c6d"

    struct HourlyForecast {
        let time: String
        let icon: String
        let temp: Int
    }

    struct DailyForecast {
        let day: String
        let icon: String
        let tempMin: Int
        let tempMax: Int
        let humidity: Int // Added humidity to DailyForecast
    }

    /// Fetches weather and air quality data for a city.
    func fetchWeather(forCity city: String) async {
        isLoading = true
        
        do {
            // Step 1: Get latitude and longitude for the city
            let geoInfo = try await fetchGeocoding(for: city)
            
            // Step 2: Fetch weather data
            let weatherResponse = try await fetchWeatherData(lat: geoInfo.lat, lon: geoInfo.lon)
            
            // Step 3: Fetch air quality data
            let airQualityResponse = try await fetchAirQualityData(lat: geoInfo.lat, lon: geoInfo.lon)
            
            // Step 4: Update the UI with the fetched data
            updateUI(with: weatherResponse, airQuality: airQualityResponse, cityName: geoInfo.name)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    

    // MARK: - Private Helper Methods
    
    /// Fetches geocoding data to get coordinates for a city.
    private func fetchGeocoding(for city: String) async throws -> GeocodingResponse {
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=1&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let geoResponse = try JSONDecoder().decode([GeocodingResponse].self, from: data)
        guard let geoInfo = geoResponse.first else {
            throw URLError(.badServerResponse)
        }
        return geoInfo
    }

    /// Fetches weather data using latitude and longitude.
    private func fetchWeatherData(lat: Double, lon: Double) async throws -> OpenWeatherOneCallResponse {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(OpenWeatherOneCallResponse.self, from: data)
    }

    /// Fetches air quality data using latitude and longitude.
    private func fetchAirQualityData(lat: Double, lon: Double) async throws -> AirQualityResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AirQualityResponse.self, from: data)
    }

    /// Updates UI with the fetched weather and air quality data.
    private func updateUI(with weather: OpenWeatherOneCallResponse, airQuality: AirQualityResponse, cityName: String) {
        DispatchQueue.main.async {
            self.locationName = cityName
            self.temperature = "\(Int(weather.current.temp))°"
            self.feelsLikeTemperature = "\(Int(weather.current.feels_like))°"
            self.weatherDescription = self.getWeatherCondition(from: weather.current.weather.first?.description ?? "N/A")
            self.uvIndex = weather.current.uvi
            self.sunriseTime = self.formatTime(from: weather.current.sunrise)
            self.sunsetTime = self.formatTime(from: weather.current.sunset)
            self.humidity = "\(Int(weather.current.humidity))%" // Assign current humidity
            
            // Calculate average temperature
            let totalTempMax = weather.daily.reduce(0) { $0 + Int($1.temp.max) }
            let totalTempMin = weather.daily.reduce(0) { $0 + Int($1.temp.min) }
            let averageTemp = (totalTempMax + totalTempMin) / (weather.daily.count * 2)
            self.averageTemperature = "\(averageTemp)°"
            
            // Wind information
            self.windSpeed = "\(Int(weather.current.wind_speed)) km/h"
            self.windDirection = self.getWindDirection(from: weather.current.wind_deg)
            
            self.hourlyForecast = weather.hourly.prefix(10).map {
                HourlyForecast(
                    time: self.formatTime(from: $0.dt),
                    icon: self.mapWeatherIcon(icon: $0.weather.first?.icon ?? ""),
                    temp: Int($0.temp)
                )
            }

            self.dailyForecast = weather.daily.map {
                DailyForecast(
                    day: self.formatDay(from: $0.dt),
                    icon: self.mapWeatherIcon(icon: $0.weather.first?.icon ?? ""),
                    tempMin: Int($0.temp.min),
                    tempMax: Int($0.temp.max),
                    humidity: $0.humidity // Store daily humidity
                )
            }

            if let airQualityData = airQuality.list.first {
                self.airQualityScore = airQualityData.main.aqi
                self.airQualityLevel = self.getAirQualityLevel(from: airQualityData.main.aqi)
                self.airQualityDescription = "Air quality is \(self.airQualityLevel)"
            }

            self.selectedDayForecast = self.dailyForecast.first
        }
    }

    // MARK: - Weather Condition Parsing

    private func getWeatherCondition(from description: String) -> String {
        let descriptionLowercased = description.lowercased()
        
        if descriptionLowercased.contains("clear sky") {
            return "clear sky"
        } else if descriptionLowercased.contains("rain") {
            return "rain"
        } else if descriptionLowercased.contains("snow") {
            return "snow"
        } else if descriptionLowercased.contains("cloud") {
            return "cloudy"
        } else {
            return "unknown"
        }
    }

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

    private func formatTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func formatDay(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func getAirQualityLevel(from aqi: Int) -> String {
        switch aqi {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }
    
    private func getWindDirection(from degree: Double) -> String {
        switch degree {
        case 0..<45, 315..<360: return "N"
        case 45..<135: return "E"
        case 135..<225: return "S"
        case 225..<315: return "W"
        default: return "Unknown"
        }
    }
}

// MARK: - Model Definitions

struct GeocodingResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
}

struct OpenWeatherOneCallResponse: Decodable {
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
    
    struct Current: Decodable {
        let temp: Double
        let feels_like: Double
        let sunrise: TimeInterval
        let sunset: TimeInterval
        let uvi: Int
        let weather: [Weather]
        let humidity: Int // Current humidity
        let wind_speed: Double
        let wind_deg: Double
    }
    
    struct Hourly: Decodable {
        let dt: TimeInterval
        let temp: Double
        let weather: [Weather]
    }
    
    struct Daily: Decodable {
        let dt: TimeInterval
        let temp: Temp
        let weather: [Weather]
        let humidity: Int // Daily humidity
    }
    
    struct Temp: Decodable {
        let min: Double
        let max: Double
    }
    
    struct Weather: Decodable {
        let description: String
        let icon: String
    }
}

struct AirQualityResponse: Decodable {
    struct AirQualityData: Decodable {
        struct Main: Decodable {
            let aqi: Int
        }
        let main: Main
    }
    let list: [AirQualityData]
}
