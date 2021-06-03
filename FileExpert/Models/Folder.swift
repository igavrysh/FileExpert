//
//  Folder.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Folder: Item {
    private(set) var contents: [Item]
    
    enum SortType {
        case nameAsc, directoryFileNameAsc
    }
    
    private var sortType: SortType
    
    override weak var store: Store? {
        didSet {
            contents.forEach { $0.store = store }
        }
    }
    
    override init(name: String, id: String) {
        contents = []
        sortType = .directoryFileNameAsc
        super.init(name: name, id: id)
    }
    
    init(name: String, id: String, sortType: SortType) {
        contents = []
        self.sortType = sortType
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
        sortStrategies[sortType].map { contents.sort(by: $0)}
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
        sortStrategies[sortType].map { contents.sort(by: $0)}
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
    
    var sortStrategies: [SortType: ((_: Item, _: Item) -> Bool)] = [
        .nameAsc: { $0.name < $1.name },
        .directoryFileNameAsc: { (item1, item2) -> Bool in
            if (item1 is Folder && item2 is Folder)
                || (item1 is FileNew && item2 is FileNew) {
                return item1.name < item2.name
            } else {
                if item1 is FileNew && item2 is Folder {
                    return false
                } else if item1 is Folder && item2 is FileNew {
                    return true
                }
                fatalError("Unexpect file and directory configuration found when trying to sort items")
            }
        }
    ]
    
    var isRoot: Bool {
        get {
            self.store?.rootFolder === self
        }
    }
}

