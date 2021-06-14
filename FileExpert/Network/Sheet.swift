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

enum SheetRecordType: String {
    case file = "f"
    case directory = "d"
}

struct SheetRecord: Hashable {
    let id: String
    let parentId: String
    let type: SheetRecordType
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(parentId)
        hasher.combine(type)
        hasher.combine(name)
    }
}


