//
//  MainViewController.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class MainViewController: UINavigationController {
    
    init() {
        super.init(rootViewController: FolderViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.topItem?.title = "File Expert"
    
        self.title = "File Expert"
        self.navigationItem.title = "FileExpert"
        self.tabBarController?.title = "File Expert"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
