//
//  Webservice.swift
//  FileExpert
//
//  Created by new on 6/9/21.
//

import UIKit

final class Webservice {
    private var processing = false
    private weak var store: Store!
    private var pendingItems: [PendingItem] = [] {
        didSet { saveQueue() }
    }
    
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static private let queueURL = Webservice.documentDirectory.appendingPathComponent("queue.json")
    
    init(store: Store) {
        self.store = store
        loadQueue()
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange(_:)), name: Store.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func loadQueue() {
        guard let data = try? Data(contentsOf: Webservice.queueURL) else { return }
        pendingItems = try! JSONDecoder().decode([PendingItem].self, from: data)
    }
    
    private func saveQueue() {
        try! JSONEncoder().encode(pendingItems).write(to: Webservice.queueURL)
    }
    
    @objc func didBecomeActive() {
        processChanges()
    }
    
    @objc func storeDidChange(_ note: Notification) {
        guard let pending = PendingItem(note) else { return }
        pendingItems.append(pending)
        processChanges()
    }
    
    func processChanges() {
        guard !processing, let pending = pendingItems.first else { return }
        processing = true
        
        if pending.change == .create {
            if let id = pending.idPath.last,
               pending.idPath.count >= 2 {
                let parentId = pending.idPath[pending.idPath.count - 2]
                let sr = SheetRecord(id: id, parentId: parentId, type: pending.isDirectory ? .directory : .file, name: pending.name)
                SpreadsheetService.shared.addRecord(sr) {[weak self] result in
                    guard let s = self else { return }
                    s.processing = false
                    s.pendingItems.removeFirst()
                    if let item = s.store.item(atIdPath: pending.idPath),
                       let parent = item.parent,
                       let index = parent.contents.firstIndex(where: { $0 === item })
                    {
                        NotificationCenter.default.post(name: Store.changedNotification, object: item, userInfo: [
                            Item.changeReasonKey: Item.reloaded,
                            Item.oldValueKey: index,
                            Item.newValueKey: index,
                            Item.parentFolderKey: parent
                        ])
                    }
                }
            }
        }
        
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
