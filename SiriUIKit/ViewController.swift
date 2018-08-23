//
//  ViewController.swift
//  SiriUIKit
//
//  Created by Shane Whitehead on 23/8/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var siriQueryView: SiriQueryView!
	@IBOutlet weak var slider: UISlider!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		siriQueryView.volumn = 0.05
	}
	
	@IBAction func sliderChanged(_ sender: Any) {
		siriQueryView.volumn = CGFloat(slider.value)
	}
}

