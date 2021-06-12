//
//  NetworkTask.swift
//  FileExpert
//
//  Created by new on 6/11/21.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST

protocol NetworkTask {
    func cancel()
}

class SpreadsheetNetworkTask: NetworkTask {
    
    var task: GTLRServiceTicket
    
    init(with task: GTLRServiceTicket) {
        self.task = task
    }
    
    func cancel() {
        self.task.cancel()
    }
}
