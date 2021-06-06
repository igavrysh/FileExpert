//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewListCell {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    static let testing = false
    
    let cellFillRatioIcon: CGFloat = 0.75
    let cellFillRatioText: CGFloat = 0.30
    
    private var gridLayoutConstraints: (iconViewCenterX: NSLayoutConstraint,
                                        iconViewCenterY: NSLayoutConstraint,
                                        iconViewWidth: NSLayoutConstraint,
                                        iconViewHeight: NSLayoutConstraint)?
    
    private var listLayoutConstraints: (listViewLeft: NSLayoutConstraint,
                                        listViewTop: NSLayoutConstraint,
                                        listViewBottom: NSLayoutConstraint,
                                        listViewWidth: NSLayoutConstraint)?
    
    let iconView: UIImageView = {
        var i = UIImageView()
        if IconViewCell.testing {
            i.backgroundColor = .blue
        }
        i.contentMode = .scaleAspectFit
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureObserver()
    }
    
    func updateWithItem(_ item: Item) {
        self.item = item
        nameLabel.text = item.name
        var iconImage: UIImage? = nil
        if item is Directory {
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
        self.addSubview(iconView)
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
            iconViewCenterX: iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconViewCenterY: iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: self.cellFillRatioIcon),
            iconViewHeight: iconView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: self.cellFillRatioIcon))
        
        listLayoutConstraints = (
            listViewLeft: iconView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            listViewTop: iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            listViewBottom: iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
            listViewWidth: iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor)
            //listViewWidth: iconView.widthAnchor.constraint(equalToConstant: 10)
        )
                
        activateConstraintsForStyle(AppState.shared.style, animated: false)
        

        
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
                self.activateConstraintsForStyle(AppState.shared.style, animated: true)
            }
        }
    }
    
    func activateConstraintsForStyle(_ style: DirectoryViewStyle, animated: Bool) {
        switch style {
        case .icons:
            let fromListToGrid = { () -> Void in
                self.listLayoutConstraints?.listViewWidth.isActive = false
                self.listLayoutConstraints?.listViewLeft.isActive = false
                self.listLayoutConstraints?.listViewTop.isActive = false
                self.listLayoutConstraints?.listViewBottom.isActive = false
                self.gridLayoutConstraints?.iconViewWidth.isActive = true
                self.gridLayoutConstraints?.iconViewHeight.isActive = true
                self.gridLayoutConstraints?.iconViewCenterX.isActive = true
                self.gridLayoutConstraints?.iconViewCenterY.isActive = true
            }
            
            fromListToGrid()
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.layoutIfNeeded()
                }, completion: nil)
/*
                UIView.animate(withDuration: 1.0,
                               delay: 0.0,
                               usingSpringWithDamping: 0.0,
                               initialSpringVelocity: 0.1,
                               options: .curveEaseIn,
                               animations: { self.layoutIfNeeded() },
                               completion: nil)*/
            }
        case .list:
            
            let fromGridToList = { () -> Void in
                self.gridLayoutConstraints?.iconViewWidth.isActive = false
                self.gridLayoutConstraints?.iconViewHeight.isActive = false
                self.gridLayoutConstraints?.iconViewCenterX.isActive = false
                self.gridLayoutConstraints?.iconViewCenterY.isActive = true
                
                self.listLayoutConstraints?.listViewWidth.isActive = true
                self.listLayoutConstraints?.listViewLeft.isActive = true
                self.listLayoutConstraints?.listViewTop.isActive = true
                self.listLayoutConstraints?.listViewBottom.isActive = true
            }
            fromGridToList()
            
            if animated {
                /*
                UIView.animate(withDuration: 1.0,
                               delay: 0.0,
                               usingSpringWithDamping: 0.0,
                               initialSpringVelocity: 0.1,
                               options: .curveEaseIn,
                               animations: {
                                self.layoutIfNeeded()
                                
                               },
                               completion: nil)
                 */
           
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.layoutIfNeeded()
                    }, completion: nil)
            }
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
            
            if item is Directory {
                accessories = [.disclosureIndicator()]
            }
        }
    }
}
