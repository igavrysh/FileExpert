//
//  File.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import Foundation

struct File {
    var id: String
    var name: String
}

struct Directory {
    var id: String
    var name: String
    
    var subdirectories: [Directory]
    var files: [File]
    

}
