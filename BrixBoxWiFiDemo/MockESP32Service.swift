//
//  MockESP32Service.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 12/29/25.
//

import Foundation

class MockESP32Service: LocationServiceProtocol {
    func fetchDeviceLocation() async throws -> (lat: Double, lon: Double) {
        return (lat: 37.667700, lon: -121.907100)
    }
    func uploadPhoneLocation(payload: LocationPayload) async throws {
        print("MOCK: Data sent: \(payload.phone_lat), \(payload.phone_lon)")
    }
    
}
