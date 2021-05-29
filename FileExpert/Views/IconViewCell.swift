//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell, ItemView {
    
    let iconCellFillRatio: CGFloat = 0.6
    let iconView = UIImageView()
    let iconHeight: CGFloat
    var iconWidthConstraint: NSLayoutConstraint? = nil
    var iconHeightConstraint: NSLayoutConstraint? = nil
    var item: ItemModel? = nil

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
            $0.layer.backgroundColor = UIColor.init(red: 0, green: 111.0/255.0, blue: 247.0 / 255.0, alpha: 0.2).cgColor
        }
    }
    
    func unhighlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    override init(frame: CGRect) {
        iconHeight = frame.height * iconCellFillRatio
        super.init(frame: frame)
        self.backgroundView = {
            let v = UIView()
            v.fillSuperview()
            v.backgroundColor = .white
            v.layer.cornerRadius = 8
            v.layer.shadowOpacity = 0.1
            v.layer.shadowRadius = 15
            v.layer.shadowOffset = .init(width: 0, height: 15)
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
    
    func updateUIWithItem(_ item: ItemModel) {
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        switch item.type {
        case .file:
            iconImage = UIImage(named: "file")
        case .directory:
            iconImage = UIImage(named: "directory")
        }
        iconImage.map { setIconImage($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
