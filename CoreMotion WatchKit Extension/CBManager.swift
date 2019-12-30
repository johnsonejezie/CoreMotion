//
//  CBManager.swift
//  CoreMotion WatchKit Extension
//
//  Created by Johnson Ejezie on 30/12/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import CoreBluetooth

class CBManager: NSObject {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    let uuid = CBUUID(string: "0x2A38")
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    fileprivate func scan() {
        centralManager.scanForPeripherals(withServices: [uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true as Bool)])
    }

    fileprivate func cleanUp() {
        guard discoveredPeripheral?.state != .disconnected,
            let services = discoveredPeripheral?.services else {
                centralManager.cancelPeripheralConnection(discoveredPeripheral!)
                return
        }
        for service in services {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid.isEqual(uuid) {
                        if characteristic.isNotifying {
                            discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                            return
                        }
                    }
                }
            }
        }
        centralManager.cancelPeripheralConnection(discoveredPeripheral!)
    }

    // Depending on the maximum transmission unit, the logic here can be modified
    // Data can be modified 
    func sendData(gravity: String, rotation: String, acceleration: String, attitude: String) {
        let string = "\(gravity),\(rotation),\(acceleration),\(attitude)"
        guard let data = string.data(using: .utf8) else { return }
        if let peripheral = self.discoveredPeripheral,
            let characteristic = self.characteristic {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
}

// Mark:- CBCentralManagerDelegate
extension CBManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scan()
        case .poweredOff, .resetting:
            cleanUp()
        default:
            return
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if discoveredPeripheral == peripheral {
            cleanUp()
        }
        scan()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let range = -40..<(-15)
        guard range.contains(RSSI.intValue) && discoveredPeripheral != peripheral else { return }
        discoveredPeripheral = peripheral
        central.connect(peripheral, options: [:])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        cleanUp()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([uuid])
    }
}


//CBPeripheralDelegate
extension CBManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            cleanUp()
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([uuid], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {}

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {}

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {}

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            cleanUp()
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == uuid {
                    self.characteristic = characteristic
                }
            }
        }
    }
}
