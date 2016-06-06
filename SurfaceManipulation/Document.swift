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
	case InvalidFileFormat(unexpectedToken: String)
}

class Document: NSDocument {
	internal var faces = [Face]()
	internal var edges = [Edge]()
	internal var vertices = [Vertex]()
	internal var halfedges = [Halfedge]()
	internal var AABB = (min: float3(), max: float3())
	
	lazy var center: float3 = {
		return mix(self.AABB.min, self.AABB.max, t: 0.5)
	}()
	
	internal var edgeHash = [Int: Edge]()
	
	lazy var valid: Bool = {
		for vertex in self.vertices {
			if vertex.he == nil {
				return false
			}
			if vertex.he!.o !== vertex {
				return false
			}
		}
		
		for face in self.faces {
			if face.he == nil {
				return false
			}
			
			var edge = face.he!
			
			repeat {
				if edge.f !== face {
					return false
				}
				
				edge = edge.next!
			} while edge !== face.he!
		}
		
		for halfedge in self.halfedges {
			if halfedge.next == nil {
				return false
			}
			if halfedge.prev == nil {
				return false
			}
			if halfedge.flip == nil {
				return false
			}
			if halfedge.flip!.flip! !== halfedge {
				return false
			}
		}
		
		for edge in self.edges {
			if edge.he == nil {
				return false
			}
			if edge.he!.e !== edge {
				return false
			}
			if edge.he!.flip!.e !== edge {
				return false
			}
		}
		
		return true
	}()
	
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
		guard let dataString = String(data: data, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n") else {
			throw FileIOError.InvalidFileEncoding
		}
		
		for line in dataString {
			// check if the line is a comment
			if line.hasPrefix("#") {
			}
				
			// Check for vertices
			else if line.hasPrefix("v ") {
				let start = line.startIndex.advancedBy(1), end = line.endIndex
				let values = line[start..<end].trim.componentsSeparatedByString(" ").map({ Float($0)! })
				
				assert(values.count == 3)
				
				let x = values[0], y = values[1], z = values[2]
				
				if x < AABB.min.x {
					AABB.min.x = x
				} else if x > AABB.max.x {
					AABB.max.x = x
				}
				
				if y < AABB.min.y {
					AABB.min.y = y
				} else if y > AABB.max.y {
					AABB.max.y = y
				}
				
				if z < AABB.min.z {
					AABB.min.z = z
				} else if z > AABB.max.z {
					AABB.max.z = z
				}
				
				vertices.append(Vertex(pos: float3(x, y, z)))
			}
				
			else if line.hasPrefix("vn ") { }
				
			else if line.hasPrefix("vt ") { }
				
			else if line.hasPrefix("vp ") { }
				
			// Check for faces
			else if line.hasPrefix("f ") {
				var vertexList = [Vertex]()
				let start = line.startIndex.advancedBy(1), end = line.endIndex
				let indices = line[start..<end].trim.componentsSeparatedByString(" ").map({ Int($0)! - 1 })
				
				for index in indices {
					vertexList.append(vertices[index])
				}
				
				addFace(vertexList)
			}
			
			else if line.trim != "" {
				throw FileIOError.InvalidFileFormat(unexpectedToken: line)
			}
		}
	}

	internal func addFace(vertexList: [Vertex]) {
		func getEdge(v1: Vertex, _ v2: Vertex) -> Edge {
			let hashValue = v1.hashValue ^ v2.hashValue
			
			if let edge = edgeHash[hashValue] {
				return edge
			}
			
			edges.append(Edge())
			edgeHash[hashValue] = edges.last!
			
			return edges.last!
		}
		
		let rotatedList: [Vertex] = vertexList.dropFirst() + [vertexList.first!]
		
		faces.append(Face())
		
		var first: Halfedge?, prev: Halfedge?
		
		for (this, next) in zip(vertexList, rotatedList) {
			let e = getEdge(this, next)
			
			halfedges.append(Halfedge(f: faces.last!, e: e, o: this, prev: prev, flip: e.he))
			
			if this !== vertexList.first! {
				prev!.next = halfedges.last!
			}
			
			if e.he != nil {
				e.he!.flip = halfedges.last!
			}
			
			prev = halfedges.last
			e.he = prev!
			
			if this === vertexList.first! {
				first = prev
			}
			
			prev!.o.he = prev
		}
		
		prev!.next = first
		faces.last!.he = halfedges.last
		first!.prev = halfedges.last
	}
}

