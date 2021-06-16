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
    
    private var listLayoutConstraints: (iconViewLeft: NSLayoutConstraint,
                                        iconViewTop: NSLayoutConstraint,
                                        iconViewBottom: NSLayoutConstraint,
                                        iconViewWidth: NSLayoutConstraint,
                                        nameLabelCenterY: NSLayoutConstraint,
                                        nameLabelLeft: NSLayoutConstraint,
                                        nameLabelRight: NSLayoutConstraint,
                                        separatorViewHeight: NSLayoutConstraint,
                                        separatorViewLeading: NSLayoutConstraint,
                                        separatorViewTrailing: NSLayoutConstraint,
                                        separatorViewBottom: NSLayoutConstraint)?
    var styleInternal: DirectoryViewStyle = .icons
    var style: DirectoryViewStyle {
        get{
            print("i can do editional work when setter set value  ")
            return self.styleInternal
        }
        set(newValue){
            self.styleInternal = newValue
            switch self.styleInternal {
            case .icons:
                var background = UIBackgroundConfiguration.listPlainCell()
                background.cornerRadius = 8
                background.strokeColor = .systemGray3
                background.strokeWidth = 1.0 / self.traitCollection.displayScale
                self.backgroundConfiguration = background
                contentConfiguration = nil
                accessories = []
            case .list:
                let background = UIBackgroundConfiguration.listPlainCell()
                self.backgroundConfiguration = background
                let content = self.defaultContentConfiguration()
                contentConfiguration = content
                if item is Directory {
                    accessories = [.disclosureIndicator()]
                }
            }
        }
    }
    
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
        l.font = .systemFont(ofSize: 12)
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
    
    let separatorView: UIView = {
        var v = UIView()
        if IconViewCell.testing {
            v.backgroundColor = .blue
        } else {
            v.backgroundColor = .systemGray3
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
        self.style = AppState.shared.style
        iconSize = frame.height * cellFillRatioIcon
        nameLabel.text = "placeholder"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        alignmentView1.translatesAutoresizingMaskIntoConstraints = false
        alignmentView2.translatesAutoresizingMaskIntoConstraints = false
        alignmentView3.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(alignmentView1)
        self.addSubview(alignmentView2)
        self.addSubview(alignmentView3)
        self.addSubview(iconView)
        self.addSubview(nameLabel)
        self.addSubview(separatorView)

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
            iconViewLeft: iconView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            iconViewTop: iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            iconViewBottom: iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            iconViewWidth: iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            
            nameLabelCenterY: nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nameLabelLeft: nameLabel.leadingAnchor.constraint(equalTo: self.iconView.trailingAnchor, constant: 0),
            nameLabelRight: nameLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            separatorViewHeight: separatorView.heightAnchor.constraint(equalToConstant: 0.3),
            separatorViewLeading: separatorView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            separatorViewTrailing: separatorView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            separatorViewBottom: separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        )
                
        activateConstraintsForStyle(AppState.shared.style, animated: false)
        
        UIImage(named: "placeholder").map{ setIconImage($0) }
    }
}

extension IconViewCell {
    
    func configureObserver() {
        NotificationCenter.default.addObserver(forName: AppState.changedNotification, object: nil, queue: OperationQueue.main, using: {n in self.handleChangeNotification(n)})
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        if let changeReason = notification.userInfo?[AppState.changeReasonKey] as? String,
           changeReason == AppState.styleChanged,
           let style = notification.userInfo?[AppState.styleKey] as? DirectoryViewStyle
        {
            self.activateConstraintsForStyle(style, animated: true)
            self.style = style
        }
    }
    
    var gridLayoutConstraintsArray: [NSLayoutConstraint]? {
        get {
            return self.gridLayoutConstraints.map {
                return [
                    $0.alignmentView1Top,
                    $0.alignmentView1Leading,
                    $0.alignmentView1Width,
                    $0.alignmentView1Height,
                    $0.iconViewTop,
                    $0.iconViewCenterX,
                    $0.iconViewWidth,
                    $0.iconViewHeight,
                    $0.alignmentView2Top,
                    $0.alignmentView2Leading,
                    $0.alignmentView2Width,
                    $0.alignmentView2Height,
                    $0.nameLabelTop,
                    $0.nameLabelLeft,
                    $0.nameLabelRight,
                    $0.nameLabelHegith,
                    $0.nameLabelCenterX]
            }
        }
    }
    
    var listLayoutConstraintsArray: [NSLayoutConstraint]? {
        get {
            return self.listLayoutConstraints.map {
                return [
                    $0.iconViewWidth,
                    $0.iconViewLeft,
                    $0.iconViewTop,
                    $0.iconViewBottom,
                    $0.nameLabelCenterY,
                    $0.nameLabelLeft,
                    $0.nameLabelRight,
                    $0.separatorViewHeight,
                    $0.separatorViewLeading,
                    $0.separatorViewTrailing,
                    $0.separatorViewBottom
                ]
            }
        }
    }
    
    func activateConstraintsForStyle(_ style: DirectoryViewStyle, animated: Bool) {
        var transformation: (() -> Void)? = nil
        switch style {
        case .icons:
            transformation = { () -> Void in
                self.listLayoutConstraintsArray.map { NSLayoutConstraint.deactivate($0) }
                self.gridLayoutConstraintsArray.map { NSLayoutConstraint.activate($0) }
                self.nameLabel.numberOfLines = 2
                self.nameLabel.textAlignment = .center
            }
        case .list:
            transformation = { () -> Void in
                self.gridLayoutConstraintsArray.map { NSLayoutConstraint.deactivate($0) }
                self.listLayoutConstraintsArray.map { NSLayoutConstraint.activate($0) }
                self.nameLabel.numberOfLines = 1
                self.nameLabel.textAlignment = .left
            }
        }
        transformation.map { $0() }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: { self.layoutIfNeeded()}, completion: nil)
        }
    }
}
