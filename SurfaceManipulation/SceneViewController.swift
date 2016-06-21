//
//  SceneViewController.swift
//  Subdivision
//
//  Created by Matthew Dillard on 6/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import SceneKit
import QuartzCore

class SceneViewController: NSViewController {
	
	var document: Document?

	@IBOutlet weak var sceneView: SceneView!
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		// identify over the document
		let view = self.view
		let window = view.window
		let windowController = window?.windowController
		document = windowController?.document as? Document
		
		// create a new scene
		let scene = SCNScene()
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLightTypeOmni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = NSColor.darkGrayColor()
		scene.rootNode.addChildNode(ambientLightNode)
		
		// define my own custom shape
		if let mesh = document?.shape {
			let shape = SCNNode(geometry: mesh.generateSCNGeometry())
			scene.rootNode.addChildNode(shape)
			
			// animate the 3d object
			let animation = CABasicAnimation(keyPath: "rotation")
			animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
			animation.duration = 3
			animation.repeatCount = MAXFLOAT //repeat forever
			shape.addAnimation(animation, forKey: nil)
		}
		
		// set the scene to the view
		self.sceneView!.scene = scene
		
		// allows the user to manipulate the camera
		self.sceneView!.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		self.sceneView!.showsStatistics = true
		
		// configure the view
		self.sceneView!.backgroundColor = NSColor.blackColor()
	}
}
