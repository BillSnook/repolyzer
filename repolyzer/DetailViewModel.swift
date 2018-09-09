//
//  DetailViewModel.swift
//  repolyzer
//
//  Created by William Snook on 9/8/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import Foundation

class DiffLines {
	
	var lineRange = ""
	var line = ""
	var added = false
	var removed = false
	var lineNumber = 0
}

class DiffEntry {
	
	var fileName = ""
	var diffLines: [DiffLines] = []
}

class DiffList {
	
	var diffEntries: [DiffEntry] = []
}

class DetailViewModel {
	
	let diffString: String
	let diffList: DiffList
	
	init( with diff: Data ) {
		diffString = String( data: diff, encoding: String.Encoding.utf8 ) ?? ""
		diffList = DiffList()
		
		seperateFiles()
		for entry in diffList.diffEntries  {
			print( entry.fileName )
			for line in entry.diffLines {
				print( line.lineRange )
				print( line.line )
			}
		}
	}
	
	func seperateFiles() {
		
		let fileArray = diffString.components(separatedBy: "diff --git a/").filter {!$0.isEmpty}
		for file in fileArray {
			let diffEntry = DiffEntry()
			let diffArray = file.components(separatedBy: "\n@@ ")
			// First entry contains diff --git ..., remaining ones start with @@ -aa,b +cc,d @@
			// and contain lines of code to display
			var isFirstElement = true
			for diff in diffArray {
				if isFirstElement {
					isFirstElement = false
					diffEntry.fileName = filenameFromSegment( diff )
					continue
				}
				let diffLine = DiffLines()
				let diffLineArray = diff.components(separatedBy: "\n@@ ")
				if let firstLineSegment = diffLineArray.first {
					let firstLineArray = firstLineSegment.components(separatedBy: " @@")
					if (firstLineArray.count == 2) {	// < -11,6 +11,7 > section then everything else from that diff sequence
						diffLine.lineRange = firstLineArray[0]
						diffLine.line = firstLineArray[1]
					}
				}
//				print( diff )
				diffEntry.diffLines.append( diffLine )
			}
			diffList.diffEntries.append( diffEntry )
		}
	}
	
	func filenameFromSegment( _ rawFilenameString: String ) -> String {

		let firstArray = rawFilenameString.components(separatedBy: "\n--- a/")	// diff --git a/...
		if firstArray.count > 1 {
			let fileNamePlus = firstArray[1]	// Second component contains filename plus another line
			let secondArray = fileNamePlus.components(separatedBy: "\n")
			if secondArray.count > 0 {
				return secondArray[0]
			}
		}
		return "No Filename Found"
	}
}
