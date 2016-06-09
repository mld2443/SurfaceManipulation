//
//  Document.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

enum FileIOError: ErrorType {
	case InvalidFileEncoding
	case InvalidManifold
}

class Document: NSDocument {
	var shape = Manifold()
	
	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

	override class func autosavesInPlace() -> Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
		self.addWindowController(windowController)
	}

	override func dataOfType(typeName: String) throws -> NSData {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func readFromData(data: NSData, ofType typeName: String) throws {
		guard let shape = Manifold(data: data) else {
			throw FileIOError.InvalidFileEncoding
		}
		
		if !shape.valid {
			throw FileIOError.InvalidManifold
		}
		
		self.shape = shape
	}
}

