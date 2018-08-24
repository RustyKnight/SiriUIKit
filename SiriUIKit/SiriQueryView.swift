//
//  SiriQueryView.swift
//  SiriKit
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
	static var positiveRandom: CGFloat {
		return CGFloat.random(in: 0..<CGFloat.greatestFiniteMagnitude)
	}
}

extension Int {
	static var positiveRandom: Int {
		return Int.random(in: 0..<Int.max)
	}
}

extension Int32 {
	static var positiveRandom: Int32 {
		return Int32.random(in: 0..<Int32.max)
	}
}

internal let cgRandMax = CGFloat(RAND_MAX)

public class SiriQueryView: UIView {
	
//	internal static let numberOfElements = 10
	internal static let colors: [[CGFloat]] = [
		[32, 133, 252],
		[94, 252, 169],
		[253, 71, 103],
		[45, 246, 238],
		[252, 18, 245],
		[224, 245, 22],
	]
	
	internal static let k: CGFloat = 0.5
	internal static let numberOfWaves = 6
	public var speed = 1
	
	public var tick: [Int] = Array(repeating: 0, count: SiriQueryView.numberOfWaves)
	public var tickLimit: [Int] = Array(repeating: 0, count: SiriQueryView.numberOfWaves)
	public var amp: [CGFloat] = Array(repeating: 0, count: SiriQueryView.numberOfWaves)
	public var pos: [CGFloat] = Array(repeating: 0, count: SiriQueryView.numberOfWaves)
	public var colors: [[CGFloat]] = Array(repeating: Array(repeating: 0, count: 4), count: SiriQueryView.numberOfWaves)
	
	public var volumn: CGFloat = 0.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	private var animator: LinearAnimator?;
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		generateRandomTick()
		for i in 0..<SiriQueryView.numberOfWaves {
			generateRandomPos(at: i)
		}
		//refreshView()
	}
	
	public func start() {
		guard animator == nil else {
			return
		}
		animator = LinearAnimator()
		animator?.delegate = self
		animator?.start()
	}
	
	public func stop() {
		guard let animator = animator else {
			return
		}
		animator.stop()
		animator.delegate = nil
		self.animator = nil
	}
	
	internal func commonRandom(at i: Int) {
		tickLimit[i] = Int.random(in: 0..<Int.max) % 10 + 41
		amp[i] = CGFloat(Int32.positiveRandom) * 0.5 / cgRandMax + 0.5
		let index = Int(Int32.positiveRandom) % SiriQueryView.numberOfWaves
		for j in 0..<3 {
			colors[i][j] = SiriQueryView.colors[index][j]
		}
		colors[i][3] = CGFloat.random(in: 102...153)
	}
	
	internal func generateRandomTick() {
		for i in 0..<SiriQueryView.numberOfWaves {
			commonRandom(at: i)
			tick[i] = Int(Int32.positiveRandom) % tickLimit[i]
		}
	}
	
	internal func generateRandomPos(at index: Int) {
		let width = bounds.size.width
		pos[index] = (CGFloat(Int32.positiveRandom) - CGFloat(RAND_MAX) * 0.5) * CGFloat(width) * 0.5 / CGFloat(RAND_MAX)
	}
	
	internal func nextState() {
		for i in 0..<SiriQueryView.numberOfWaves {
			tick[i] += speed
			guard tick[i] >= tickLimit[i] else {
				continue
			}
			tick[i] = 0
			commonRandom(at: i)
			generateRandomPos(at: i)
		}
	}
	
//	@objc public func refreshView() {
//		setNeedsDisplay()
//		// CADisplay link :/
//		perform(#selector(refreshView), with: nil, afterDelay: 0.02)
//	}
	
	internal func yPos(at x: CGFloat, index: Int) -> CGFloat {
		var gfn = pow(SiriQueryView.k / (SiriQueryView.k + pow(x, 2)), 2)
		gfn *= CGFloat(sin(Double.pi * (0.5 + Double(tick[index])) / Double(tickLimit[index])))
		return max(0, gfn) * bounds.size.height / 2.0
	}
	
	internal func drawOneWave(at index: Int, sign: Int) {
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		let width = bounds.size.width
		let height = bounds.size.height
		context.saveGState()
		let path = CGMutablePath()
		let x: CGFloat = 0
		let y: CGFloat = height / 2.0
		path.move(to: CGPoint(x: x + pos[index], y: y))
		
		for d in stride(from: -3.0, to: 3.0, by: 0.01) {
			let yPos = self.yPos(at: CGFloat(d), index: index)
			
			let step1 = x + pos[index]
			let step2 = CGFloat(3 + d)
			let step3 = width / 6.0

			let xValue = step1 + step2 * step3
			
			let yValue = y - yPos * CGFloat(sign) * amp[index] * volumn
			path.addLine(to: CGPoint(x: xValue, y: yValue))
		}
		path.closeSubpath()
		context.addPath(path)
		context.clip()

//		let components: [CGFloat] = [
//			1.0, 1.0, 1.0, 0.8,
//			colors[index][0] / 256.0, colors[index][1] / 256.0, colors[index][2] / 256.0, 0.6,
//			colors[index][0] / 256.0, colors[index][1] / 256.0, colors[index][2] / 256.0, 0.4
//		]
//		let colorSpace = CGColorSpaceCreateDeviceRGB()
//		let locations: [CGFloat] = [0.5, 0.05, 1.0]
//		guard let gradient = CGGradient(colorSpace: colorSpace,
//																		colorComponents: components,
//																		locations: locations,
//																		count: 3) else {
//																			fatalError("Could not create gradient")
//		}
//
//		let startPoint = CGPoint(x: width / 2, y: height / 2)
//		let endPoint = CGPoint(x: width / 2, y: height / 2 - (height * CGFloat(sign) / 2))
//		context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

//		let alpha = CGFloat.random(in: 0.4...0.6)
		
		let delta = min(1, max(0, amp[index] * volumn))
		let alpha = 1 - min(1, max(0, (colors[index][3] / 256.0) * delta))
		let color = UIColor(red: colors[index][0] / 256.0, green: colors[index][1] / 256.0, blue: colors[index][2] / 256.0, alpha: alpha)
		color.setFill()
		context.fill(CGRect(x: 0, y: 0, width: width, height: height))
		context.restoreGState()
	}
	
	func drawOneWave(at index: Int) {
		drawOneWave(at: index, sign: 1)
		drawOneWave(at: index, sign: -1)
	}
	
	public override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		context.clear(rect)
		for wave in 0..<SiriQueryView.numberOfWaves {
			drawOneWave(at: wave)
		}

		//nextState()
	}
	
}

extension SiriQueryView: LinearAnimatorDelegate {
	
	public func didTick(Animator: LinearAnimator) {
		nextState()
		setNeedsDisplay()
	}
	
}

public extension UIColor {
	public func colorWithBrightness(brightness: CGFloat) -> UIColor {
		var H: CGFloat = 0, S: CGFloat = 0, B: CGFloat = 0, A: CGFloat = 0
		
		if getHue(&H, saturation: &S, brightness: &B, alpha: &A) {
			B += (brightness - 1.0)
			B = max(min(B, 1.0), 0.0)
			
			return UIColor(hue: H, saturation: S, brightness: B, alpha: A)
		}
		
		return self
	}
}

extension UIColor {
	func brighten(by factor: CGFloat) -> UIColor {
		var fRed : CGFloat = 0
		var fGreen : CGFloat = 0
		var fBlue : CGFloat = 0
		var fAlpha: CGFloat = 0
		if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
			fRed = min(1.0, max(0, fRed + (1.0 * factor)))
			fGreen = min(1.0, max(0, fGreen + (1.0 * factor)))
			fBlue = min(1.0, max(0, fBlue + (1.0 * factor)))
			return UIColor(red: fRed, green: fGreen, blue: fBlue, alpha: fAlpha)
		}
		return self
	}
	
	func brighten(by factor: Double) -> UIColor {
		return brighten(by: CGFloat(factor))
	}
}
