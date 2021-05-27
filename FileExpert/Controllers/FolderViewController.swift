//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit
import Foundation

class FolderViewController: UIViewController {
    
    let sheetService = SheetService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blue
        sheetService.fetchSheet(completion: { (sheet: Sheet?, error: Error?) -> () in
            if (error != nil) {
                return
            }
            
            for row in sheet!.rows {
                print("\(row.id), \(row.parentFolder), \(row.type), \(row.name)")
            }
        })
    }
    
    
}
