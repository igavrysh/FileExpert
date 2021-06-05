//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewListCell, ItemView {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    static let testing = true
    
    let cellFillRatioIcon: CGFloat = 0.60
    let cellFillRatioText: CGFloat = 0.30
    
    private var gridLayoutConstraints: (iconViewCenterX: NSLayoutConstraint,
                                        iconViewCenterY: NSLayoutConstraint,
                                        iconViewWidth: NSLayoutConstraint,
                                        iconViewHeight: NSLayoutConstraint)?
    
    private var listLayoutConstraints: (iconViewLeading: NSLayoutConstraint,
                                        iconViewTop: NSLayoutConstraint,
                                        iconViewBottom: NSLayoutConstraint,
                                        iconViewWidth: NSLayoutConstraint)?
    
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
        self.backgroundView.map { $0.layer.backgroundColor = UIColor.init(red: 0, green: 111.0 / 255.0, blue: 247.0 / 255.0, alpha: 0.2).cgColor }
    }
    
    func unhighlight() {
        self.backgroundView.map{
            $0.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureObserver()
    }
    
    func updateUIWithItem(_ item: ItemModel) {
    }
    
    func updateWithItem(_ item: Item) {
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        if item is Folder {
            iconImage = UIImage(systemName: "folder")!
            if AppState.shared.style == .list {
                accessories = [.disclosureIndicator()]
            } else {
                accessories = []
            }
        } else {
            iconImage = UIImage(systemName: "doc.richtext")!
            accessories = []
        }
        iconImage.map { setIconImage($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconViewCell {
    func configureHierarchy() {
        setupContentForStyle(AppState.shared.style)
        
        //content.text = "abc"
        //content.textProperties.font = .boldSystemFont(ofSize: 38)
        //content.textProperties.alignment = .center
        
        
        
        iconSize = frame.height * cellFillRatioIcon
        
        /*
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
        }()*/

        //self.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        // self.addSubview(paddingViewTop)
        self.contentView.addSubview(iconView)
        //self.addSubview(paddingViewMiddle)
        //self.addSubview(nameLabel)
        
        // top padding view setup
        /*
        paddingViewTop.widthAnchor.constraint(equalToConstant: 0).isActive = true
        paddingViewTop.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: paddingToViewMul * 4).isActive = true
        paddingViewTop.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        paddingViewTop.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        */
        // icon View constraints
        //self.contentView.translatesAutoresizingMaskIntoConstraints = false

        gridLayoutConstraints = (
            iconViewCenterX: iconView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            iconViewCenterY: iconView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: self.cellFillRatioIcon),
            iconViewHeight: iconView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: self.cellFillRatioIcon)
        )
        

        
        listLayoutConstraints = (
            iconViewLeading: iconView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            iconViewTop: iconView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            iconViewBottom: iconView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor))
                
        activateConstraintsForStyle(AppState.shared.style)
        

        
        //iconView.topAnchor.constraint(equalTo: paddingViewTop.bottomAnchor, constant: 0).isActive = true
        /*
        // middle padding view setup
        paddingViewMiddle.widthAnchor.constraint(equalToConstant: 0).isActive = true
        paddingViewMiddle.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: paddingToViewMul).isActive = true
        paddingViewMiddle.topAnchor.constraint(equalTo: self.iconView.bottomAnchor).isActive = true
        paddingViewMiddle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: paddingViewMiddle.bottomAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 - 2 * paddingToViewMul).isActive = true
        nameLabel.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor, multiplier: cellFillRatioText).isActive = true
        */
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}

extension IconViewCell {
    func configureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChangeNotification(_:)),
            name: Store.changeNotification,
            object: nil)
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        if notification.object is AppState {
            DispatchQueue.main.async {
                self.setupContentForStyle(AppState.shared.style)
                self.activateConstraintsForStyle(AppState.shared.style)
            }
        }
    }
    
    func activateConstraintsForStyle(_ style: DirectoryViewStyle) {
        switch style {
        case .icons:
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.listLayoutConstraints.map { NSLayoutConstraint.deactivate([$0.iconViewLeading, $0.iconViewTop, $0.iconViewBottom, $0.iconViewWidth]) }
                self.gridLayoutConstraints.map { NSLayoutConstraint.activate([$0.iconViewCenterX, $0.iconViewCenterY, $0.iconViewWidth, $0.iconViewHeight]) }
                self.layoutIfNeeded()
              }, completion: nil)

        case .list:
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.gridLayoutConstraints.map { NSLayoutConstraint.deactivate([$0.iconViewCenterX, $0.iconViewCenterY, $0.iconViewWidth, $0.iconViewHeight]) }
                self.listLayoutConstraints.map { NSLayoutConstraint.activate([$0.iconViewLeading, $0.iconViewTop, $0.iconViewBottom, $0.iconViewWidth]) }
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func setupContentForStyle(_ style: DirectoryViewStyle) {
        switch style {
        case .icons:
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / self.traitCollection.displayScale
            self.backgroundConfiguration = background
            
            contentConfiguration = nil
            accessories = []
        case .list:
            var background = UIBackgroundConfiguration.listPlainCell()
            self.backgroundConfiguration = background

            var content = self.defaultContentConfiguration()
            contentConfiguration = content
            
            if item is Folder {
                accessories = [.disclosureIndicator()]
            }
            /*
            var background = UIBackgroundConfiguration.listPlainCell()
            self.backgroundConfiguration = background
            */
        }
        
        /*
        switch style {
        case .icons:
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / self.traitCollection.displayScale
            self.backgroundConfiguration = background
            
            accessories = []
            contentConfiguration = nil
        case .list:
            var content = self.defaultContentConfiguration()
            contentConfiguration = content
            accessories = [.disclosureIndicator()]
            
            content.directionalLayoutMargins = .zero
            
            self.backgroundConfiguration = nil
        }
         */
         
    }
}
