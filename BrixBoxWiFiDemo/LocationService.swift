//
//  LocationService.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 12/29/25.
//
import Foundation

@MainActor
class LocationService: LocationServiceProtocol {
    func fetchDeviceLocation() async throws -> (lat: Double, lon: Double){
        let url = URL(string: "http://192.168.4.1/brix/location")!
        let (data, _) = try await URLSession.shared.data(from:url)
        let json = try JSONSerialization.jsonObject(with:data) as? [String: Any]
        
        let lat = json?["esp_lat"] as? Double ?? 0.0
        let lon = json?["esp_lon"] as? Double ?? 0.0
        //let accuracy = json?["esp_acc"] as? Double ?? 0.0
        //let timestamp = json?["esp_ts"] as? UInt32 ?? 0
        
        return (lat: lat, lon: lon)
    }
    func uploadPhoneLocation(payload: LocationPayload) async throws {
        let url = URL(string: "http://192.168.4.1/brix/location")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(payload)
        request.httpBody = jsonData
        let (_,response) = try await URLSession.shared.upload(for: request, from: jsonData)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
                
    }
    
}
