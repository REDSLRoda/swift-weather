//
//  RandomCity.swift
//  WeatherCW
//
//  Created by Achintha on 2025-01-01.
//

import SwiftUI

struct RandomCityView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var randomCity: String = ""
    private let cities = ["London", "New York", "Tokyo", "Paris", "Colombo"]

    var body: some View {
        ZStack {
            BackgroundView(topColor: Color("lightblue"), bottomColor: .blue)

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Display selected city name
                    Text("Weather for \(randomCity)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

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

                            AirQualityView(
                                airQualityScore: viewModel.airQualityScore,
                                airQualityLevel: viewModel.airQualityLevel,
                                qualityDescription: viewModel.airQualityDescription
                            )

                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                        Text("Averages".uppercased())
                                    }
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .shadow(radius: 10)

                                    Text("+2°")
                                        .font(.system(size: 40, weight: .semibold))

                                    Text("above or below daily high average")

                                    if let selectedDay = viewModel.selectedDayForecast {
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
                                .padding()
                                .background(Color.blue.gradient.opacity(0.5))
                                .cornerRadius(20)
                                .foregroundColor(.white)

                                Spacer()

                                FeelsLikeView(feelsLikeTemperature: viewModel.feelsLikeTemperature)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10.0)
        }
        .onAppear {
            randomCity = cities.randomElement() ?? "London" // Select a random city
            Task {
                await viewModel.fetchWeather(forCity: randomCity)
                
            }
        }
    }
}

#Preview {
    RandomCityView()
}
