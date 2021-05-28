//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell {
    
    let iconView = UIImageView()
    let nameLabel = UILabel()
    
    var item: ItemModel? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.image = UIImage(named: "folder")
        nameLabel.text = "hello"
        //iconView.constrainHeight(constant: 34)
        iconView.constrainWidth(constant: 34)
        let stackView = UIStackView(arrangedSubviews: [iconView, nameLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    func updateUIWithItem(_ item: ItemModel) {
        self.item = item
        nameLabel.text = item.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
