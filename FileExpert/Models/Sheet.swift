//
//  SheetData.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import Foundation

struct Sheet {
    var rows: [SheetRecord] = []
}

struct SheetRecord {
    let id: String
    let parentFolder: String
    let type: String
    let name: String
}
