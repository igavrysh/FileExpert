//
//  Store.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class Store {
    
    static let changedNotification = Notification.Name("StoreChanged")
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    static let shared = Store(url: documentDirectory)
    
    private var webservice: Webservice!
    
    let localBaseURL: URL
    
    var localStoreLocationURL: URL {
        return localBaseURL.appendingPathComponent(.storeLocation)
    }
    
    private(set) var rootDirectory: Directory!
    
    private var sheetService = SpreadsheetService()
    
    init(url: URL) {
        self.localBaseURL = url
        self.webservice = Webservice(store: self)
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
    
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        let json = rootDirectory.json
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        try! data.write(to: localStoreLocationURL)
        NotificationCenter.default.post(name: Store.changedNotification, object: notifying, userInfo: userInfo)
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
}

fileprivate extension String {
    static let rootDirectoryId = ""
    static let rootDirectoryName = ""
    static let sheetRecordTypeDirectory = "d"
    static let sheetRecordTypeFile = "f"
    static let storeLocation = "store.json"
}
