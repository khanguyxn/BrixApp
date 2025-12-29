import Foundation
import CoreLocation

enum Geo {
    // Haversine distance in meters
    static func distanceMeters(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0
        let toRad = Double.pi / 180.0
        let dLat = (lat2 - lat1) * toRad
        let dLon = (lon2 - lon1) * toRad
        let a = sin(dLat/2)*sin(dLat/2) + cos(lat1*toRad)*cos(lat2*toRad)*sin(dLon/2)*sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }

    static func distanceMeters(phone: CLLocation?, deviceLat: Double, deviceLon: Double) -> Double? {
        guard let p = phone else { return nil }
        return distanceMeters(lat1: p.coordinate.latitude, lon1: p.coordinate.longitude,
                              lat2: deviceLat, lon2: deviceLon)
    }
}
