//
//  MainViewController.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class MainViewController: UINavigationController {
    
    init() {
        super.init(rootViewController: FolderViewController(style: .icons))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
