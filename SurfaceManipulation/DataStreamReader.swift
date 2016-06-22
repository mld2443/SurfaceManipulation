// Source from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
// Modified By Matthew Dillard

import Foundation

public class DataStreamReader {
	
	let encoding: UInt
	let chunkSize: Int
	
	let rawData: NSData
	let buffer: NSMutableData!
	let delimData: NSData
	internal var location: Int = 0
	internal var atEOF: Bool = false
	
	public init?(data: NSData, delimiter: String = "\n", encoding : UInt = NSUTF8StringEncoding, chunkSize : Int = 4096) {
		self.chunkSize = chunkSize
		self.encoding = encoding
		
		self.rawData = data
		
		if let delimData = delimiter.dataUsingEncoding(encoding),
			buffer = NSMutableData(capacity: chunkSize) {
			self.delimData = delimData
			self.buffer = buffer
		} else {
			return nil
		}
	}
	
	/// Return next line, or nil on EOF.
	public func nextLine() -> String? {
		if atEOF {
			return nil
		}
		
		// Read data chunks from file until a line delimiter is found:
		var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
		while range.location == NSNotFound {
			let bytesLeft = rawData.length - location
			let unformattedData = rawData.subdataWithRange(NSMakeRange(location, chunkSize < bytesLeft ? chunkSize : bytesLeft))
			location = location + unformattedData.length
			
			if unformattedData.length == 0 {
				// EOF or read error.
				atEOF = true
				
				if buffer.length == 0 {
					// No more lines.
					return nil
				}
				
				// Buffer contains last line in file (not terminated by delimiter).
				let line = String(data: buffer, encoding: encoding)
				
				buffer.length = 0
				return line
			}
			
			buffer.appendData(unformattedData)
			range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
		}
		
		// Convert complete line (excluding the delimiter) to a string:
		let line = String(data: buffer.subdataWithRange(NSMakeRange(0, range.location)), encoding: encoding)
		
		// Remove line (and the delimiter) from the buffer:
		buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
		
		return line
	}
	
	/// Start reading from the beginning of file.
	public func rewind() {
		location = 0
		buffer.length = 0
		atEOF = false
	}
}
