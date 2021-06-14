//
//  SheetData.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import Foundation

struct Sheet {
    var rows: [SheetRecord] = []
    
    mutating func addSheetRecord(_ sheetRecord: SheetRecord) {
        rows.append(sheetRecord)
    }
}

struct SheetRecord: Hashable {
    let id: String
    let parentId: String
    let isDirectory: Bool
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(parentId)
        hasher.combine(isDirectory)
        hasher.combine(name)
    }
}
