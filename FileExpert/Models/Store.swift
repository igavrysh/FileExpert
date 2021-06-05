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
    
    private var sheetService = SheetService()
    
    init() {
        self.rootFolder = Folder(name: .rootDirectoryName, id: .rootDirectoryId)
        self.rootFolder.store = self
    }
    
    func load() {
        // TODO: refactor this to a separate service class that will maitain store lifecycle (e.g. initial load, caching and
        // follow up refreshes
        if rootFolder.contents.count == 0 {
            DispatchQueue.global(qos: .background).async { [weak self] in
                
                let abcFolder = self?.rootFolder.add(Folder(name: "abc", id: "abc"))
                let abc1Folder = self?.rootFolder.add(Folder(name: "abc1", id: "abc1"))
                let abc2Folder = self?.rootFolder.add(Folder(name: "abc2", id: "abc2"))
                let abc3Folder = self?.rootFolder.add(Folder(name: "abc3", id: "abc3"))

                self?.rootFolder.add(
                    FileNew(
                        name: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                        id: "id2"))
                (abcFolder as? Folder)?.add(Folder(name: "in abc", id: "in abc"))
                
                 
                
                /*
                
                self?.sheetService.fetchSheet { [weak self] (sheet, error) in
                    if error != nil {
                        return
                    }
                    if let sheet = sheet {
                        self?.loadDirectoryFromSheet(sheet)
                    }
                }
                 */
                
                
            }
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
    
    
    fileprivate class Container {
        var records: [SheetRecord]
        init(_ records: [SheetRecord]) {
            self.records = records
        }
    }
    
    func loadDirectoryFromSheet(_ sheet: Sheet) {
        var sheetsByParentId = [String: Container]();
        for row in sheet.rows {
            if let c = sheetsByParentId[row.parentId] {
                c.records.append(row)
            } else {
                sheetsByParentId[row.parentId] = Container([row])
            }
        }
        
        var dirs = [String: Folder]()
        var queue = [SheetRecord(id: .rootDirectoryId, parentId: .rootDirectoryId, type: .sheetRecordTypeDirectory, name: .rootDirectoryName)]
        dirs[rootFolder.id] = rootFolder
        while !queue.isEmpty {
            let row = queue.remove(at: 0)
            if row.type == .sheetRecordTypeFile {
                if let parentDir = dirs[row.parentId] {
                    _ = parentDir.add(FileNew(name: row.name, id: row.id))
                }
            }
            if row.type == .sheetRecordTypeDirectory {
                let parentDir = dirs[row.parentId]
                // if not a root folder as root folder has been added in class init
                if (row.id != .rootDirectoryId) {
                    if let dir = parentDir?.add(Folder(name: row.name, id: row.id)) as? Folder {
                        dirs[dir.id] = dir
                    }
                }
                if let children = sheetsByParentId[row.id] {
                    queue.append(contentsOf: children.records)
                }
            }
        }
    }
}

fileprivate extension String {
    static let rootDirectoryId = ""
    static let rootDirectoryName = ""
    static let sheetRecordTypeDirectory = "d"
    static let sheetRecordTypeFile = "f"
}
