//
//  Store.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Store {
    
    static let changeNotification = Notification.Name("StoreChanged")
    
    static let shared = Store()
    
    private(set) var rootFolder: Folder
    
    init() {
        self.rootFolder = Folder(name: "", id: "")
        self.rootFolder.store = self
    }
    
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Store.changeNotification, object: notifying, userInfo: userInfo)
    }
    
    func item(atIdPath path: [String]) -> Item? {
        return rootFolder.item(atIdPath: path[0...])
    }
    
    func removeFile(for file: FileNew) {
    }
    
}
