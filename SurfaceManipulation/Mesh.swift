import Foundation
import SceneKit
import simd

public class Mesh {
	internal var faces = [Face]()
	internal var edges = [Edge]()
	internal var vertices = [Vertex]()
	internal var halfedges = [Halfedge]()
	internal var AABB = (min: float3(), max: float3())
	
	lazy var center: float3 = {
		return mix(self.AABB.min, self.AABB.max, t: 0.5)
	}()
	
	internal var edgeHash = [Int: Edge]()
	
	public lazy var valid: Bool = {
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
		
		return true
	}()
	
	public lazy var manifold: Bool = {
		if !self.valid {
			return false
		}
		
		for vertex in self.vertices {
			if vertex.he == nil {
				return false
			}
			if vertex.he!.o !== vertex {
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
	
	public init() { }
	
	public init?(data: NSData, scale: Float = 1.0) {
		guard let dataString = String(data: data, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString("\n") else {
			return nil
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
				return nil
			}
		}
	}
	
	internal func addFace(vertexList: [Vertex]) {
		/// Checks if there exists an edge between two vertices already,
		/// returns existing edge if so, or creates one and returns it.
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
		
		for (v1, v2) in zip(vertexList, rotatedList) {
			let e = getEdge(v1, v2)
			
			halfedges.append(Halfedge(f: faces.last!, e: e, o: v1, prev: prev, flip: e.he))
			
			if v1 !== vertexList.first! {
				prev!.next = halfedges.last!
			}
			
			e.he?.flip = halfedges.last!
			
			prev = halfedges.last
			e.he = prev!
			
			if v1 === vertexList.first! {
				first = prev
			}
			
			prev!.o.he = prev
		}
		
		prev!.next = first
		faces.last!.he = first!
		first!.prev = halfedges.last
	}
}

extension Mesh {
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
