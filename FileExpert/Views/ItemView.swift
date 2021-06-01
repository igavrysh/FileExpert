//
//  ItemView.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import UIKit

protocol ItemView: UICollectionViewCell {
        
    func highlight()
    
    func unhighlight()
    
    func updateUIWithItem(_ item: ItemModel)
    
    func updateWith(_ item: Item)
    
}
