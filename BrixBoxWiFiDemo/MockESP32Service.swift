//
//  MockESP32Service.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 12/29/25.
//

import Foundation
//in Build Settings, Debug, need to have "DEBUG_ESP32_MOCK" in the "active" value otherwise this protocol will not be selected.

class MockESP32Service: LocationServiceProtocol {
    func fetchDeviceLocation() async throws -> (lat: Double, lon: Double, accuracy: Double, timestamp_ms: UInt64) {
        return (lat: 37.667685, lon: -121.907124, accuracy: 1.0, timestamp_ms: 1636024000000)
    }
    func uploadPhoneLocation(payload: LocationPayload) async throws {
        print("MOCK: Data sent: \(payload.phone_lat), \(payload.phone_lon)")
    }
    
}
