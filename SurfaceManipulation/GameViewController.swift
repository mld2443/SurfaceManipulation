//
//  GameViewController.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/30/16.
//  Copyright (c) 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
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
		
		// identify over the document
		let view = self.view
		let window = view.window
		let windowController = window?.windowController
		document = windowController?.document as? Document
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard metalController != nil else { // Fallback to a blank NSView, an application could also fallback to OpenGL here.
			print("Metal is not supported on this device")
			self.view = NSView(frame: self.view.frame)
			return
		}
	}
	
	func getVertices() -> [float4] {
		return vertexData
	}
}
