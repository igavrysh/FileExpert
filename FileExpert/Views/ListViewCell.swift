//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import UIKit

class ListViewCell: UICollectionViewCell, ItemView {

    let iconCellFillRatio: CGFloat = 0.7
    
    var item: ItemModel? = nil
    
    let rowHeight: CGFloat
    let iconWidth: CGFloat
    
    let iconView = UIImageView()
    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 1)
        l.textAlignment = .left
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()
    
    let buttonTransition: UIButton = {
        var b = UIButton()
        _ = UIImage(systemName: "chevron.forward").map { b.setImage($0, for: .normal)}
        return b
    }()
    
    var iconWidthConstraint: NSLayoutConstraint? = nil
    var iconHeightConstraint: NSLayoutConstraint? = nil
    
    func setIconImage(_ image: UIImage) {
        let ratio = image.size.width / image.size.height
        self.iconView.image = image
        self.iconHeightConstraint.map { $0.constant = iconWidth / ratio }
        self.iconWidthConstraint.map { $0.constant = iconWidth }
    }
    
    override init(frame: CGRect) {
        rowHeight = frame.height
        iconWidth = frame.height * iconCellFillRatio

        super.init(frame: frame)
        
        self.backgroundColor = UIColor.yellow
        let iconContainer = UIView()
    
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        _ = iconContainer.constrainWidth(constant: 1 * rowHeight)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)
        self.iconWidthConstraint = iconView.constrainWidth(constant: iconWidth)
        self.iconHeightConstraint = iconView.constrainHeight(constant: iconWidth)
        iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor).isActive = true
        
        UIImage(named: "placeholder").map { self.setIconImage($0) }
        
        buttonTransition.translatesAutoresizingMaskIntoConstraints = false
        _ = buttonTransition.constrainWidth(constant: 50)
    
        let stackView = UIStackView(arrangedSubviews: [iconContainer, nameLabel, buttonTransition])
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        self.addSubview(stackView)
        stackView.fillSuperview()
    
        nameLabel.text = "placeholder"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight() {
    }
    
    func unhighlight() {
    }
    
    func updateUIWithItem(_ item: ItemModel) {
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        switch item.type {
        case .file:
            iconImage = UIImage(systemName: "doc.richtext")!
            buttonTransition.isHidden = true
        case .directory:
            iconImage = UIImage(systemName: "folder")!
            buttonTransition.isHidden = false
        }
        iconImage.map { setIconImage($0) }
    }
    
}
