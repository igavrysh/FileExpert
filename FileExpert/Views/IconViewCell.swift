//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell, ItemView {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    let iconCellFillRatio: CGFloat = 0.60
    let iconView = UIImageView()
    var iconSize: CGFloat = 0
    var iconWidthConstraint: NSLayoutConstraint? = nil
    var iconHeightConstraint: NSLayoutConstraint? = nil
    var item: Item? = nil

    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 2)
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()
    
    func setIconImage(_ image: UIImage) {
        let ratio = image.size.width / image.size.height
        self.iconView.image = image
        self.iconWidthConstraint.map { $0.constant = iconSize }
        self.iconWidthConstraint.map { $0.constant = ratio * iconSize }
    }
    
    func highlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.init(
                red: 0,
                green: 111.0 / 255.0,
                blue: 247.0 / 255.0,
                alpha: 0.2).cgColor
        }
    }
    
    func unhighlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }
    
    func updateUIWithItem(_ item: ItemModel) {
    }
    
    func updateWithItem(_ item: Item) {
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        if item is Folder {
            iconImage = UIImage(systemName: "folder")!
        } else {
            iconImage = UIImage(systemName: "doc.richtext")!
        }
        iconImage.map { setIconImage($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconViewCell {
    func configureHierarchy() {
        iconSize = frame.width * iconCellFillRatio
        self.backgroundView = {
            let v = UIView()
            v.fillSuperview()
            v.backgroundColor = .white
            v.layer.cornerRadius = 8
            v.layer.shouldRasterize = true
            v.layer.borderWidth = 0.3
            v.layer.borderColor = UIColor.lightGray.cgColor
            self.addSubview(v)
            return v
        }()
        
        // remainig size after icon size is taken into consideration
        let remainingSize = frame.height * (1 - iconCellFillRatio)
        // H:|padding-[imageview]-padding-[label]-padding|
        let padding = remainingSize * 0.4 / 3
        // divide by 2 cos max two lines are allowed in item name label
        let textHeight = remainingSize * 0.6 / 2
        let fontSize = self.nameLabel.fontSizeToFitSize(CGSize(width: frame.width, height: textHeight))
        nameLabel.font = .systemFont(ofSize: fontSize)
        nameLabel.text = "placeholder"
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconView)
        self.addSubview(nameLabel)
        
        iconHeightConstraint = self.iconView.constrainHeight(constant: iconSize)
        iconWidthConstraint = self.iconView.constrainWidth(constant: iconSize)
        
        iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: padding).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
    
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}
