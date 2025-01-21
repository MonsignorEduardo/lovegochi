import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var newlocationManager = NewLocationManager()
    @State var oldLocationManager = OldLocationManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .padding()
            Text("Old location manager: \(oldLocationManager.location?.description ?? "No Location Provided!")")
            Text("New location manager: \(newlocationManager.location?.description ?? "No Location Provided!")")
        }
        .padding()
        .task {
            oldLocationManager.requestUserAuthorization()
            oldLocationManager.startCurrentLocationUpdates()
        }
        .task {
            try? await newlocationManager.requestUserAuthorization()
            try? await newlocationManager.startCurrentLocationUpdates()
            // remember that nothing will run here until the for try await loop finishes
        }
    }
}

@Observable
class OldLocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestUserAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        self.location = location
    }
}

@Observable
class NewLocationManager {
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()
    
    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }

            self.location = location
        }
    }
}
