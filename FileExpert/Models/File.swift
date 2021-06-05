//
//  FileNEw.swift
//  FileExpert
//
//  Created by new on 5/31/21.
//

import Foundation

class File: Item {
    
    override init(name: String, id: String) {
        super.init(name: name, id: id)
    }
    
    override func deleted() {
        store?.removeFile(for: self)
        super.deleted()
    }
}
