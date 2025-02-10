import SwiftUI

// Onboarding view for showing 5 cities
struct OnboardingView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var currentPage = 0
    let cities = ["London", "New York", "Berlin", "Paris", "Toronto"]
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<cities.count, id: \.self) { index in
                        CityDetailView(city: cities[index])
                            .tag(index)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)  // Ensures full screen usage
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct CityDetailView: View {
    @StateObject private var viewModel = WeatherViewModel()
    let city: String
    
    var body: some View {
        ZStack {
            DynamicBackgroundView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        Text("Weather for \(city)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding(.top, 100.0)
                        
                        // Search Button
                        NavigationLink(destination: WeatherView()) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text(viewModel.locationName)
                                    .font(.system(size: 30))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                                
                                Text(viewModel.temperature)
                                    .font(.system(size: 70, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                                
                                Text(viewModel.weatherDescription)
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                                
                                if let selectedDay = viewModel.selectedDayForecast {
                                    VStack {
                                        HStack {
                                            Text("H: \(selectedDay.tempMax)°")
                                            Text("L: \(selectedDay.tempMin)°")
                                        }
                                        .font(.system(size: 30, weight: .medium))
                                        .foregroundColor(.white)
                                        .shadow(radius: 10)
                                    }
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(viewModel.hourlyForecast, id: \.time) { forecast in
                                        WeatherViewVertical(
                                            timeOfDay: forecast.time,
                                            imageName: forecast.icon,
                                            temperature: forecast.temp
                                        )
                                    }
                                }
                                .padding()
                                .background(Color.blue.gradient.opacity(0.5))
                                .cornerRadius(20)
                            }
                            
                            Divider()
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text("10-Day Forecast".uppercased())
                                    }
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .shadow(radius: 10)
                                    
                                    ForEach(viewModel.dailyForecast, id: \.day) { forecast in
                                        WeatherViewHorizontal(
                                            dayOfWeek: forecast.day,
                                            imageName: forecast.icon,
                                            temperatureEarlier: forecast.tempMin,
                                            temperatureLater: forecast.tempMax
                                        )
                                        Divider().background(Color.white)
                                    }
                                }
                                .padding()
                                .background(Color.blue.gradient.opacity(0.5))
                                .cornerRadius(20)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                uvIndexView(imageName: "sun.max.fill", uvIndex: viewModel.uvIndex)
                                
                                Spacer()
                                
                                sunTrackerView(imageName: "sunset.fill", sunSet: "SUNSET", suSetTime: viewModel.sunsetTime)
                            }
                            HStack{
                                VStack {
                                    HStack {
                                        Image(systemName: "thermometer.low")
                                        Text("Humidity".uppercased())
                                    }
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .shadow(radius: 10)
                                    
                                    // Humidity Section
                                    if let dailyAverageHumidity = viewModel.dailyForecast.map({ $0.humidity }).average() {
                                        HStack {
                                            Text("Humidity")
                                            Text("\(String(format: "%.0f", dailyAverageHumidity))%")
                                        }
                                    }
                                    
                                }
                                .padding()
                                .frame(width: 200,height: 230)
                                .background(Color.blue.gradient.opacity(0.6))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                AirQualityView(
                                    airQualityScore: viewModel.airQualityScore,
                                    airQualityLevel: viewModel.airQualityLevel,
                                    qualityDescription: viewModel.airQualityDescription
                                )
                            }
                            
                            
                            // Precipitation map section
                            VStack {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Precipitation Map".uppercased())
                                }
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .shadow(radius: 10)
                                
                                MapView()
                                    .frame(height: 200)
                                    .cornerRadius(20)
                            }
                            .padding()
                            .background(Color.blue.gradient.opacity(0.5))
                            .cornerRadius(20)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                        Text("Averages".uppercased())
                                    }
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .shadow(radius: 10)
                                    
                                    if let dailyAverageTemperature = viewModel.dailyForecast.map({ $0.tempMax }).average() {
                                        Text("\(String(format: "%.1f", dailyAverageTemperature))°")
                                            .font(.system(size: 40, weight: .semibold))
                                    }
                                    
                                    Text("above or below daily high average")
                                    
                                    if let selectedDay = viewModel.selectedDayForecast {
                                        VStack{
                                            
                                            HStack {
                                                Text("Today")
                                                Text("H: \(selectedDay.tempMax)°")
                                            }
                                            HStack {
                                                Text("Average")
                                                Text("H: \(selectedDay.tempMax)°")
                                            }
                                            
                                        }
                                    }
                                    
                                    
                                }
                                .padding()
                                .background(Color.blue.gradient.opacity(0.5))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                
                                
                                
                                FeelsLikeView(feelsLikeTemperature: viewModel.feelsLikeTemperature)
                            }
                            HStack {
                                WindSpeedView(windSpeed: viewModel.windSpeed, windDirection: viewModel.windDirection)
                                    .padding()
                                
                                Spacer()
                                
                                // You can also display other components like AirQualityView, FeelsLikeView, etc.
                            }
                            
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            
        }
        .onAppear {
            Task {
                await viewModel.fetchWeather(forCity: city)
            }
        }
    }
}

extension Collection where Element: Numeric {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        let sum = self.reduce(0, { $0 + Double("\($1)")! })
        return sum / Double(count)
    }
}

#Preview {
    OnboardingView()
}
