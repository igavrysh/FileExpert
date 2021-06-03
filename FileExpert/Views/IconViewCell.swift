//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewCell, ItemView {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    static let testing = false
    
    let cellFillRatioIcon: CGFloat = 0.60
    let cellFillRatioText: CGFloat = 0.30
    
    let iconView: UIImageView = {
        var i = UIImageView()
        if IconViewCell.testing {
            i.backgroundColor = .blue
        }
        i.contentMode = .scaleAspectFill
        return i
    }()
    var iconSize: CGFloat = 0
    var item: Item? = nil

    let nameLabel: UILabel = {
        var l = UILabel(text: "hello", font: .systemFont(ofSize: 12), numberOfLines: 2)
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        if IconViewCell.testing {
            l.backgroundColor = .green
        }
        return l
    }()
    
    func setIconImage(_ image: UIImage) {
        self.iconView.image = image
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
        iconSize = frame.height * cellFillRatioIcon
        self.backgroundView = {
            let v = UIView()
            v.fillSuperview()
            if IconViewCell.testing {
                v.backgroundColor = .red
            } else {
                v.backgroundColor = .white
            }
            v.layer.cornerRadius = 8
            v.layer.borderWidth = 0.3
            v.layer.borderColor = UIColor.lightGray.cgColor
            self.addSubview(v)
            return v
        }()

        self.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingViewGenerator = {() -> UIView in
            let p = UIView()
            p.translatesAutoresizingMaskIntoConstraints = false
            if IconViewCell.testing {
                p.backgroundColor = .green
            }
            return p
        }
        
        nameLabel.text = "placeholder"
        let paddingToViewMul = (1 - cellFillRatioIcon - cellFillRatioText) / 5
        
        let paddingViewTop = paddingViewGenerator()
        let paddingViewMiddle = paddingViewGenerator()
    
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(paddingViewTop)
        self.addSubview(iconView)
        self.addSubview(paddingViewMiddle)
        self.addSubview(nameLabel)
        
        // top padding view setup
        paddingViewTop.widthAnchor.constraint(equalToConstant: 0).isActive = true
        paddingViewTop.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: paddingToViewMul * 4).isActive = true
        paddingViewTop.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        paddingViewTop.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        // icon View constraints
        iconView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.cellFillRatioIcon).isActive = true
        iconView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: self.cellFillRatioIcon).isActive = true
        iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: paddingViewTop.bottomAnchor, constant: 0).isActive = true
        
        // middle padding view setup
        paddingViewMiddle.widthAnchor.constraint(equalToConstant: 0).isActive = true
        paddingViewMiddle.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: paddingToViewMul).isActive = true
        paddingViewMiddle.topAnchor.constraint(equalTo: self.iconView.bottomAnchor).isActive = true
        paddingViewMiddle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: paddingViewMiddle.bottomAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 - 2 * paddingToViewMul).isActive = true
        nameLabel.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: cellFillRatioText).isActive = true
        
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}
