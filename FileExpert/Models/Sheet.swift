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

struct SheetRecord: Hashable {
    let id: String
    let parentId: String
    let type: String
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(parentId)
        hasher.combine(type)
        hasher.combine(name)
    }
}
