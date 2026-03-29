//
//  LocationServiceProtocol.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 12/29/25.
//
import Foundation
protocol LocationServiceProtocol {
    
    func fetchDeviceLocation() async throws -> (lat: Double, lon: Double, accuracy: Double, timestamp_ms: UInt64)
    
    func uploadPhoneLocation(payload: LocationPayload) async throws
    
}
