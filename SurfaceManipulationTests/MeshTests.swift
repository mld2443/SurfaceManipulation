//
//  MeshTests.swift
//  SurfaceManipulationTests
//
//  Created by Matthew Dillard on 6/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import XCTest
@testable import SurfaceManipulation

class MeshTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func fetchFileFromBundle(file: String, type: String) -> NSData {
		guard let location =  NSBundle(forClass: self.dynamicType).pathForResource(file, ofType: type) else {
			XCTFail("Could not find file \"\(file).\(type)\"")
			return NSData()
		}
		
		return NSData(contentsOfFile: location)!
	}
	
	func testLoadIcosahedron() {
		let data = fetchFileFromBundle("icosahedron", type: "obj")
		let mesh = Mesh(data: data)
		
		XCTAssertNotNil(mesh, "Could not parse data")
		XCTAssert(mesh!.manifold, "File failed to load properly")
	}
	
	func testLoadDodecahedron() {
		let data = fetchFileFromBundle("dodecahedron", type: "obj")
		let mesh = Mesh(data: data)
		
		XCTAssertNotNil(mesh, "Could not parse data")
		XCTAssert(mesh!.manifold, "File failed to load properly")
	}
	
	func testLoadArmadilloPerformance() {
		let data = fetchFileFromBundle("armadillo", type: "obj")
		
		self.measureBlock {
			let mesh = Mesh(data: data)
			
			XCTAssertNotNil(mesh, "Could not parse data")
			XCTAssert(mesh!.manifold, "File failed to load properly")
		}
	}
}
