import SwiftUI
import _LocationEssentials

struct ContentView: View {
    
    //Choose between which protocol you want
    private let hardwareService: LocationServiceProtocol = {
#if DEBUG_ESP32_MOCK
        return MockESP32Service()
#else
        return LocationService()
#endif
    }()
    
    //StateObject keeps class instance alive even after UI refreshes
    @StateObject private var wifi = WiFiClient()
    @StateObject private var loc = LocationManager()
    @StateObject private var blManager = BluetoothManager()
    
    
    // One window: pick which "host endpoint" you're talking to.
    // ESP32 AP default is included.
    @State private var endpointChoice: String = "ESP32 (WiFi AP)"
    @State private var deviceURL: String = "http://192.168.4.1/brix" // ESP32 AP default
    @State private var autoPoll: Bool = true
    
    //hard coded device location:
    @State private var mockESP32: Fix? = nil
    
    
    private let endpoints: [(String, String)] = [
        ("ESP32 (WiFi AP)", "http://192.168.4.1/brix"),
        // Placeholders for STM32 / Windows CE gateways:
        // These are ONLY valid if those hosts expose the same HTTP endpoint over WiFi/Ethernet/USB-tether.
        ("STM32 Gateway (placeholder)", "http://brixbox-stm32.local/brix"),
        ("Windows CE Gateway (placeholder)", "http://brixbox-ce.local/brix")
    ]
    
    //calculation of distance based on hardcoded location
    /*
     var distance: Double? {
     
     guard let phone_loc = loc.phoneLocation,
     let dev = hardCodedDeviceLocation else {return nil}
     
     return Geo.distanceMeters(phone: phone_loc, deviceLat: dev.lat, deviceLon: dev.lon)
     }
     */
    //determines color
    /*
     var confidence_color: Color {
     guard let d = distance else {return .secondary}
     if d < 5 {
     return .green
     }
     else if d <= 20 {
     return .yellow
     }
     else {
     return .red
     }
     }
     */
    var body: some View {
        
        TabView {
            ScrollView {
                //-----------------Tab 1--------------------------------------------
                VStack(spacing: 14) {
                    Text("BrixBox Demo").font(.largeTitle).bold()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Endpoint").font(.headline)
                        
                        Picker("Endpoint", selection: $endpointChoice) {
                            ForEach(endpoints.map{$0.0}, id: \ .self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Device URL", text: $deviceURL)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .onChange(of: endpointChoice) { _, newValue in
                        if let match = endpoints.first(where: { $0.0 == newValue }) {
                            deviceURL = match.1
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(loc.statusText).font(.subheadline)
                        Spacer()
                        Text(wifi.statusText).font(.subheadline)
                    }
                    
                    let latest = wifi.latest
                    let brix = latest?.brix
                    
                    //these are unused when hardcoded
                    //let dlat = latest?.gps.lat
                    //let dlon = latest?.gps.lon
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("BRIX").font(.headline)
                        Text(brix.map{ String(format: "%.2f", $0) } ?? "--.--")
                            .font(.system(size: 44, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                        Divider().padding(.vertical, 6)
                        
                        //---------------iPhone Coordinates------------------
                        //My additions to test if iphone GPS reads correctly
                        Text("iPhone GPS Validation").font(.headline)
                        if let p = loc.phoneLocation {
                            Text("Phone Coords: \(p.coordinate.latitude), \(p.coordinate.longitude)")
                            Text("Update Counter: \(loc.updateCounter)")
                        }
                        else {
                            Text("Phone Coords: unknown")
                        }
                        //
                        Divider().padding(.vertical, 6)
                        
                        //--------------Distance, Latitude, Longitude Display-
                        Text("GPS Delta (meters)").font(.headline)
                        
                        
                        //Original:
                        //Text(deltaText(phone: loc.phoneLocation, deviceLat: dlat, deviceLon: dlon))
                        //instead, do with hardcoded devicelat and devicelon.
                        //my Addition:
                        
                        Text("Device Latitude: \( mockESP32?.lat ?? 0.0)")
                        Text("Device Longitude: \(mockESP32?.lon ?? 0.0)")
                        
                        
                        //displays with color coded confidence level and introduces dead zone
                        Text("Raw Distance: \(calculationResults?.rawDeltaM ?? 0.0)")
                        Text("Stable Distance: \(calculationResults?.stableDeltaM ?? 0.0)")
                            .foregroundColor(calculationResults?.band.color ?? .white)
                        
                        
                        Divider().padding(.vertical, 6)
                        
                        //-------------Comms display--------------------
                        Text("Comms").font(.headline)
                        commCapsView(latest?.comm_caps)
                        
                        Text("Host targets").font(.headline)
                        Text((latest?.host_targets?.joined(separator: ", ") ?? "unknown"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider().padding(.vertical, 6)
                    //----------Fetch Requests-------------
                    HStack(spacing: 12) {
                        Button("Request Location") { loc.request() }
                            .buttonStyle(.bordered)
                        
                        Button("Fetch /brix") {
                            //Task { await wifi.fetch(urlString: deviceURL) }
                            //changing where the brix box fetches from in order to test hardcoded values
                            Task {
                                let result = try await hardwareService.fetchDeviceLocation()
                                //mockESP32 = (lat:result.lat, lon:result.lon, accM : result.accuracy, timestamp_ms: result.timestamp_ms)
                                mockESP32 = Fix(lat: result.lat, lon: result.lon, accM: result.accuracy, timestamp_ms: result.timestamp_ms)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Toggle("Auto", isOn: $autoPoll)
                            .toggleStyle(.switch)
                    }
                    
                    if let latest {
                        Text("unit_id: \(latest.unit_id)  ts: \(Int(latest.ts_unix))")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                    if let e = wifi.lastError {
                        Text("Error: \(e)").font(.footnote).foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    loc.request()
                    startAutoPoll()
                }
                .onChange(of: autoPoll) { _, _ in
                    startAutoPoll()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            //----------------Tab 2------------------------------
            NavigationStack {
                VStack(spacing: 14) {
                    Text("Bluetooth Scanner").font(.largeTitle).bold()
                    //--------------Bluetooth Scanning-------------------
                    //first check if bluetooth is on device
                    let bl_status = blManager.bluetoothState
                    Text("Bluetooth Status: \(bl_status)")
                    Spacer()
                    List(blManager.devicesArray) { device in
                        HStack {
                            Text(device.name)
                            Spacer()
                            Text("\(device.rssi) dBm")
                            Spacer()
                            Text(device.strength)
                        }
                    }
                    Divider().padding(.vertical, 6)
                }
            }
                .tabItem {
                    Label("Scanner", systemImage: "antenna.radiowaves.left.and.right")
                }
        }
    }
    
    
    var calculationResults: DeltaResult? {
        guard let pLoc = loc.phoneLocation, let dLoc = mockESP32 else {return nil}
        let phoneFix = Fix(
            lat: pLoc.coordinate.latitude,
            lon: pLoc.coordinate.longitude,
            accM: loc.horizontalAccuracy,
            timestamp_ms: 1636024000000)
        return computeDelta(phone: phoneFix, device: dLoc)
    }
    
    
    
    private func startAutoPoll() {
        guard autoPoll else { return }
        Task {
            while autoPoll {
                await wifi.fetch(urlString: deviceURL)
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
    
    
    private func deltaText(phone: CLLocation?, deviceLat: Double?, deviceLon: Double?) -> String {
        guard let lat = deviceLat, let lon = deviceLon else { return "--" }
        if let d = Geo.distanceMeters(phone: phone, deviceLat: lat, deviceLon: lon) {
            return String(format: "%.1f m", d)
        }
        return "phone gps --"
    }
    
    @ViewBuilder
    private func commCapsView(_ caps: BrixResponse.CommCaps?) -> some View {
        let wifiOn = caps?.wifi ?? false
        let bleOn = caps?.ble ?? false
        let cellOn = caps?.cellular5g ?? false
        let satOn = caps?.satellite ?? false
        
        HStack(spacing: 10) {
            capBadge("WiFi", wifiOn)
            capBadge("BLE", bleOn)
            capBadge("5G", cellOn)
            capBadge("SAT", satOn)
        }
    }
    
    private func capBadge(_ label: String, _ on: Bool) -> some View {
        Text(label)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(on ? Color.green.opacity(0.25) : Color.gray.opacity(0.18))
            .clipShape(Capsule())
    }
}
