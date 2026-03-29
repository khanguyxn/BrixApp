//
//  LocationPayload.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 12/29/25.
//

import Foundation

public struct LocationPayload: Codable {
    let phone_lat: Double
    let phone_lon: Double
    let accuracy_m: Double
    let timestamp_ms: UInt64
}


