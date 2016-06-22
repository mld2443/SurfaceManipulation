//
//  Halfedge.swift
//  SurfaceManipulation
//
//  Created by Matthew Dillard on 6/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

// for information on the Halfedge data structure: https://en.wikipedia.org/wiki/Doubly_connected_edge_list

import SceneKit
import simd

public class Halfedge {
	var next: Halfedge?, prev: Halfedge?, flip: Halfedge?
	var face: Face
	var edge: Edge
	var vertex: Vertex
	
	public lazy var point: float3 = self.vertex.pos
	
	public init(face: Face, edge: Edge, vertex: Vertex, next: Halfedge? = nil, prev: Halfedge? = nil, flip: Halfedge? = nil) {
		self.face = face
		self.edge = edge
		self.vertex = vertex
		self.next = next
		self.prev = prev
		self.flip = flip
	}
}


public class Vertex {
	var pos: float3
	var halfedge: Halfedge?
	
	public init(pos: float3) {
		self.pos = pos
	}
	
	public lazy var neighborhood: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.halfedge!
		repeat {
			neighbors.append(trav.flip!.vertex)
			trav = trav.flip!.next!
		} while trav !== self.halfedge!
		
		return neighbors
	}()
	
	public lazy var valence: Int = self.neighborhood.count
}

extension Vertex {
	/// Formats vertex data for output to a file.
	public var data : NSData? {
		let value = "v \(pos.x) \(pos.y) \(pos.z)\n"
		
		return value.dataUsingEncoding(NSUTF8StringEncoding)
	}
}


public class Edge {
	var halfedge: Halfedge?
	
	public var midpoint: float3 {
		return mix(halfedge!.point, halfedge!.flip!.point, t: 0.5)
	}
}


public class Face {
	var halfedge: Halfedge?

	public lazy var normal: float3 = ((self.halfedge!.next!.next!.point - self.halfedge!.point) ⨯ (self.halfedge!.prev!.point - self.halfedge!.next!.point)).unit
	
	public lazy var centroid: float3 = {
		var center = float3()
		
		var trav = self.halfedge!
		repeat {
			center += trav.point
			trav = trav.next!
		} while trav !== self.halfedge!
		
		return center
	}()
	
	public lazy var vertices: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.halfedge!
		repeat {
			neighbors.append(trav.vertex)
			trav = trav.next!
		} while trav !== self.halfedge!
		
		return neighbors
	}()
}

extension Face {
	/// Converts vertices and normal vector from native SIMD types to SceneKit types.
	public func generateVeticesAndNormal() -> ([SCNVector3],SCNVector3) {
		return (vertices.map({ SCNVector3($0.pos.x, $0.pos.y, $0.pos.z) }), SCNVector3(normal.x, normal.y, normal.z))
	}
}


// MARK: Hashable stuff
extension Vertex: Hashable {
	public var hashValue: Int { return ObjectIdentifier(self).hashValue }
}

public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
	return lhs.pos == rhs.pos
}
