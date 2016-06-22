//
//  Extensions.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/15/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

// MARK: float3
extension float3 {
	/// Absolute value of a Vector
	/// - Returns: √(x² + y² + z²)
	public var length: Float {
		return simd.length(self)
	}
	
	/// Normalizes a vector
	/// - Returns: unit length vector
	public var unit: float3 {
		return normalize(self)
	}
}

extension float3: CustomStringConvertible {
	public var description: String { return String(format: "(%.3f, %.3f, %.3f)", x, y, z) }
}

extension float3: Hashable {
	public var hashValue: Int { return "\(x),\(y),\(z)".hashValue }
}

public func randomInUnitSphere() -> float3 {
	var p = float3()
	repeat {
		p = 2.0 * float3(Float(drand48()), Float(drand48()), Float(drand48())) - float3(1, 1, 1)
	} while p == float3(0,0,0)
	return p.unit
}


// MARK: float3 Operators
public func /(lhs: float3, rhs: Float) -> float3 { return float3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs) }
public func ==(lhs: float3, rhs: float3) -> Bool { return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z }

infix operator • { associativity left precedence 150 }
/// Dot product of two vectors
public func •(lhs: float3, rhs: float3) -> Float { return dot(lhs, rhs) }

infix operator ⨯ { associativity left precedence 150 }
/// Cross product of two vectors
public func ⨯(lhs: float3, rhs: float3) -> float3 { return cross(lhs, rhs) }


// MARK: String
extension String {
	public var trim: String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
	public func cutOffAfterString(marker: String) -> String {
		return self.substringToIndex(self.rangeOfString(marker)?.indices.first ?? self.endIndex)
	}
}


// MARK: NSImage
extension NSImage {
	public var imagePNGRepresentation: NSData {
		return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
	}
	public func savePNG(path:String) -> Bool {
		return imagePNGRepresentation.writeToFile(path, atomically: true)
	}
}
