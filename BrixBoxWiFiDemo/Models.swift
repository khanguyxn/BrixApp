import Foundation

struct BrixResponse: Codable {
    struct GPS: Codable {
        let lat: Double
        let lon: Double
        let alt_m: Double?
        let fix: Int?
    }

    struct CommCaps: Codable {
        let wifi: Bool?
        let ble: Bool?
        let cellular5g: Bool?
        let satellite: Bool?
    }

    let brix: Double
    let unit_id: String
    let ts_unix: Double
    let gps: GPS

    // New (v0.3): capabilities + host targets
    let comm_caps: CommCaps?
    let host_targets: [String]?
}
