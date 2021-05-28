//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell {
    
    let iconView = UIImageView()
    var iconWidthConstraint: NSLayoutConstraint? = nil
    var iconHeightConstraint: NSLayoutConstraint? = nil
    
    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 2)
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()
    
    func setIconImage(_ image: UIImage) {
        let ratio = image.size.width / image.size.height
        self.iconView.image = image
        self.iconWidthConstraint.map { $0.constant = 64 }
        self.iconWidthConstraint.map { $0.constant = ratio * 64 }
    }
    
    var item: ItemModel? = nil

    override init(frame: CGRect) {
        
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

        nameLabel.text = "placeholder"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconHeightConstraint = self.iconView.constrainHeight(constant: 64)
        iconWidthConstraint = self.iconView.constrainWidth(constant: 64)
        
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
