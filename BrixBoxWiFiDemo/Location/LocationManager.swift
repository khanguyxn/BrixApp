import Foundation
import CoreLocation
import SwiftUI
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var phoneLocation: CLLocation?
    @Published var statusText: String = "Loc: idle"
    
    //added update counter to visualize changes in gps
    @Published var updateCounter: Int = 0
    
    
    
    private let lm = CLLocationManager()

    override init() {
        super.init()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
    }

    func request() {
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingLocation()
        statusText = "Loc: requesting…"
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            statusText = "Loc: authorized"
        case .denied, .restricted:
            statusText = "Loc: denied"
        default:
            statusText = "Loc: pending"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        phoneLocation = locations.last
        
        //added update counter to visualize changes in gps
        updateCounter += 1
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusText = "Loc error"
    }
}
