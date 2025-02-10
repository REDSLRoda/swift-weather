import SwiftUI

struct MainView: View {
    @State private var selectedTab = 1  
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // WorldMapView Tab
            WorldMapView()
                .tabItem {
                    Label("Explore Map", systemImage: "map.fill")
                        
                }
                .tag(0)  // Set tag for the first tab
            
            // OnboardingView Tab
            OnboardingView()
               
                .tag(1)  // Set tag for the onboarding tab, this will be the initial selected tab
            
            // CityListView Tab
            CityListView()
                .tabItem {
                    Label("Stored Places", systemImage: "bookmark.fill")
                }
                .tag(2)  // Set tag for the third tab
        }
        .onAppear {
            // This will ensure the onboarding tab is selected when the app launches
            selectedTab = 1
        }
        .background(Color.clear)  // Set the TabView background to transparent
        .overlay(
            VStack {
                Spacer()
            }
            .background(Color.clear)  // Make sure the content does not get clipped
        )
        .ignoresSafeArea()
    }
}

#Preview {
    MainView()
}
