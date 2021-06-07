//
//  ListViewCell.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class IconViewCell: UICollectionViewListCell {
   
    static let reuseIdentifier = "icon-view-cell-reuse-identifier"
    
    var item: Item? = nil
    
    static let testing = false
    
    let cellFillRatioIcon: CGFloat = 0.6
    let cellFillRatioText: CGFloat = 0.3
    let cellFillRatioSpacing: CGFloat = (1.0 - 0.6 - 0.3) / 3.0
    
    private var gridLayoutConstraints: (alignmentView1Top: NSLayoutConstraint,
                                        alignmentView1Leading: NSLayoutConstraint,
                                        alignmentView1Width: NSLayoutConstraint,
                                        alignmentView1Height: NSLayoutConstraint,
                                        
                                        iconViewTop: NSLayoutConstraint,
                                        iconViewCenterX: NSLayoutConstraint,
                                        iconViewWidth: NSLayoutConstraint,
                                        iconViewHeight: NSLayoutConstraint,
                                        
                                        alignmentView2Top: NSLayoutConstraint,
                                        alignmentView2Leading: NSLayoutConstraint,
                                        alignmentView2Width: NSLayoutConstraint,
                                        alignmentView2Height: NSLayoutConstraint,
                                        
                                        nameLabelTop: NSLayoutConstraint,
                                        nameLabelLeft: NSLayoutConstraint,
                                        nameLabelRight: NSLayoutConstraint,
                                        nameLabelHegith: NSLayoutConstraint,
                                        nameLabelCenterX: NSLayoutConstraint)?
    
    private var listLayoutConstraints: (listViewLeft: NSLayoutConstraint,
                                        listViewTop: NSLayoutConstraint,
                                        listViewBottom: NSLayoutConstraint,
                                        listViewWidth: NSLayoutConstraint,
                                        nameLabelCenterY: NSLayoutConstraint,
                                        nameLabelLeft: NSLayoutConstraint,
                                        nameLabelRight: NSLayoutConstraint)?
    
    let iconView: UIImageView = {
        var i = UIImageView()
        if IconViewCell.testing {
            i.backgroundColor = .blue
        }
        i.contentMode = .scaleAspectFit
        return i
    }()
    var iconSize: CGFloat = 0
    
    let nameLabel: UILabel = {
        var l = UILabel()
        l.text = "placehodler"
        l.font = .systemFont(ofSize: 14)
        l.numberOfLines = 2
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        //l.adjustsFontSizeToFitWidth = true
        //l.baselineAdjustment = .alignBaselines
        if IconViewCell.testing {
            l.backgroundColor = .green
        }
        return l
    }()
    
    let alignmentView1: UIView = {
        var v = UIView()
        if IconViewCell.testing {
            v.backgroundColor = .orange
        }
        return v
    }()
    
    let alignmentView2: UIView = {
        var v = UIView()
        if IconViewCell.testing {
            v.backgroundColor = .orange
        }
        return v
    }()
    
    let alignmentView3: UIView = {
        var v = UIView()
        if IconViewCell.testing {
            v.backgroundColor = .orange
        }
        return v
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
    
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        alignmentView1.translatesAutoresizingMaskIntoConstraints = false
        alignmentView2.translatesAutoresizingMaskIntoConstraints = false
        alignmentView3.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(alignmentView1)
        self.addSubview(alignmentView2)
        self.addSubview(alignmentView3)
        self.addSubview(iconView)
        self.addSubview(nameLabel)

        gridLayoutConstraints = (
            alignmentView1Top: alignmentView1.topAnchor.constraint(equalTo: topAnchor),
            alignmentView1Leading: alignmentView1.leadingAnchor.constraint(equalTo: leadingAnchor),
            alignmentView1Width: alignmentView1.widthAnchor.constraint(equalToConstant: 30),
            alignmentView1Height: alignmentView1.heightAnchor.constraint(equalTo: heightAnchor, multiplier: cellFillRatioSpacing),
            
            iconViewTop: iconView.topAnchor.constraint(equalTo: self.alignmentView1.bottomAnchor),
            iconViewCenterX: iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: cellFillRatioIcon),
            iconViewHeight: iconView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: cellFillRatioIcon),
            
            alignmentView2Top: alignmentView2.topAnchor.constraint(equalTo: iconView.bottomAnchor),
            alignmentView2Leading: alignmentView2.leadingAnchor.constraint(equalTo: leadingAnchor),
            alignmentView2Width: alignmentView2.widthAnchor.constraint(equalToConstant: 30),
            alignmentView2Height: alignmentView2.heightAnchor.constraint(equalTo: heightAnchor, multiplier: cellFillRatioSpacing),
            
            nameLabelTop: nameLabel.topAnchor.constraint(equalTo: alignmentView2.bottomAnchor),
            nameLabelLeft: nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 3),
            nameLabelRight: nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -3),
            nameLabelHegith: nameLabel.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: cellFillRatioText),
            nameLabelCenterX: nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        )
        
        listLayoutConstraints = (
            listViewLeft: iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3),
            listViewTop: iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            listViewBottom: iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
            listViewWidth: iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            nameLabelCenterY: nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nameLabelLeft: nameLabel.leadingAnchor.constraint(equalTo: self.iconView.trailingAnchor, constant: 0),
            nameLabelRight: nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3)
        )
                
        activateConstraintsForStyle(AppState.shared.style, animated: false)
        
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
                self.listLayoutConstraints?.nameLabelCenterY.isActive = false
                self.listLayoutConstraints?.nameLabelLeft.isActive = false
                self.listLayoutConstraints?.nameLabelRight.isActive = false
                
                self.gridLayoutConstraints.map {
                    $0.alignmentView1Top.isActive = true
                    $0.alignmentView1Leading.isActive = true
                    $0.alignmentView1Width.isActive = true
                    $0.alignmentView1Height.isActive = true
                    $0.iconViewTop.isActive = true
                    $0.iconViewCenterX.isActive = true
                    $0.iconViewWidth.isActive = true
                    $0.iconViewHeight.isActive = true
                    $0.alignmentView2Top.isActive = true
                    $0.alignmentView2Leading.isActive = true
                    $0.alignmentView2Width.isActive = true
                    $0.alignmentView2Height.isActive = true
                    $0.nameLabelTop.isActive = true
                    $0.nameLabelLeft.isActive = true
                    $0.nameLabelRight.isActive = true
                    $0.nameLabelHegith.isActive = true
                    $0.nameLabelCenterX.isActive = true
                }
                
                self.nameLabel.numberOfLines = 2
                self.nameLabel.textAlignment = .center
 
            }
            
            fromListToGrid()
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        case .list:
            
            let fromGridToListIcon = { () -> Void in
                self.gridLayoutConstraints.map {
                    $0.alignmentView1Top.isActive = false
                    $0.alignmentView1Leading.isActive = false
                    $0.alignmentView1Width.isActive = false
                    $0.alignmentView1Height.isActive = false
                    $0.iconViewTop.isActive = false
                    $0.iconViewCenterX.isActive = false
                    $0.iconViewWidth.isActive = false
                    $0.iconViewHeight.isActive = false
                    $0.alignmentView2Top.isActive = false
                    $0.alignmentView2Leading.isActive = false
                    $0.alignmentView2Width.isActive = false
                    $0.alignmentView2Height.isActive = false
                    $0.nameLabelTop.isActive = false
                    $0.nameLabelLeft.isActive = false
                    $0.nameLabelRight.isActive = false
                    $0.nameLabelHegith.isActive = false
                    $0.nameLabelCenterX.isActive = false
                }
                self.listLayoutConstraints?.listViewWidth.isActive = true
                self.listLayoutConstraints?.listViewLeft.isActive = true
                self.listLayoutConstraints?.listViewTop.isActive = true
                self.listLayoutConstraints?.listViewBottom.isActive = true
                self.listLayoutConstraints?.nameLabelCenterY.isActive = true
                self.listLayoutConstraints?.nameLabelLeft.isActive = true
                self.listLayoutConstraints?.nameLabelRight.isActive = true
                self.nameLabel.numberOfLines = 1
                self.nameLabel.textAlignment = .left

            }
            
            fromGridToListIcon()
            
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { self.layoutIfNeeded()}, completion: nil)
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
