import SceneKit
import simd

public class Halfedge {
	var next: Halfedge?, prev: Halfedge?, flip: Halfedge?
	var f: Face
	var e: Edge
	var o: Vertex
	
	public lazy var p: float3 = self.o.pos
	
	public init(f: Face, e: Edge, o: Vertex, next: Halfedge? = nil, prev: Halfedge? = nil, flip: Halfedge? = nil) {
		self.f = f
		self.e = e
		self.o = o
		self.next = next
		self.prev = prev
		self.flip = flip
	}
}

public class Vertex {
	var pos: float3
	var he: Halfedge?
	
	public init(pos: float3) {
		self.pos = pos
	}
	
	public lazy var neighborhood: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.he!
		repeat {
			neighbors.append(trav.flip!.o)
			trav = trav.flip!.next!
		} while trav !== self.he!
		
		return neighbors
	}()
	
	public lazy var valence: Int = self.neighborhood.count
}

public class Edge {
	var he: Halfedge?
	
	public var midpoint: float3 {
		return mix(he!.p, he!.flip!.p, t: 0.5)
	}
}

public class Face {
	var he: Halfedge?

	public lazy var normal: float3 = ((self.he!.next!.next!.p - self.he!.p) ⨯ (self.he!.prev!.p - self.he!.next!.p)).unit
	
	public lazy var centroid: float3 = {
		var center = float3()
		
		var trav = self.he!
		repeat {
			center += trav.p
			trav = trav.next!
		} while trav !== self.he!
		
		return center
	}()
	
	public lazy var vertices: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.he!
		repeat {
			neighbors.append(trav.o)
			trav = trav.next!
		} while trav !== self.he!
		
		return neighbors
	}()
}

extension Face {
	public func generateVeticesAndNormal() -> ([SCNVector3],SCNVector3) {
		return (vertices.map({ SCNVector3($0.pos.x, $0.pos.y, $0.pos.z) }), SCNVector3(normal.x, normal.y, normal.z))
	}
}


extension Vertex {
	public var data : NSData? {
		let value = "v \(pos.x) \(pos.y) \(pos.z)\n"
		
		return value.dataUsingEncoding(NSUTF8StringEncoding)
	}
}

extension Face {
	public var data : NSMutableData {
		return NSMutableData()
	}
}


// MARK: Hashable stuff
extension Vertex: Hashable {
	public var hashValue: Int { return pos.hashValue }
}

public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
	return lhs.pos == rhs.pos
}
