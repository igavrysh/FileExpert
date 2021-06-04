//
//  DirectoryViewController.swift
//  FileExpert
//
//  Created by new on 6/1/21.
//

import UIKit

class DirectoryViewController: UIViewController {
    
    let iconSize: CGFloat = 100
    
    var titleText: String = .fileExpert {
        didSet {
            title = titleText
        }
    }
    
    let folder: Folder
    
    var toggleButton: UIBarButtonItem!
    var userButton: UIBarButtonItem!
    var addFileButton: UIBarButtonItem!
    var addDirectoryButton: UIBarButtonItem!
    
    enum Section: CaseIterable {
        case main
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    convenience init() {
        self.init(folder: Store.shared.rootFolder)
    }
    
    init(folder: Folder) {
        self.folder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleText
        configureHierarchy()
        configureDataSource()
        configureObserver()
        Store.shared.load()
    }
}

extension DirectoryViewController {
    
    @objc func onToolbarButtonTap(_ sender: NSObject) {
        if sender == self.toggleButton {
            AppState.shared.toggleNextStyle()
        }
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
        if notification.object is Item {
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
        
        if notification.object is AppState {
            toggleButton.image = getAppStateIconImage()
            collectionView.setCollectionViewLayout(getLayout(), animated: true)
        }
    }
}

extension DirectoryViewController {
    func configureDataSource() {
        
        let gridCellRegistration = createGridCellRegistration()
        // data source
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: item)
        }
        
        /*
        let iconViewCellRegistration = createIconViewCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: iconViewCellRegistration, for: indexPath, item: identifier)
        }
         */
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(folder.contents)
        dataSource.apply(snapshot, animatingDifferences: true)
         
    }
    
    func createIconViewCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        return UICollectionView.CellRegistration<IconCell, Item>{ (cell, indexPath, item) in
            cell.updateWithItem(item)
        }
    }
    
    func createGridCellRegistration() -> UICollectionView.CellRegistration<IconCell, Item> {
        return UICollectionView.CellRegistration<IconCell, Item> { (cell, indexPath, item) in
            cell.updateWithItem(item)
            cell.accessories = [.disclosureIndicator()]

            /*
            
            var content = UIListContentConfiguration.cell()
            if item is Folder {
                content.text = "folder"
            } else {
                content.text = "file"
            }
            content.image = UIImage(systemName: "folder")

            content.textProperties.font = .boldSystemFont(ofSize: 38)
            content.textProperties.alignment = .center
            content.directionalLayoutMargins = .zero
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
             */
        }
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
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
        
        /*
        
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
         */
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
    
    func getLayout() -> UICollectionViewLayout {
        var layout: UICollectionViewLayout!
        switch AppState.shared.style {
        case .icons:
            layout = createGridLayout()
        default:
            layout = createListLayout()
        }
        return layout
    }
    
    func configureHierarchy() {
        view.backgroundColor = .systemBackground
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createGridLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        self.collectionView = collectionView
        setupToolbar()
    }
    
    func setupToolbar() {
        let genButtonWithImage = {[weak self] (image: UIImage) -> UIBarButtonItem in
            let b = UIBarButtonItem()
            b.style = .plain
            b.target = self
            b.action = #selector(self?.onToolbarButtonTap(_:))
            b.image = image
            return b
        }
        toggleButton = genButtonWithImage(getAppStateIconImage())
        addFileButton = genButtonWithImage(DirectoryViewController.addFileIcon)
        addDirectoryButton = genButtonWithImage(DirectoryViewController.addDirectoryIcon)
        userButton = genButtonWithImage(DirectoryViewController.userIcon)
        navigationItem.rightBarButtonItems = [toggleButton, addDirectoryButton, addFileButton]
        
        if folder.isRoot == true {
            navigationItem.leftBarButtonItem = userButton
        }
    }
    
    func getAppStateIconImage() -> UIImage {
        return DirectoryViewController.appStateIcons[AppState.shared.style]!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }) { (context) in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                self.collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
}

extension DirectoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        if let folder = item as? Folder {
            let vc = DirectoryViewController(folder: folder)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

fileprivate extension String {
    static let fileExpert = NSLocalizedString("File Expert", comment: "Heading for the list of files and Folders")
}

extension DirectoryViewController {
    static let appStateIcons: [DirectoryViewStyle: UIImage] = [
        .icons: UIImage(systemName: "square.grid.3x2.fill")!,
        .list: UIImage(systemName: "text.justify")!
    ]
    
    static let addFileIcon = UIImage(systemName: "doc.badge.plus")!
    
    static let addDirectoryIcon = UIImage(systemName: "plus.rectangle.on.folder")!
    
    static let userIcon = UIImage(systemName: "person")!
}
