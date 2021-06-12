//
//  Resources.swift
//  FileExpert
//
//  Created by new on 6/11/21.
//

import Foundation

extension Directory {
    
    var contentsResource: Resource<[Item]> {
        let id = self.id
        return Resource(id: id, parseElementJSON: Item.load)
    }
    
    func loadContents(completion: @escaping () -> ()) -> NetworkTask? {
        let task = SpreadsheetService.shared.load(contentsResource) { [weak self] result in
            completion()
            guard case let .success(items) = result else { return }
            self?.updateContents(from: items)
        }
        return task
    }
}

extension Directory {
    func updateContents(from items: [Item]) {
        
        // TODO: update logic for pending items from store
        let newContents = items
        
        // Re-apply old contents to new folders
        for item in newContents {
            guard
                let directory = item as? Directory,
                let old = contents.first(where: { item.id == $0.id }) as? Directory
            else { continue }
            directory.contents = old.contents
        }
        
        let merged = newContents
        contents = merged
        store?.save(self, userInfo: [Item.changeReasonKey: Item.reloaded])
    }
}
