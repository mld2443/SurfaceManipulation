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
	let device: MTLDevice
	
	var delegate: MetalControllerDelegate!
	
	var vertexBuffer: MTLBuffer! = nil
	var indexBuffer: MTLBuffer! = nil
	
	var pipelineState: MTLRenderPipelineState! = nil
	var commandQueue: MTLCommandQueue! = nil
	
	init?(device: MTLDevice! = MTLCreateSystemDefaultDevice()) {
		if device == nil {
			return nil
		}
		
		self.device = device
		
		super.init()
		
		let defaultLibrary = self.device.newDefaultLibrary()
		let fragmentProgram = defaultLibrary!.newFunctionWithName("fragmentShader")
		let vertexProgram = defaultLibrary!.newFunctionWithName("vertexShader")
		
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = vertexProgram
		pipelineStateDescriptor.fragmentFunction = fragmentProgram
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
		
		do {
			try pipelineState = self.device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
		} catch let error {
			print("Failed to create pipeline state, error \(error)")
			return nil
		}
		
		if self.pipelineState == nil {
			print("Failed to create pipeline state, error unknown")
			return nil
		}
		
		self.commandQueue = self.device.newCommandQueue()
	}
	
	func drawInMTKView(view: MTKView) {
//		let vertices = delegate.getVertices()
//		
//		let dataSize = vertices.count * sizeof(float4)
//		vertexBuffer = device.newBufferWithBytes(vertices, length: dataSize, options: .CPUCacheModeDefaultCache)
		
	}
	
	func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
		
	}
}
