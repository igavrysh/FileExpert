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
    // TODO: review model (should implicit unwrapping be used here?)
    weak var directory: Directory?
    
    init(id: String, name: String, directory: Directory) {
        self.id = id
        self.name = name
        self.directory = directory
    }
}

enum ItemType {
    case file
    case directory
}

struct ItemModel {
    var id: String
    var name: String
    var type: ItemType
}

class Directory {
    var id: String
    var name: String
    var subdirs: [Directory]
    var files: [File]
    weak var parent: Directory?
    
    var isRootDirectory: Bool {
        get {
            return id == ""
        }
    }
    
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
            let dir = subdirs[index]
            return ItemModel(id: dir.id, name: dir.name, type: .directory)
        } else {
            let file = files[index - subdirs.count]
            return ItemModel(id: file.id, name: file.name, type: .file)
        }
    }
    
    func directory(at index: Int) -> Directory? {
        return index >= 0 && index < subdirs.count ? subdirs[index] : nil
    }
}

 
