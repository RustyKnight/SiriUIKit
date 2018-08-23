//
//  LinearAnimator.swift
//  SiriUIKit
//
//  Created by Shane Whitehead on 24/8/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import UIKit

// MARK: LinearAnimator
// The intention of this class is to provide a "untimed" Animator cycle,
// meaning that it will just keep on ticking, it has no duration.  Probably
// good for things like timers or Animator cycles which don't know how
// long they need to keep running for
public protocol LinearAnimatorDelegate {
	func didTick(Animator: LinearAnimator)
}

public class LinearAnimator: Animator {
	
	public var delegate: LinearAnimatorDelegate?
	
	// Extension point
	override public func tick() {
		delegate?.didTick(Animator: self)
	}
	
}
