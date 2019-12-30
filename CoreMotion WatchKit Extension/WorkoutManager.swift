//
//  WorkoutManager.swift
//  CoreMotion WatchKit Extension
//
//  Created by Johnson Ejezie on 30/12/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: class {
    func didUpdateMotion(_ gravity: String, rotation: String, acceleration: String, attitude: String)
}

final class WorkoutManager {
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()
    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?

    init() {
        motionManager.delegate = self
    }

    func startWorkout() {
        if session == nil {
            return
        }

        let workoutConfig = HKWorkoutConfiguration()
        workoutConfig.activityType = .wheelchairWalkPace
        workoutConfig.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfig)
        } catch {
            fatalError("Failed to create session workout session!")
        }
        session!.startActivity(with: nil)
        motionManager.startUpdates()
    }

    func stopWorkout() {
        if (session == nil) {
            return
        }
        session!.stopActivity(with: nil)
        motionManager.stopUpdates()
        session = nil
    }
}


extension WorkoutManager: MotionManagerDelegate {
    func didUpdateMotion(_ gravity: String, rotation: String, acceleration: String, attitude: String) {
        delegate?.didUpdateMotion(gravity, rotation: rotation, acceleration: acceleration, attitude: attitude)
    }
}
