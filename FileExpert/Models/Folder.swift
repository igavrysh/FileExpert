//
//  Folder.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Folder: Item {
    
    private(set) var contents: [Item]
    
    override weak var store: Store? {
        didSet {
            contents.forEach { $0.store = store }
        }
    }
    
    override init(name: String, id: String) {
        contents = []
        super.init(name: name, id: id)
    }
    
    override func deleted() {
        for item in contents {
            remove(item)
        }
        super.deleted()
    }
    
    func add(_ item: Item) -> Item {
        assert(contents.contains { $0 == item } == false)
        contents.append(item)
        contents.sort(by: { $0.name < $1.name })
        let newIndex = contents.firstIndex { $0 == item }!
        item.parent = self
        store?.save(item, userInfo: [
            Item.changeReasonKey: Item.added,
            Item.newValueKey: newIndex,
            Item.parentFolderKey: self
        ])
        return item
    }
    
    func reSort(changedItem: Item) -> (oldIndex: Int, newIndex: Int) {
        let oldIndex = contents.firstIndex { $0 == changedItem }!
        contents.sort(by: { $0.name < $1.name })
        let newIndex = contents.firstIndex { $0 == changedItem }!
        return (oldIndex, newIndex)
    }
    
    func remove(_ item: Item) {
        guard let index = contents.firstIndex(where: { $0 == item }) else { return }
        item.deleted()
        contents.remove(at: index)
        store?.save(item, userInfo: [
            Item.changeReasonKey: Item.removed,
            Item.oldValueKey: index,
            Item.parentFolderKey: self
        ])
    }
    
    override func item(atIdPath path: ArraySlice<String>) -> Item? {
        guard path.count > 1 else { return super.item(atIdPath: path) }
        guard path.first == id else { return nil }
        let subseq = path.dropFirst()
        guard let second = subseq.first else { return nil }
        return contents
            .first { $0.id == second }
            .flatMap { $0.item(atIdPath: subseq) }
    }
}
