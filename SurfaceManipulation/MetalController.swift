//
//  MetalController.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 7/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd
import MetalKit

protocol MetalControllerDelegate {
	func getVertices() -> [float4]
}

class MetalController: NSObject, MTKViewDelegate {
	let device: MTLDevice!
	
	init?(device: MTLDevice! = MTLCreateSystemDefaultDevice()) {
		if device == nil {
			return nil
		}
		
		self.device = device
	}
	
	func drawInMTKView(view: MTKView) {
		
	}
	
	func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
		
	}
}
