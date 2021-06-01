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
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let rootFolder = self?.rootFolder else { return }
            rootFolder.add(FileNew(name: "file1.txt", id: UUID().uuidString))
            rootFolder.add(FileNew(name: "file2.txt", id: UUID().uuidString))
            rootFolder.add(Folder(name: "directory1fasdfsafsafsafasfasfsafasfsafasdfsadfadf", id: UUID().uuidString))
            rootFolder.add(Folder(name: "directory2", id: UUID().uuidString))
            rootFolder.add(Folder(name: "directory3", id: UUID().uuidString))
        }
        
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
