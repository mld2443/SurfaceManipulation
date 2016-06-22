//
//  Mesh.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import SceneKit
import simd

struct UnorderedPair<T: protocol<Hashable, Comparable>> {
	let a, b: T
	
	init(a: T, b: T) {
		if a < b {
			self.a = a
			self.b = b
		} else {
			self.a = b
			self.b = a
		}
	}
}

extension UnorderedPair: Hashable {
	var hashValue : Int { return a.hashValue &* 31 &+ b.hashValue }
}

// comparison function for conforming to Equatable protocol
func ==<T>(lhs: UnorderedPair<T>, rhs: UnorderedPair<T>) -> Bool {
	return lhs.a == rhs.a && lhs.b == rhs.b
}


/// A mesh is responsible for creating and manipulating a complex web of
/// halfedges using surface simplification and subdivision algorithms.
public class Mesh {
	internal var faces = [Face]()
	internal var edges = [Edge]()
	internal var vertices = [Vertex]()
	internal var halfedges = [Halfedge]()
	internal var AABB = (min: float3(), max: float3())
	
	lazy var center: float3 = {
		return mix(self.AABB.min, self.AABB.max, t: 0.5)
	}()
	
	internal var edgeHash = Dictionary<UnorderedPair<Int>, (edge: Edge, count: Int)>()
	
	/// Tells us if the mesh has any faces which are incomplete
	public lazy var valid: Bool = {
		for face in self.faces {
			if face.halfedge == nil {
				return false
			}
			
			var edge = face.halfedge!
			
			repeat {
				if edge.face !== face {
					return false
				}
				
				edge = edge.next!
			} while edge !== face.halfedge!
		}
		
		return true
	}()
	
	public lazy var polyhedralFormula: Int = {
		return self.vertices.count + self.faces.count - self.edges.count
	}()
	
	/// Indicates whether the surface is a topological 2-manifold (within reason)
	public lazy var manifold: Bool = {
		if !self.valid {
			return false
		}
		
		for (hash, (edge: _, count: count)) in self.edgeHash {
			if count != 2 {
				return false
			}
		}
		
		for vertex in self.vertices {
			if vertex.halfedge == nil {
				return false
			}
			if vertex.halfedge!.vertex !== vertex {
				return false
			}
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
			if edge.halfedge == nil {
				return false
			}
			if edge.halfedge!.edge !== edge {
				return false
			}
			if edge.halfedge!.flip!.edge !== edge {
				return false
			}
		}
		
		if self.polyhedralFormula != 2 {
			return false
		}
		
		return true
	}()
	
	/// Builds an empty mesh
	public init() { }
	
	/// Load a mesh from NSData
	/// - parameters:
	///   - data: OBJ formatted
	///   - scale: Multiple with which to scale the loaded object
	public init?(data: NSData, scale: Float = 1.0) {
		guard let stream = DataStreamReader(data: data, chunkSize: 16) else {
			return nil
		}
		
		while let line = stream.nextLine() {
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
				
			else if line.hasPrefix("f ") {
				var vertexList = [Vertex]()
				let start = line.startIndex.advancedBy(1), end = line.endIndex
				let stringIndices = line[start..<end].trim.componentsSeparatedByString(" ")
				let cleanedIndices = stringIndices.map({ $0.cutOffAfterString("/") })
				let indices = cleanedIndices.map({ Int($0)! - 1 })
				
				for index in indices {
					vertexList.append(vertices[index])
				}
				
				addFace(vertexList)
			}
				
			else if line.trim != "" {
				return nil
			}
		}
	}
	
	/// Adds a single face and associated halfedges (and edges where necessary).
	internal func addFace(vertexList: [Vertex]) {
		/// Checks if there exists an edge between two vertices already,
		/// returns existing edge if so, or creates one and returns it.
		func getEdge(v1: Vertex, _ v2: Vertex) -> Edge {
			let hashValue = UnorderedPair(a: v1.hashValue, b: v2.hashValue)
			
			if let entry = edgeHash[hashValue] {
				edgeHash[hashValue] = (entry.edge, entry.count + 1)
				return entry.edge
			}
			
			edges.append(Edge())
			edgeHash[hashValue] = (edges.last!, 1)
			
			return edges.last!
		}
		
		let rotatedList: [Vertex] = vertexList.dropFirst() + [vertexList.first!]
		
		faces.append(Face())
		
		var first: Halfedge?, prev: Halfedge?
		
		for (v1, v2) in zip(vertexList, rotatedList) {
			let edge = getEdge(v1, v2)
			
			halfedges.append(Halfedge(face: faces.last!, edge: edge, vertex: v1, prev: prev, flip: edge.halfedge))
			
			if v1 !== vertexList.first! {
				prev!.next = halfedges.last!
			}
			
			edge.halfedge?.flip = halfedges.last!
			
			prev = halfedges.last
			edge.halfedge = prev!
			
			if v1 === vertexList.first! {
				first = prev
			}
			
			prev!.vertex.halfedge = prev
		}
		
		prev!.next = first
		faces.last!.halfedge = first!
		first!.prev = halfedges.last
	}
}

extension Mesh {
	/// Generates a sceneKit geometry object for drawing a mesh in SceneKit
	public func generateSCNGeometry() -> SCNGeometry {
		var points: [SCNVector3] = []
		var normalVectors: [SCNVector3] = []
		
		var scnFaces: [SCNGeometryElement] = []
		
		for face in faces {
			let startIndex = points.count
			
			let (facePoints, normal) = face.generateVeticesAndNormal()
			let count = facePoints.count
			points.appendContentsOf(facePoints)
			normalVectors.appendContentsOf([SCNVector3](count: count, repeatedValue: normal))
			
			var indices: [CInt] = []
			var step = 0
			
			// Scenekit makes this needlessly complicated, my points come in order, but to get
			// the triangles to draw correctly, I need to shuffle back and forth like this.
			for index in 0..<count {
				if index % 2 == 0 {
					indices.append(CInt(startIndex + count - step - 1))
				}
				else {
					indices.append(CInt(startIndex + step))
					step = step + 1
				}
			}
			
			scnFaces.append(SCNGeometryElement(indices: indices, primitiveType: .TriangleStrip))
		}
		
		let scnVertices = SCNGeometrySource(vertices: points, count: points.count)
		let scnNormals = SCNGeometrySource(vertices: normalVectors, count: normalVectors.count)
		
		return SCNGeometry(sources: [scnVertices, scnNormals], elements: scnFaces)
	}
}

extension Mesh {
	/// Generates an output data file for saving a mesh to disk.
	public var data : NSMutableData {
		let meshData = NSMutableData()
		
		meshData.appendData("# \(vertices.count) vertices, \(faces.count) faces\n".dataUsingEncoding(NSUTF8StringEncoding)!)
		
		var index = 1
		var backTrace: [Vertex : Int] = [:]
		
		for vertex in vertices {
			guard let vertexData = vertex.data else {
				print("Error on vertex \(index)")
				return NSMutableData()
			}
			
			meshData.appendData(vertexData)
			backTrace[vertex] = index
			index = index + 1
		}
		
		for face in faces {
			var output = "f"
			
			for vertex in face.vertices {
				output += " \(backTrace[vertex]!)"
			}
			
			output += "\n"
			
			meshData.appendData(output.dataUsingEncoding(NSUTF8StringEncoding)!)
		}
		
		return meshData
	}
}
