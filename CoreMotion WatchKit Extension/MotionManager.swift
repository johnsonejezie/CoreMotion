//
//  MotionManager.swift
//  CoreMotion WatchKit Extension
//
//  Created by Johnson Ejezie on 30/12/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
import CoreMotion

protocol MotionManagerDelegate: class {
    func didUpdateMotion(_ gravity: String, rotation: String, acceleration: String, attitude: String)
}

private let defaultDeviceMotionUpdateInterval = 0.01

final class MotionManager {
    weak var delegate: MotionManagerDelegate?
    private var motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = defaultDeviceMotionUpdateInterval
        return motionManager
    }()

    private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            return
        }
        motionManager.deviceMotionUpdateInterval = 1.0/50
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion, error) in
            if let deviceMotion = deviceMotion {
                self.processDeviceMotion(deviceMotion: deviceMotion)
            }
        }
    }

    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func processDeviceMotion(deviceMotion: CMDeviceMotion) {
        let gravity = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                            deviceMotion.gravity.x,
                            deviceMotion.gravity.y,
                            deviceMotion.gravity.z)
        let acceleration = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                           deviceMotion.userAcceleration.x,
                           deviceMotion.userAcceleration.y,
                           deviceMotion.userAcceleration.z)
        let rotation = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                              deviceMotion.rotationRate.x,
                              deviceMotion.rotationRate.y,
                              deviceMotion.rotationRate.z)
        let attitude = String(format: "r: %.1f p: %.1f y: %.1f" ,
                                 deviceMotion.attitude.roll,
                                 deviceMotion.attitude.pitch,
                                 deviceMotion.attitude.yaw)
        delegate?.didUpdateMotion(gravity, rotation: rotation, acceleration: acceleration, attitude: attitude)
    }
}
