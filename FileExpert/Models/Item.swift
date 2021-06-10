//
//  Item.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Item: Hashable {

    let id: String
    
    private(set) var name: String
    
    weak var store: Store?
    
    weak var parent: Directory? {
        didSet {
            store = parent?.store
        }
    }
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        self.store = nil
    }
    
    func setName(_ newName: String) {
        name = newName
        if let p = parent {
            let (oldIndex, newIndex) = p.reSort(changedItem: self)
            store?.save(self, userInfo: [
                            Item.changeReasonKey: Item.renamed,
                            Item.oldValueKey: oldIndex,
                            Item.newValueKey: newIndex,
                            Item.parentFolderKey: p])
        }
    }
    
    func deleted() {
        parent = nil
    }
    
    var idPath: [String] {
        var path = parent?.idPath ?? []
        path.append(id)
        return path
    }
    
    func item(atIdPath path: ArraySlice<String>) -> Item? {
        guard let first = path.first, first == id else {
            return nil
        }
        return self
    }
    
    static func load(json: Any) -> Item? {
        guard let dict = json as? [String: Any],
              let name = dict[.nameKey] as? String,
              let id = dict[.idKey] as? String,
              let isDirectory = dict[.isDirectoryKey] as? Bool
        else { return nil }
        if isDirectory {
            return Directory(name: name, id: id, dict: dict)
        } else {
            return File(name: name, id: id)
        }
    }
    
    var json: [String: Any] {
        return [.nameKey: name, .idKey: id, .isDirectoryKey: self is Directory]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    static let changeReasonKey = "reason"
    static let newValueKey = "newValue"
    static let oldValueKey = "oldValue"
    static let parentFolderKey = "parentFolder"
    static let renamed = "renamed"
    static let added = "added"
    static let removed = "removed"
    static let reloaded = "reloaded"
}

fileprivate extension String {
    static let nameKey = "name"
    static let idKey = "id"
    static let isDirectoryKey = "isDirectory"
}
