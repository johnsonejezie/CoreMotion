//
//  InterfaceController.swift
//  CoreMotion WatchKit Extension
//
//  Created by Johnson Ejezie on 30/12/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    let manager = MotionManager()
    let centralManager = CBManager()
    var active = false
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        manager.delegate = self
        // Configure interface objects here.
    }
    
    override func willActivate() {
        super.willActivate()
        active = true
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }

}

extension InterfaceController: MotionManagerDelegate {
    func didUpdateMotion(_ gravity: String, rotation: String, acceleration: String, attitude: String) {
        print(gravity)
        print(rotation)
        print(acceleration)
        print(attitude)
        centralManager.sendData(gravity: gravity, rotation: rotation, acceleration: acceleration, attitude: attitude)
    }
}
