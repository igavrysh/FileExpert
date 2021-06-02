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
    let iconView: UIImageView = {
        var i = UIImageView()
        i.backgroundColor = .blue
        return i
    }()
    let iconViewContainer: UIView = {
        var v = UIView()
        v.backgroundColor = .yellow
        return v
    }()
    var iconSize: CGFloat = 0
    var iconWidthConstraint: NSLayoutConstraint? = nil
    var iconHeightConstraint: NSLayoutConstraint? = nil
    var item: Item? = nil

    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 2)
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        l.backgroundColor = .green
        return l
    }()
    
    func setIconImage(_ image: UIImage) {
        let ratio = image.size.width / image.size.height
        var width: CGFloat = 0
        var height: CGFloat = 0
        if ratio > 1 {
            width = iconSize
            height = iconSize / ratio
        } else {
            height = iconSize
            width = iconSize * ratio
        }
        self.iconView.image = image
        _ = self.iconWidthConstraint.map { $0.constant = width }
        _ = self.iconHeightConstraint.map { $0.constant = height}
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
        //iconImage.map { setIconImage($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconViewCell {
    func configureHierarchy() {
        iconSize = frame.height * iconCellFillRatio
        self.backgroundView = {
            let v = UIView()
            v.fillSuperview()
            v.backgroundColor = .red
            v.layer.cornerRadius = 8
            v.layer.shouldRasterize = true
            v.layer.borderWidth = 0.3
            v.layer.borderColor = UIColor.lightGray.cgColor
            self.addSubview(v)
            return v
        }()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // remainig size after icon size is taken into consideration
        let remainingSize = frame.height * (1 - iconCellFillRatio)
        // H:|padding-[imageview]-padding-[label]-padding|
        let padding = remainingSize * 0.4 / 3
        // divide by 2 cos max two lines are allowed in item name label
        let textHeight = remainingSize * 0.6 / 2
        let fontSize = self.nameLabel.fontSizeToFitSize(CGSize(width: frame.width - padding * 2, height: textHeight))
        nameLabel.font = .systemFont(ofSize: 3)
        nameLabel.text = "placeholder"
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconViewContainer.translatesAutoresizingMaskIntoConstraints = false
        iconViewContainer.addSubview(iconView)
        self.addSubview(iconViewContainer)
        //self.addSubview(nameLabel)
        
        // icon View constraints
        iconHeightConstraint = self.iconView.constrainHeight(constant: iconSize)
        iconWidthConstraint = self.iconView.constrainWidth(constant: iconSize)
        
        iconView.centerXAnchor.constraint(equalTo: iconViewContainer.centerXAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: iconViewContainer.centerYAnchor).isActive = true
        iconWidthConstraint?.isActive = true
        iconHeightConstraint?.isActive = true
        
        
        iconViewContainer.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconViewContainer.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconViewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconViewContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
        
        /*
        
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    
        nameLabel.topAnchor.constraint(equalTo: iconViewContainer.bottomAnchor, constant: padding).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
         */
    
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}
