//
//  Resources.swift
//  FileExpert
//
//  Created by new on 6/11/21.
//

import Foundation

extension Directory {
    
    func loadContents(completion: @escaping () -> ()) -> NetworkTask? {
        let task = SpreadsheetService.shared.loadRecords { [weak self] (result: Result<[SheetRecord]>) in
            completion()
            
            guard case let .success(records) = result else { return }
            self?.updateContentsWithRecords(records)
        }
        return task
    }
}

extension Directory {
    func updateContentsWithRecords(_ records: [SheetRecord]) {
        // TODO: update logic for pending items from store
        
        // Re-apply old contents to new folders
        let merged =  records
            .filter { $0.parentId == self.id }
            .map { r in
                switch r.type {
                case .directory:
                    return Directory(name: r.name, id: r.id)
                case .file:
                    return File(name: r.name, id: r.id)
                }
            }
            .map { (item: Item) -> Item in
                if let d = item as? Directory,
                   let oldContents = (self.contents.first(where: { d.id == $0.id }) as? Directory)?.contents {
                    d.contents = oldContents
                }
                return item
            }
        
        contents = merged
        
        store?.save(self, userInfo: [Item.changeReasonKey: Item.reloaded])
    }
}
