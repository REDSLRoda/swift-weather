import SwiftUI

struct DynamicBackgroundView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var movingClouds = false
    @State private var fallingRain = false
    @State private var fallingSnow = false

    var body: some View {
        ZStack {
            // Conditional animation based on weather description
            if viewModel.weatherDescription.lowercased().contains("clear") {
                clearSkyBackground
            } else if viewModel.weatherDescription.lowercased().contains("rain") {
                rainBackground
            } else if viewModel.weatherDescription.lowercased().contains("snow") {
                snowBackground
            } else if viewModel.weatherDescription.lowercased().contains("cloud") {
                cloudyBackground
            } else {
                defaultBackground
            }
        }
        .onAppear {
            // Update the animations based on the weather description
            updateWeatherAnimation()
        }
        .onChange(of: viewModel.weatherDescription) { _ in
            updateWeatherAnimation()
        }
    }

    // Update animation based on weather condition
    private func updateWeatherAnimation() {
        switch viewModel.weatherDescription.lowercased() {
        case let description where description.contains("rain"):
            fallingRain = true
            fallingSnow = false
            movingClouds = false
        case let description where description.contains("snow"):
            fallingRain = false
            fallingSnow = true
            movingClouds = false
        case let description where description.contains("cloud"):
            movingClouds = true
            fallingRain = false
            fallingSnow = false
        default:
            fallingRain = false
            fallingSnow = false
            movingClouds = false
        }
    }

   

    // Background with moving clouds
    private var cloudyBackground: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            if movingClouds {
                ForEach(0..<10, id: \.self) { _ in
                    MovingCloudsView()
                }
            }
        }
    }

    // Background with rain animation
    private var rainBackground: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            if fallingRain {
                ForEach(0..<20, id: \.self) { _ in
                    FallingRainView()
                }
            }
        }
    }

    // Background with snow animation
    private var snowBackground: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            if fallingSnow {
                ForEach(0..<20, id: \.self) { _ in
                    FallingSnowView()
                }
            }
        }
    }

    // Default background for unknown weather conditions
    private var defaultBackground: some View {
        LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}
private var clearSkyBackground: some View {
    ZStack {
        // Gradient background representing a clear sky
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.cyan, Color.white.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)

        // Lens flare effect
        LensFlareView()
            .offset(x: -50, y: -200) // Position the lens flare
    }
}

// Lens flare view
struct LensFlareView: View {
    @State private var flareScale: CGFloat = 1.0
    @State private var flareOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // Main sun flare
            Circle()
                .fill(Color.yellow.opacity(0.5))
                .frame(width: 150, height: 150)
                .blur(radius: 30)

            // Glow around the main flare
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 50)

            // Additional small lens flare spots
            Group {
                LensFlareSpot(size: 50, color: .white.opacity(0.6), offset: CGSize(width: 100, height: 100))
                LensFlareSpot(size: 30, color: .yellow.opacity(0.4), offset: CGSize(width: 200, height: 180))
                LensFlareSpot(size: 70, color: .cyan.opacity(0.3), offset: CGSize(width: -150, height: 220))
                LensFlareSpot(size: 40, color: .pink.opacity(0.2), offset: CGSize(width: -50, height: 300))
            }
        }
        .scaleEffect(flareScale)
        .opacity(flareOpacity)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
            ) {
                flareScale = 1.2
                flareOpacity = 1.0
            }
        }
    }
}

// Helper view for small flare spots
struct LensFlareSpot: View {
    var size: CGFloat
    var color: Color
    var offset: CGSize

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size / 4)
            .offset(offset)
    }
}

struct MovingCloudsView: View {
    @State private var cloudOffset = CGSize(width: -500, height: CGFloat.random(in: -300...300))

    var body: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .foregroundColor(.white.opacity(0.6))
            .scaledToFit()
            .frame(width: CGFloat.random(in: 100...200), height: CGFloat.random(in: 50...100))
            .offset(cloudOffset)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 10...30)).repeatForever(autoreverses: false)) {
                    cloudOffset = CGSize(width: 500, height: cloudOffset.height)
                }
            }
    }
}

struct FallingRainView: View {
    let rainDrops = Array(0..<50) // Generate 50 raindrops for a denser effect

    var body: some View {
        ZStack {
            ForEach(rainDrops, id: \.self) { _ in
                SingleRainDropView()
            }
        }
    }
}

struct SingleRainDropView: View {
    @State private var rainOffset = CGSize(width: CGFloat.random(in: -200...200), height: -500)

    var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .foregroundColor(.blue.opacity(0.6))
            .scaledToFit()
            .frame(width: 5, height: 15)
            .offset(rainOffset)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 2...5)).repeatForever(autoreverses: false)) {
                    rainOffset = CGSize(width: rainOffset.width, height: 600)
                }
            }
    }
}

struct FallingSnowView: View {
    let snowFlakes = Array(0..<30) // Generate 50 snowflakes for a denser effect

    var body: some View {
        ZStack {
            ForEach(snowFlakes, id: \.self) { _ in
                SingleSnowFlakeView()
            }
        }
    }
}

struct SingleSnowFlakeView: View {
    @State private var snowOffset = CGSize(width: CGFloat.random(in: -200...200), height: -500)

    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .foregroundColor(.white.opacity(0.3))
            .scaledToFit()
            .frame(width: CGFloat.random(in: 10...30), height: CGFloat.random(in: 10...30))
            .offset(snowOffset)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 5...10)).repeatForever(autoreverses: false)) {
                    snowOffset = CGSize(width: snowOffset.width, height: 600)
                }
            }
    }
}

struct SunnyView: View {
    var body: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 100, height: 100)
            .shadow(radius: 10)
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .opacity(0.8)
    }
}

struct DynamicBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicBackgroundView(viewModel: WeatherViewModel())
    }
}
