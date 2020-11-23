//
//  MMBluetoothReader.swift
//  WNoter
//
//  Created by Floris Fredrikze on 25/09/2020.
//

import Foundation
import CoreBluetooth
import Combine

class MMBluetoothReader: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let aicareWeightServiceUUID = CBUUID(string: "0000FFB0-0000-1000-8000-00805F9B34FB")
    let aicareWeightCharacteristicUUID = CBUUID(string: "0000FFB2-0000-1000-8000-00805F9B34FB")

    var centralManager: CBCentralManager
    var hasMeasured = false
    
    @Published var wdata: [MMWeightData]
    @Published var isUpdating = false
    
    var connectedPeripheral: CBPeripheral?
    var discoveredServices: [CBService]?
    
    override init() {
        self.wdata = [
// some test data
//            MMWeightData(weight: 10, type: .kDefiniteWeight),
//            MMWeightData(weight: 20, type: .kDefiniteWeight),
//            MMWeightData(weight: 10, type: .kDefiniteWeight),
//            MMWeightData(weight: 20, type: .kDefiniteWeight),
//            MMWeightData(weight: 10, type: .kDefiniteWeight),
//            MMWeightData(weight: 20, type: .kDefiniteWeight),
//            MMWeightData(weight: 10, type: .kDefiniteWeight),
//            MMWeightData(weight: 20, type: .kDefiniteWeight)
        ]
        centralManager = CBCentralManager()
        super.init()
        centralManager.delegate = self
    }
    
    func startScanning() {
		if centralManager.state == .poweredOn {
			centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
			isUpdating = true
		}
	}

	func stopScanning() {
		centralManager.stopScan()
		isUpdating = false
	}
    
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
     }

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
	{
        NSLog("didDiscover: %@ %@", peripheral, advertisementData)
		if peripheral.name == "ADV" {
            NSLog("didDiscover: %@", peripheral)
			if let advData: NSData = advertisementData["kCBAdvDataManufacturerData"] as? NSData {
                if let weight = MMDataParserOKOK.getWeightFromData(advData)
                {
                    if let first = wdata.first, first.type == weight.type && first.weight == weight.weight
                    {
                        NSLog("Not Duplicating \(weight)")
                    }
                    else
                    {
                        NSLog("Found \(weight)")
                        objectWillChange.send()
                        wdata.insert(weight, at: 0);
                    }
                }
			}
		}
        else if peripheral.name == "SWAN" || peripheral.identifier == UUID(uuidString: "F0CC1E79-3574-4C17-AAF0-AA158F199979")
        {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            stopScanning()
            NSLog("Trying to connect to: \(peripheral.name ?? "(null)")")
            if peripheral != connectedPeripheral || connectedPeripheral?.state == .disconnected {
                NSLog("Trying to connect to: \(peripheral.name ?? "(null)")")
                connectedPeripheral = peripheral;
                peripheral.delegate = self;
                connect(peripheral: peripheral);
            }
        }
	}
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("didDiscoverServices [\(peripheral.identifier)]: %@", peripheral.services ?? "(null)")
        if let services = peripheral.services
        {
            discoveredServices = services
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            discoveredServices = peripheral.services;
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        NSLog("didDiscoverCharacteristicsFor [\(peripheral.identifier):\(service.uuid)]: %@", service.characteristics ?? "(null)")
        if let characteristics = service.characteristics, service.uuid == aicareWeightServiceUUID {
            if let charateristic = characteristics.first(where: {$0.uuid == aicareWeightCharacteristicUUID})
            {
                peripheral.setNotifyValue(true, for: charateristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("didUpdateValueFor %@", characteristic)
        
        if let data = characteristic.value, characteristic.uuid == aicareWeightCharacteristicUUID
        {
            if let weight = MMDataParserSwan.getWeightFromData(NSData(data: data))
            {
                if let first = wdata.first, first.type == weight.type && first.weight == weight.weight
                {
                    NSLog("Not Duplicating \(weight)")
                }
                else
                {
                    NSLog("Found \(weight)")
                    objectWillChange.send()
                    wdata.insert(weight, at: 0);
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("didConnect: %@", peripheral)
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("Failed to connect to %@", peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                break
            case .poweredOff:
                isUpdating = false
            default: break
        }
        print(central)
    }

}
