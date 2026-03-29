//
//  GeoEngine.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 1/4/26.
//

import Foundation
import SwiftUI

let DEAD_BAND_M: Double = 1.5 //snaps to 0 if less than 1.5
let MAX_UI_M: Double = 2000
let SMOOTH_WINDOW: Int = 5 //rolling median window

struct Fix {
    let lat: Double
    let lon: Double
    let accM: Double //horizontal accuracy
    let timestamp_ms: UInt64
}

//gives us 3 options for what var "Band" can be. ex: Band.green
enum Band {
    case green
    case yellow
    case red
    
    var color: Color {
        switch self {
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        }
    }
}

struct DeltaResult {
    let rawDeltaM: Double
    let stableDeltaM: Double //deadband + smoothing
    let band: Band
    let note: String //ex "within accuracy envelope"
    
    }


func haversineMeters(_ a: Fix, _ b: Fix) ->Double {
    //unguard optional values?
    
    //returns raw distance
    return Geo.distanceMeters(lat1: a.lat, lon1: a.lon, lat2: b.lat, lon2: b.lon)
}

var recentRawDeltas: [Double] = []

func rollingMedian(_ x:Double) -> Double {
    recentRawDeltas.append(x)
    if recentRawDeltas.count > SMOOTH_WINDOW {
        //kicks out most recent val to insure window size is not exceeded
        recentRawDeltas.removeFirst(recentRawDeltas.count - SMOOTH_WINDOW)
    }
    let sorted = recentRawDeltas.sorted()
    //return median of values. doesn't matter if current size is less than window size, still returns median
    return sorted[sorted.count/2]
}

func computeDelta(phone: Fix, device: Fix) -> DeltaResult {
    let raw_distance = haversineMeters(phone, device)
    let smoothed_distance = rollingMedian(raw_distance)
    
    //like an if/else, first val is if true, second is if false
    let uiDelta = (smoothed_distance < DEAD_BAND_M) ? 0.0: smoothed_distance
    
    let envelope = max(DEAD_BAND_M, phone.accM + device.accM)
    
    let band: Band
    let note: String
    
    if smoothed_distance <= envelope {
        band = .green
        note = "within jitter/accuracy envelope"
    }
    else if smoothed_distance <= max(20.0, envelope*2.0) {
        band = .yellow
        note = "moderate delta: re-check accuracy + environment"
    }
    else {
        band = .red
        note = "large delta, likely real separation or bad fix"
    }
    
    //clamp ui
    let stable_distance = min(uiDelta, MAX_UI_M)
    return DeltaResult(
        rawDeltaM: raw_distance,
        stableDeltaM: stable_distance,
        band: band,
        note: note)
}
