//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell, ItemView {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    let iconCellFillRatio: CGFloat = 0.6
    let iconView = UIImageView()
    var iconHeight: CGFloat = 0
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
        self.iconWidthConstraint.map { $0.constant = iconHeight }
        self.iconWidthConstraint.map { $0.constant = ratio * iconHeight }
    }
    
    func highlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.init(
                red: 0,
                green: 111.0/255.0,
                blue: 247.0/255.0,
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
        configure()
    }
    
    func updateUIWithItem(_ item: ItemModel) {
        /*
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        switch item.type {
        case .file:
        case .directory:
            
        }
        iconImage.map { setIconImage($0) }
        */
    }
    
    func updateWith(_ item: Item) {
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
    func configure() {
        iconHeight = frame.height * iconCellFillRatio
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
        
        let textHeight = frame.height * (1 - iconCellFillRatio) / 4
        let fontSize = self.nameLabel.fontSizeToFitSize(CGSize(width: frame.width, height: textHeight))
        nameLabel.font = .systemFont(ofSize: fontSize)
        nameLabel.text = "placeholder"
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconHeightConstraint = self.iconView.constrainHeight(constant: iconHeight)
        iconWidthConstraint = self.iconView.constrainWidth(constant: iconHeight)
        
        let dummyView = UIView()
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        _ = dummyView.constrainHeight(constant: 0)
        _ = dummyView.constrainWidth(constant: 0)
        
        let stackView = UIStackView(arrangedSubviews: [dummyView, iconView, nameLabel, dummyView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.fillSuperview(padding: .init(top: 8, left: 8, bottom: 8, right: 8))
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}
