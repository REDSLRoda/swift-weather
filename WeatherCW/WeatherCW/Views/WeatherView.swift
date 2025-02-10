// WeatherView.swift
// WeatherCW
//
// Created by Achintha on 2025-01-01.
//

import SwiftUI
import MapKit

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityInput: String = "London"
    
    var body: some View {
        ZStack {
            // Add DynamicBackgroundView here
            DynamicBackgroundView(viewModel: viewModel)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Search bar and fetch button
                    VStack {
                        TextField("Enter city name", text: $cityInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Fetch Weather") {
                            Task {
                                await viewModel.fetchWeather(forCity: cityInput)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 10)
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            // Main weather display
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
                            
                            // Hourly forecast scroll view
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
                            
                            // Daily forecast scroll view
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
                            Divider()
                            HStack{
                                VStack {
                                    HStack {
                                        Image(systemName: "thermometer.low")
                                        Text("Humidity".uppercased())
                                    }
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
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
                                .frame(width: 180.0, height: 300.0)
                                .background(Color.blue.gradient.opacity(0.5))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                
                                AirQualityView(
                                    airQualityScore: viewModel.airQualityScore,
                                    airQualityLevel: viewModel.airQualityLevel,
                                    qualityDescription: viewModel.airQualityDescription
                                )
                            }
                            
                            Divider()
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
                                
                                Spacer()
                                
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
            .padding(.horizontal, 10.0)
        }
        .onAppear {
            Task {
                await viewModel.fetchWeather(forCity: cityInput)
            }
        }
    }
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 120)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [.zoom, .pan], showsUserLocation: false, userTrackingMode: nil)
            .overlay(
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 300, height: 300) // Example precipitation overlay
            )
    }
}


struct BackgroundView: View {
    var topColor: Color
    var bottomColor: Color
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]),
                       startPoint: .topTrailing,
                       endPoint: .bottomLeading)
        .edgesIgnoringSafeArea(.all)
    }
}

struct WeatherViewVertical: View {
    var timeOfDay: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack {
            Text(timeOfDay)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .padding(10)
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 80)
            
            Text("\(temperature)°")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)
            
           
        }
    }
}

struct WeatherViewHorizontal: View {
    var dayOfWeek: String
    var imageName: String
    var temperatureEarlier: Int
    var temperatureLater: Int
    
    var body: some View {
        HStack {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
                
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .bottomLeading)
                
            Spacer()
            
            Text("\(temperatureEarlier)°")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            // Add gradient progress bar
            ProgressView(value: Double(temperatureEarlier), total: Double(temperatureLater))
                .progressViewStyle(GradientProgressViewStyle2(gradientColors: [.blue, .purple])) // Example gradient colors
                .frame(width: 70) // Adjust the width as needed
            
            Text("\(temperatureLater)°")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
        }
    }
}


struct AirQualityView: View {
    var airQualityScore: Int
    var airQualityLevel: String
    var qualityDescription: String
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "wind")
                Text("Air Quality".uppercased())
            }
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
            .shadow(radius: 10)
            
            Text("\(airQualityScore)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(airQualityScoreColor)
                .shadow(radius: 10)
            
            Text(airQualityLevel)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(airQualityScoreColor)
            
            Text(qualityDescription)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
            
            // Apply custom gradient progress view
            ProgressView(value: airQualityProgress, total: 1.0)
                .progressViewStyle(GradientProgressViewStyle()) // Apply the custom gradient style
                .padding(.horizontal)
        }
        .padding()
        .frame(width: 230.0, height: 300.0)
        .background(Color.blue.gradient.opacity(0.5))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
    
    private var airQualityProgress: Double {
        // Assuming a max AQI value of 500
        return Double(airQualityScore) / 500.0
    }
    
    private var airQualityScoreColor: Color {
        switch airQualityScore {
        case 0..<3:
            return .green
        case 3..<5:
            return .yellow
        case 5..<7:
            return .orange
        case 7..<8:
            return .red
        case 8..<10:
            return .purple
        default:
            return .brown
        }
    }
}

struct GradientProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Create a gradient from start to end
            LinearGradient(gradient: Gradient(colors: [.green, .yellow, .red]), startPoint: .leading, endPoint: .trailing)
                .frame(height: 10) // Adjust height as needed
                .cornerRadius(5)  // Round the corners for a smoother look
            
            // Show the progress value on top of the gradient
            ProgressView(configuration)
                .progressViewStyle(LinearProgressViewStyle(tint: .clear)) // Make the default progress clear
                .frame(height: 10)
                .cornerRadius(5)
        }
    }
}

struct GradientProgressViewStyle2: ProgressViewStyle {
    var gradientColors: [Color]
    
    init(gradientColors: [Color]) {
        self.gradientColors = gradientColors
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Create a gradient from start to end
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                .frame(height: 10) // Adjust height as needed
                .cornerRadius(5)  // Round the corners for a smoother look
            
            // Show the progress value on top of the gradient
            ProgressView(configuration)
                .progressViewStyle(LinearProgressViewStyle(tint: .clear)) // Make the default progress clear
                .frame(height: 10)
                .cornerRadius(5)
        }
    }
}

struct uvIndexView: View {
    var imageName: String
    var uvIndex: Int
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: imageName)
                Text("UV Index".uppercased())
            }
            Text("\(uvIndex)")
            Text(uvIndexLevel)
            ProgressView(value: Double(uvIndex) / 11.0, total: 1.0) // Assuming a max UV index of 11
                .frame(maxWidth: 70)
        }
        .padding()
        .frame(width: 200.0, height: 200.0)
        .background(Color.blue.gradient.opacity(0.5))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
    
    private var uvIndexLevel: String {
        switch uvIndex {
        case 0..<3:
            return "Low"
        case 3..<6:
            return "Moderate"
        case 6..<8:
            return "High"
        case 8..<11:
            return "Very High"
        default:
            return "Extreme"
        }
    }
}

struct sunTrackerView: View {
    var imageName: String
    let sunSet: String
    var suSetTime: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: imageName)
                Text(sunSet.uppercased())
            }
            Text("\(suSetTime)")
        }
        .padding()
        .frame(width: 200.0, height: 200.0)
        .background(Color.blue.gradient.opacity(0.5))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}

struct FeelsLikeView: View {
    var feelsLikeTemperature: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "thermometer.low")
                Text("Feels Like".uppercased())
            }
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white.opacity(0.6))
            .shadow(radius: 10)
            
            Text(feelsLikeTemperature)
            
            Text("Feels warmer or colder than actual temperature")
        }
        .padding()
        .background(Color.blue.gradient.opacity(0.5))
        .frame(width: 200,height: 200)
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}

#Preview {
    WeatherView()
}



struct WindSpeedView: View {
    var windSpeed: String
    var windDirection: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "wind")
                    .font(.system(size: 30))
                Text("Wind Speed".uppercased())
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 10)
            
            Text("Speed: \(windSpeed) km/h")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.white)
            
            Text("Direction: \(windDirection)")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.white)
            
            // Wind direction arrow icon
            Image(systemName: "arrow.up.circle.fill")
                .rotationEffect(Angle(degrees: windDirectionAngle))
                .foregroundColor(.white)
                .font(.system(size: 40))
        }
        .padding()
        .frame(width: 350, height: 250)
        .background(Color.blue.gradient.opacity(0.6))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
    
    // This calculates the wind direction angle based on the string (e.g. N, NW, E, etc.)
    private var windDirectionAngle: Double {
        switch windDirection {
        case "N":
            return 0
        case "NE":
            return 45
        case "E":
            return 90
        case "SE":
            return 135
        case "S":
            return 180
        case "SW":
            return 225
        case "W":
            return 270
        case "NW":
            return 315
        default:
            return 0
        }
    }
}

