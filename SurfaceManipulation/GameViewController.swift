//
//  GameViewController.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/30/16.
//  Copyright (c) 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import MetalKit
import simd

let vertexData:[float4] = [
	float4(-1.0, -1.0, 0.0, 1.0),
	float4(-1.0,  1.0, 0.0, 1.0),
	float4(1.0, -1.0, 0.0, 1.0),
	
	float4(1.0, -1.0, 0.0, 1.0),
	float4(-1.0,  1.0, 0.0, 1.0),
	float4(1.0,  1.0, 0.0, 1.0),
	
	float4(-0.0, 0.25, 0.0, 1.0),
	float4(-0.25, -0.25, 0.0, 1.0),
	float4(0.25, -0.25, 0.0, 1.0),
]

let vertexColorData:[float4] = [
	float4(0.0, 0.0, 0.0, 1.0),
	float4(0.0, 0.0, 0.0, 1.0),
	float4(0.0, 0.0, 0.0, 1.0),
	
	float4(0.0, 0.0, 0.0, 1.0),
	float4(0.0, 0.0, 0.0, 1.0),
	float4(0.0, 0.0, 0.0, 1.0),
	
	float4(0.0, 0.0, 1.0, 1.0),
	float4(0.0, 1.0, 0.0, 1.0),
	float4(1.0, 0.0, 0.0, 1.0),
]

class GameViewController: NSViewController, MetalControllerDelegate {
	var document: Document?
	
	let metalController: MetalController! = MetalController()
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// identify the document
		document = self.view.window?.windowController?.document as? Document
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard metalController != nil else {
			let view = NSTextView(frame: self.view.frame)
			view.string = "Metal cloud not configure properly."
			view.editable = false
			view.selectable = false
			view.drawsBackground = false
			
			self.view = view
			return
		}
		
		self.metalController.delegate = self
		
		// setup view properties
		let view = self.view as! MTKView
		view.delegate = self.metalController
		view.device = self.metalController.device
		view.sampleCount = 4
	}
	
	func getVertices() -> [float4] {
		return vertexData
	}
}
