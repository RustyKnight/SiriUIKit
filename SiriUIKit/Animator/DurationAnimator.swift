//
//  DurationAnimator.swift
//  SiriUIKit
//
//  Created by Shane Whitehead on 24/8/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import UIKit

// MARK: DurationAnimator
// An Animator with a specific time frame to run in
public protocol DurationAnimatorDelegate {
	func didTick(Animator: DurationAnimator, progress: Double)
	func didComplete(Animator: DurationAnimator, completed: Bool)
}

public class DurationAnimator: Animator {
	
	public var delegate: DurationAnimatorDelegate?
	
	internal var duration: TimeInterval // How long the Animator should play for
	internal var startedAt: Date? // When the Animator was started
	
	internal var timingFunction: CAMediaTimingFunction?
	
	internal var rawProgress: Double {
		guard let startedAt = startedAt else {
			return 0.0
		}
		let runningTime = Date().timeIntervalSince(startedAt)
		return runningTime / duration
	}
	
	internal var progress: Double {
		let value = rawProgress
		guard let timingFunction = timingFunction else {
			return value
		}
		return timingFunction.value(atTime: value)
	}
	
	init(duration: TimeInterval, timingFunction: CAMediaTimingFunction? = nil) {
		self.duration = duration
		self.timingFunction = timingFunction
	}
	
	override public func tick() {
        guard startedAt != nil else {
			return
		}
		defer {
			if rawProgress >= 1.0 {
				stop()
			}
		}
		let progress = self.progress
		delegate?.didTick(Animator: self, progress: progress)
	}
	
	override func didStart() {
		startedAt = Date()
	}
	
	override func didStop() {
		delegate?.didComplete(Animator: self, completed: rawProgress >= 1.0)
		startedAt = nil
	}
	
}
