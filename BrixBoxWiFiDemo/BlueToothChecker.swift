//
//  BlueToothChecker.swift
//  BrixBoxWiFiDemo
//
//  Created by Khang Nguyen on 3/29/26.
//

import CoreBluetooth
import Combine

//---------------------Step 1: State Check---------------------------
//First, check if user device has bluetooth on by using Delegate method
//Will update everytime Bluetooth hardware changes status

struct BluetoothDevice: Identifiable {
    let id: UUID
    let name: String
    var rssi: Int
    var strength: String
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    //published is necessary bc it's an observableobject
    var centralManager: CBCentralManager!
    @Published var bluetoothState: String = "Checking..."
    @Published var discoveredDevices: [UUID: BluetoothDevice] = [:]
    
    //sort devices by rssi strength for easier display
    var devicesArray: [BluetoothDevice] {
        discoveredDevices.values.sorted{$0.rssi > $1.rssi}
    }
    
    override init() {
        super.init()
        //delegate:self means manager sends all updates from the various functions back to this class
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    //runs once after initializing centralManager, then waits for a change before running again
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth on")
            bluetoothState = "Bluetooth on"
            
            //as soon as bluetooth is turned on, we tell centralManager to begin scanning for peripherals
            
            //withServices: nil, meaning scan for EVERYTHING. In other instances, we'd scan for specific ID's only.
            //AllowDuplicates: if true, continue scanning for a device even after we have detected it once
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        case .poweredOff:
            print("Bluetooth off")
            bluetoothState = "Bluetooth off"
        case .unauthorized:
            print("No Bluetooth permission")
            bluetoothState = "No Bluetooth permission"
        case .unsupported:
            print("Not Supported")
            bluetoothState = "Bluetooth not supported"
        default:
            print("Bluetooth in unknown state")
            bluetoothState = "Unknown"
        }
    }
    
    //event handler: continually run this every time we hear a new bluetooth device.
    //didDiscover is the interrupt signal. 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //filter out devices where we cannot read name
        guard let name = peripheral.name else {return}
        let rssi = RSSI.intValue
        let id = peripheral.identifier
        var strength = "default"
        if rssi > -60 {
            strength = "close"
        }
        else if rssi > -80{
            strength = "medium"
        }
        else if rssi <= -80 {
            strength = "far"
        }
        
        //implement a dictionary: checks if we've already logged the device with that id. If not, add. If yes, don't add.
        //compare by uuid to filter out duplicate readings
        discoveredDevices[id] = BluetoothDevice(id: id, name: name, rssi:rssi, strength : strength)
        print("Found \(name) with strength \(rssi)")
    }
    
}

