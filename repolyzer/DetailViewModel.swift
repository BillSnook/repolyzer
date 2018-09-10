//
//  DetailViewModel.swift
//  repolyzer
//
//  Created by William Snook on 9/8/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import Foundation


struct LineAddresses {
	var addLine = 0
	var addSize = 0
	var remLine = 0
	var remSize = 0
}

class GhostLine {
	var text = ""
	var show = false
	var add = false
	var remove = false
}

class DiffLines {
	var lineRange = ""
	var lines: [String] = []
}

class DiffArray {
	var leftLines: [GhostLine] = []
	var rightLines: [GhostLine] = []

	var lines: LineAddresses?
}

class DiffEntry {
	
	var fileName = ""
	var diffLines: [DiffLines] = []
	var diffArray: [DiffArray] = []
}

class DetailViewModel {
	
	let diffString: String
	var diffList: [DiffEntry] = []
	
	

	init( with diff: Data ) {
		diffString = String( data: diff, encoding: String.Encoding.utf8 ) ?? ""
		
		seperateFiles()
		for entry in diffList  {
			print( entry.fileName )
			for diffLine in entry.diffLines {
				print( diffLine.lineRange )
//				for line in diffLine.lines {
//					print( line )
//				}
			}
		}
		
		createDiffArrays()
	}
	
	func seperateFiles() {		// Break up diffString into strings for each file
		
		let fileArray = diffString.components(separatedBy: "diff --git ").filter {!$0.isEmpty}
		for file in fileArray {
			let diffEntry = DiffEntry()
			let diffArray = file.components(separatedBy: "\n@@ ")
			// First entry contains diff --git ..., remaining ones start with @@ -aa,b +cc,d @@
			// and contain lines of code to display
			var isFirstElement = true
			for diff in diffArray {			// Break up file-associated strings into filename section and diff sections
				if isFirstElement {			// We are only interested in the file name
					isFirstElement = false
					diffEntry.fileName = filenameFromSegment( diff )
					continue
				}
				let diffLine = DiffLines()	// Have line numbers and diff texts
				let diffLineArray = diff.components(separatedBy: "\n@@ ")
				if let firstLineSegment = diffLineArray.first {
					let firstLineArray = firstLineSegment.components(separatedBy: "\n")	// Get all lines
					if ( firstLineArray.count >= 1 ) {	// < -11,6 +11,7 > and rest of line then everything else from that diff sequence
						let secondLineArray = firstLineArray[0].components(separatedBy: " @@")	// Get just file diff range
						diffLine.lineRange = secondLineArray[0]
						for i in 1..<firstLineArray.count - 1 {				// Get remainder of lines
							diffLine.lines.append( firstLineArray[i] )
						}
					}
				}
				diffEntry.diffLines.append( diffLine )
			}
			diffList.append( diffEntry )
		}
	}
	
	func filenameFromSegment( _ rawFilenameString: String ) -> String {

		var firstArray = rawFilenameString.components(separatedBy: "\n--- a/")	// diff --git a/...
		if firstArray.count > 1 {
			let fileNamePlus = firstArray[1]	// Second component contains filename plus another line
			let secondArray = fileNamePlus.components(separatedBy: "\n")
			if secondArray.count > 0 {
				return secondArray[0]
			}
		} else {		// Maybe file was added
			firstArray = rawFilenameString.components(separatedBy: "\n+++ b/")	// diff --git a/...
			if firstArray.count > 1 {
				let fileNamePlus = firstArray[1]	// Second component contains filename plus another line
				let secondArray = fileNamePlus.components(separatedBy: "\n")
				if secondArray.count > 0 {
					return secondArray[0]
				}
			}
		}
		firstArray = rawFilenameString.components(separatedBy: "\nrename from ")
		if firstArray.count > 1 {
			let secondArray = firstArray[1].components(separatedBy: "\n")
			if secondArray.count > 0 {
				return "Rename " + secondArray[0]
			}
		}
		return "No Filename Found"
	}

	func getAddressesFromHeader( _ header: String ) -> LineAddresses {
		
		var lines = LineAddresses()
		var lineNumbers = header
		lineNumbers.remove(at: lineNumbers.startIndex)	// Remove initial '-'
		let lineNumArray = lineNumbers.components(separatedBy: " +")
		if lineNumArray.count == 2 {
			let removeArray = lineNumArray[0].components(separatedBy: ",")
			if removeArray.count == 2 {
				lines.remLine = Int( removeArray[0] ) ?? 0
				lines.remSize = Int( removeArray[1] ) ?? 0
			}
			let addArray = lineNumArray[1].components(separatedBy: ",")
			if addArray.count == 2 {
				lines.addLine = Int( addArray[0] ) ?? 0
				lines.addSize = Int( addArray[1] ) ?? 0
			}
		}
		print( "Remove: \(lines.remLine),\(lines.remSize); Add: \(lines.addLine),\(lines.addSize)" )
		return lines
	}

	func createDiffArrays() {
		
		for fileDiff in diffList  {					// For each file
			for diffLine in fileDiff.diffLines {	// For each diff segment for file
				let diffArray = DiffArray()
				let lineNumbers = getAddressesFromHeader( diffLine.lineRange )
				diffArray.lines = lineNumbers
				var addLineNo = Int( lineNumbers.addLine )
				var addSequence = 0
				var remLineNo = Int( lineNumbers.remLine )
				var remSequence = 0
				var inputIndex = 0
				var rightOutputIndex = 0
				var leftOutputIndex = 0
				print( "diffLine.lines.count: \(diffLine.lines.count)" )
				while inputIndex < diffLine.lines.count {	// Walk lines from input diff text
					print( "inputIndex: \(inputIndex)" )
					let entry = diffLine.lines[inputIndex]	// Get first line
					if entry.isEmpty {
						continue
					}
					if entry[entry.startIndex] == "-" {	// This is a removed line
						diffArray.leftLines.append( GhostLine() )
						let leftline = diffArray.leftLines[leftOutputIndex]
						leftline.text += String( remLineNo ) + "  " + entry + "\n"
						leftline.show = true
						leftline.remove = true
						leftOutputIndex += 1
						remLineNo += 1
						remSequence += 1
					} else {
						if entry[entry.startIndex] == "+" {	// This is an added line
							diffArray.rightLines.append( GhostLine() )
							let rightline = diffArray.rightLines[rightOutputIndex]
							rightline.text += String( addLineNo ) + "  " + entry + "\n"
							rightline.show = true
							rightline.add = true
							rightOutputIndex += 1
							addLineNo += 1
							if remSequence > 0 {
								remSequence -= 1
							} else {
								diffArray.leftLines.append( GhostLine() )
								let leftline = diffArray.leftLines[leftOutputIndex]
								leftline.text += String( remLineNo ) + "  " + entry + "\n"
								leftline.show = false
								leftOutputIndex += 1
							}
							addSequence += 1
						} else {
							diffArray.leftLines.append( GhostLine() )
							let leftline = diffArray.leftLines[leftOutputIndex]
							leftline.text += String( remLineNo ) + "  " + entry + "\n"
							leftline.show = true
							diffArray.rightLines.append( GhostLine() )
							let rightline = diffArray.rightLines[rightOutputIndex]
							rightline.text += String( addLineNo ) + "  " + entry + "\n"
							if remSequence > 0 {
								rightline.show = false
							} else {
								rightline.show = true
								addLineNo += 1
							}
							remLineNo += 1
							rightOutputIndex += 1
							leftOutputIndex += 1
							addSequence = 0
							if remSequence > 0 {
								diffArray.rightLines.append( GhostLine() )
								let rightline = diffArray.rightLines[rightOutputIndex]
								rightline.text += String( addLineNo ) + "  " + entry + "\n"
								rightline.show = true
								rightline.add = false
								rightOutputIndex += 1
								addLineNo += 1
								remSequence = 0
							}
						}
					}
					inputIndex += 1
				}
				fileDiff.diffArray.append( diffArray )
			}
		}
	}
}
