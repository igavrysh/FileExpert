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
        
        self.backgroundView = {
            let v = UIView()
            v.fillSuperview()
            v.backgroundColor = .white
            v.layer.shouldRasterize = true
            self.addSubview(v)
            return v
        }()
        
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
        
        let separatorContainer = UIView()
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = true
        separatorContainer.addSubview(separator)
        _ = separatorContainer.constrainHeight(constant: 0.3)
        
        separator.backgroundColor = UIColor.lightGray
        _ = separator.constrainHeight(constant: 0.3)
        separator.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor, constant: 8).isActive = true
        separator.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor, constant: -8).isActive = true
        separator.centerYAnchor.constraint(equalTo: separatorContainer.centerYAnchor).isActive = true
            
        let verticalStackView = UIStackView(arrangedSubviews: [stackView, separatorContainer])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 0
        verticalStackView.alignment = .fill
        stackView.distribution = .fill
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(verticalStackView)
        verticalStackView.fillSuperview()
    
        nameLabel.text = "placeholder"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.init(red: 0, green: 111.0/255.0, blue: 247.0 / 255.0, alpha: 0.2).cgColor
        }
    }
    
    func unhighlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.white.cgColor
        }
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
    
    func updateWithItem(_ item: Item) {
    }
    
}
