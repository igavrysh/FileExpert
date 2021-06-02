//
//  DirectoryViewController.swift
//  FileExpert
//
//  Created by new on 6/1/21.
//

import UIKit

class DirectoryViewController: UIViewController {
    
    let iconSize: CGFloat = 100
    
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
            cell.updateWithItem(item)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: directoryCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        //var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        //snapshot.appendSections([.main])
        //snapshot.appendItems([])
        //dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension DirectoryViewController {
        
    func createListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func createGridLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let padding: CGFloat = 5
            let columns: CGFloat = (contentSize.width / (self.iconSize + padding * 2)).rounded(.down)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / columns),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(1.0 / columns))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)

            return section
        }
        return layout
    }
    
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
    
            //let spacing = CGFloat(0)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            // instead of .absolute(120)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(120))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            //group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            //section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            return section
        }
        return layout
    }
    
    func configureHierarchy() {
        view.backgroundColor = .systemBackground
        let layout = createGridLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.directoryCollectionView = collectionView
    }
}

fileprivate extension String {
    static let fileExpert = NSLocalizedString("File Expert", comment: "Heading for the list of files and Folders")
}
