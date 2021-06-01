//
//  DirectoryViewController.swift
//  FileExpert
//
//  Created by new on 6/1/21.
//

import UIKit

class DirectoryViewController: UIViewController {
    
    var folder: Folder = Store.shared.rootFolder {
        didSet {
            directoryCollectionView.reloadData()
            if folder === folder.store?.rootFolder {
                title = .fileExpert
            } else {
                title = folder.name
            }
        }
    }
    
    enum Section: CaseIterable {
        case main
    }
    
    var directoryCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureObserver()
        Store.shared.load()
    }
}

extension DirectoryViewController {
    func configureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChangeNotification(_:)),
            name: Store.changeNotification,
            object: nil)
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        // Handle change to the current folder
        if let item = notification.object as? Folder,
           item === folder {
            let reason = notification.userInfo?[Item.changeReasonKey] as? String
            if reason == Item.removed {
            }
        }
        
        // Handle changes of current folder
        guard let userInfo = notification.userInfo,
              userInfo[Item.parentFolderKey] as? Folder === folder
        else {
            return
        }
        
        let items = folder.contents
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension DirectoryViewController {
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<IconViewCell, Item> { (cell, indexPath, item) in
            cell.updateWith(item)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: directoryCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
}

extension DirectoryViewController {
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            var columns = 3
            if contentSize.width > 600 {
                columns = 4
            }
            if contentSize.width > 1000 {
                columns = 5
            }
    
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(120))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
        return layout
    }
    
    func configureHierarchy() {
        view.backgroundColor = .systemBackground
        let layout = createLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)

        let views = ["cv": collectionView]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[cv]|", options: [], metrics: nil, views: views))
        constraints.append(collectionView.topAnchor.constraint(
            equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        NSLayoutConstraint.activate(constraints)
        self.directoryCollectionView = collectionView
    }
}

fileprivate extension String {
    static let fileExpert = NSLocalizedString("File Expert", comment: "Heading for the list of files and Folders")
}
