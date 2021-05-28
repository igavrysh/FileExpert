//
//  File.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import Foundation

class File {
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

struct ItemModel {
    var name: String
}

class Directory {
    var id: String
    var name: String
    var subdirs: [Directory]
    var files: [File]
    weak var parent: Directory?
    
    init(id: String, name: String, subdirs: [Directory], files: [File], parent: Directory? = nil) {
        self.id = id
        self.name = name
        self.subdirs = subdirs
        self.files = files
        self.parent = parent
    }
    
    func itemsCount() -> Int {
        return subdirs.count + files.count
    }
    
    func item(at index: Int) -> ItemModel? {
        if (index < 0 || index >= self.itemsCount()) {
            return nil
        }
        
        if (index < subdirs.count) {
            return ItemModel(name: subdirs[index].name)
        } else {
            return ItemModel(name: files[index - subdirs.count].name)
        }
    }
}

fileprivate class Container {
    var records: [SheetRecord]
    
    init(_ records: [SheetRecord]) {
        self.records = records
    }
}

func dirFromSheet(_ sheet: Sheet) -> Directory? {
    var sheetsByParentId = [String: Container]();
    for row in sheet.rows {
        if let c = sheetsByParentId[row.parentId] {
            c.records.append(row)
        } else {
            sheetsByParentId[row.parentId] = Container([row])
        }
    }
    
    var dirs = [String: Directory]()
    var queue = [SheetRecord(id: "", parentId: "", type: "d", name: "")]
    while !queue.isEmpty {
        let row = queue.remove(at: 0)
        if row.type == "f" {
            if let parentDir = dirs[row.parentId] {
                parentDir.files.append(File(id: row.id, name: row.name))
            }
        }
        if row.type == "d" {
            let parentDir = dirs[row.parentId]
            let cDir = Directory(id: row.id, name: row.name, subdirs: [], files: [], parent: parentDir)
            if let parentDir = parentDir {
                parentDir.subdirs.append(cDir)
            }
            dirs[row.id] = cDir
            if let children = sheetsByParentId[row.id] {
                queue.append(contentsOf: children.records)
            }
        }
    }
    return dirs[""]
}


