//
//  LocationManager.swift
//  CercaApp
//
//  Created by Eduardo González on 22/1/25.
//

import CoreLocation
import MapKit

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation = .init(coordinate: CLLocationCoordinate2D(latitude: 51.500685, longitude: -0.124570), altitude: .zero, horizontalAccuracy: .zero, verticalAccuracy: .zero, timestamp: Date.now)
    var direction: CLLocationDirection = .zero
    private let locationManager = CLLocationManager()
    
    
    
    var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 50 // Minum distance 50 meters
        locationManager.delegate = self
        
        Task { [weak self] in
            try? await self?.requestAuthorization()
        }
    }
   
    
    func requestAuthorization() async throws {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { [weak self] location in
            Task { @MainActor [weak self] in
                self?.location = location
                self?.userLocation = location.coordinate
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor [weak self] in
            self?.direction = newHeading.trueHeading
        }
    }
}
