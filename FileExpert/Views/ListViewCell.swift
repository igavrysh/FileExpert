//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import UIKit

class ListViewCell: UICollectionViewCell {
    
    let iconView = UIImageView()
    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 1)
        l.textAlignment = .left
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()
    var item: ItemModel? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
