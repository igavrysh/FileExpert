//
//  Webservice.swift
//  FileExpert
//
//  Created by new on 6/9/21.
//

import Foundation

final class Webservice {
    private var processing = false
    private weak var store: Store!
    private var pendingItems: [PendingItem] = [] {
        didSet { saveQueue() }
    }
    
    init(store: Store) {
        self.store = store
    }
    
    func saveQueue() {
        fatalError("not implemented")
    }
}

enum Change: String, Codable {
    case create = "create"
    case update = "update"
    case delete = "delete"
}

extension Change {
    fileprivate init?(changeReason: String) {
        switch changeReason {
        case Item.added: self = .create
        case Item.removed: self = .delete
        case Item.renamed: self = .update
        case Item.reloaded: return nil
        default: fatalError()
        }
    }
}

private struct PendingItem: Codable {
    var change: Change
    var idPath: [String]
    var name: String
    var isDirectory: Bool
}

extension PendingItem {
    init?(_ note: Notification) {
        guard
            let changeReason = note.userInfo?[Item.changeReasonKey] as? String,
            let change = Change(changeReason: changeReason)
        else { return nil }
        
        guard
            let item = note.object as? Item,
            let parent = note.userInfo?[Item.parentFolderKey] as? Item
        else { fatalError() }
        self.init(change: change, item: item, parent: parent)
    }
    
    init(change: Change, item: Item, parent: Item) {
        let idPath = parent.idPath + [item.id]
        self.init(change: change, idPath: idPath, name: item.name, isDirectory: item is Directory)
    }
}

enum ChangeError: String, Error {
    case itemArrayExists = "itemAlreadyExists"
}
