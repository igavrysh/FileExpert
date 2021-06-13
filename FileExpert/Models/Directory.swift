//
//  Folder.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Directory: Item {
    var contents: [Item] {
        didSet {
            for item in contents {
                item.store = store
                item.parent = self
            }
            contents.sort(by: self.sortStrategy)
        }
    }
    
    override weak var store: Store? {
        didSet {
            contents.forEach { $0.store = store }
        }
    }
    
    enum SortType {
        case nameAsc, directoryFileNameAsc
    }
    
    private var sortType: SortType = .directoryFileNameAsc
    
    var sortStrategy: ((_: Item, _: Item) -> Bool) {
        return sortStrategies[sortType] ?? Directory.nameAscSortStrategy
    }
    
    var sortStrategies: [SortType: ((_: Item, _: Item) -> Bool)] = [
        .nameAsc: Directory.nameAscSortStrategy,
        .directoryFileNameAsc: Directory.directoryFileNameAscSortStrategy
    ]
    
    var isRoot: Bool {
        get {
            self.store?.rootDirectory === self
        }
    }
    
    override init(name: String, id: String) {
        contents = []
        super.init(name: name, id: id)
    }
    
    init?(name: String, id: String, dict: [String: Any]) {
        self.contents = Directory.load(jsonContents: dict[.contentsKey])
        super.init(name: name, id: id)
        self.contents.forEach { $0.parent = self }
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
    
    func add<T: Item>(_ item: T) -> T {
        assert(contents.contains { $0 == item } == false)
        contents.append(item)
        sortStrategies[sortType].map { contents.sort(by: $0)}
        let newIndex = contents.firstIndex { $0 == item }!
        item.parent = self
        let userInfo: [AnyHashable: Any] = [Item.changeReasonKey: Item.added, Item.newValueKey: newIndex, Item.parentFolderKey: self]
        store?.save(item, userInfo: userInfo)
        return item
    }
    
    func addFileNamed(_ name: String) -> File {
        return add(File(name: name, id: UUID().uuidString))
    }
    
    func addDirectoryNamed(_ name: String) -> Directory {
        return add(Directory(name: name, id: UUID().uuidString))
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

    override var json: [String: Any] {
        var result = super.json
        result[.contentsKey] = contents.map { $0.json }
        return result
    }
    
    static func load(jsonContents: Any?) -> [Item] {
        return (jsonContents as? Array<Any>)?.compactMap { Item.load(json:$0) } ?? []
    }
}

fileprivate extension String {
    static let contentsKey = "contents"
}

fileprivate extension Directory {
    static var nameAscSortStrategy: ((_: Item, _: Item) -> Bool) {
        return { $0.name < $1.name }
    }
    
    static var directoryFileNameAscSortStrategy: ((_: Item, _: Item) -> Bool) {
        return { (item1, item2) -> Bool in
            if (item1 is Directory && item2 is Directory)
                || (item1 is File && item2 is File) {
                return item1.name < item2.name
            } else {
                if item1 is File && item2 is Directory {
                    return false
                } else if item1 is Directory && item2 is File {
                    return true
                }
                fatalError("Unexpected file and directory configuration found when trying to sort items")
            }
        }
    }
}

