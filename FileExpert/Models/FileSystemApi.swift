//
//  FileSystemApi.swift
//  FileExpert
//
//  Created by new on 5/30/21.
//

import Foundation

class FileSystemApi {
    
    let sheetService = SheetService()
    
    var rootDirectory: Directory?
    
    var currentDirectory: Directory?
    
    func fetchData(completion: @escaping (Error?) -> ()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.sheetService.fetchSheet(completion: { [weak self] (sheet: Sheet?, error: Error?) -> () in
                if let error = error {
                    completion(error)
                }
                if let sheet = sheet {
                    //self?.rootDirectory = dirFromSheet(sheet)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            })
        }
    }
    
    func openDirWithName(_ name: String) {
    }
    
    func openDirWithId(_ id: String) {
    }
    
    func goToParentDirectory() {
    }
    
}
