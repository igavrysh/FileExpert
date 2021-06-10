//
//  Store.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation


class Store {
    
    static let changeNotification = Notification.Name("StoreChanged")
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    static let shared = Store(url: documentDirectory)
    
    let localBaseURL: URL
    
    var localStoreLocationURL: URL {
        return localBaseURL.appendingPathComponent(.storeLocation)
    }
    
    private(set) var rootDirectory: Directory!
    
    private var sheetService = SheetService()
    
    init(url: URL) {
        self.localBaseURL = url
        self.rootDirectory = readRootDirectory() ?? Directory(name: .rootDirectoryName, id: .rootDirectoryId)
        self.rootDirectory.store = self
    }
    
    func readRootDirectory() -> Directory? {
        guard let data = try? Data(contentsOf: localStoreLocationURL),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let directory = Item.load(json: json) as? Directory
        else { return nil }
        return directory
    }
    
    func load() {
        // TODO: refactor this to a separate service class that will maitain store lifecycle (e.g. initial load, caching and
        // follow up refreshes
        if rootDirectory.contents.count == 0 {
            DispatchQueue.global(qos: .background).async { [weak self] in
                /*
                let abcFolder = self?.rootFolder.add(Directory(name: "abc", id: "abc"))
                let abc1Folder = self?.rootFolder.add(Directory(name: "abc1", id: "abc1"))
                let abc2Folder = self?.rootFolder.add(Directory(name: "abc2", id: "abc2"))
                let abc3Folder = self?.rootFolder.add(Directory(name: "abc3", id: "abc3"))

                self?.rootFolder.add(
                    File(
                        name: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                        id: "id2"))
                (abcFolder as? Directory)?.add(Directory(name: "in abc", id: "in abc"))
                */
                
                self?.sheetService.fetchSheet { [weak self] (sheet, error) in
                    if error != nil {
                        return
                    }
                    if let sheet = sheet {
                        self?.loadDirectoryFromSheet(sheet)
                    }
                }
            }
        }
    }
    
    //func addItem(item: Item) {
        //self.sheetService.
        
    //}
    
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        let json = rootDirectory.json
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        try! data.write(to: localStoreLocationURL)
        NotificationCenter.default.post(name: Store.changeNotification, object: notifying, userInfo: userInfo)
    }
    
    func item(atIdPath path: [String]) -> Item? {
        return rootDirectory.item(atIdPath: path[0...])
    }
    
    func removeFile(for file: File) {
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
        
        var dirs = [String: Directory]()
        var queue = [SheetRecord(id: .rootDirectoryId, parentId: .rootDirectoryId, type: .sheetRecordTypeDirectory, name: .rootDirectoryName)]
        dirs[rootDirectory.id] = rootDirectory
        while !queue.isEmpty {
            let row = queue.remove(at: 0)
            if row.type == .sheetRecordTypeFile {
                if let parentDir = dirs[row.parentId] {
                    _ = parentDir.add(File(name: row.name, id: row.id))
                    //Thread.sleep(forTimeInterval: 0.1)
                }
            }
            if row.type == .sheetRecordTypeDirectory {
                let parentDir = dirs[row.parentId]
                // if not a root folder as root folder has been added in class init
                if (row.id != .rootDirectoryId) {
                    if let dir = parentDir?.add(Directory(name: row.name, id: row.id)) {
                        dirs[dir.id] = dir
                    }
                    //Thread.sleep(forTimeInterval: 0.1)
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
    static let storeLocation = "store.json"
}
