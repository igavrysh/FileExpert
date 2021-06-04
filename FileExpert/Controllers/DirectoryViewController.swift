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
    
    var directoryCollectionView: UICollectionView!
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
        applySnapshot()
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
            applySnapshot()
        }
        
        if notification.object is AppState {
            var topIndexPath: IndexPath?
            
            for cell in directoryCollectionView.visibleCells {
                guard let tip = topIndexPath else {
                    topIndexPath = directoryCollectionView.indexPath(for: cell)
                    continue
                }
                if let indexPath = directoryCollectionView.indexPath(for: cell) {
                    if tip.item > indexPath.item {
                        topIndexPath = indexPath
                    }
                }
            }
            let selectedIndexPath = directoryCollectionView.indexPathsForSelectedItems?.first
            selectedIndexPath.map { directoryCollectionView.deselectItem(at: $0, animated: false) }
            directoryCollectionView.setCollectionViewLayout(getLayout(), animated: true) { (finished) in
                self.dataSource.apply(self.dataSource.snapshot(), animatingDifferences: false)
                self.directoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
                
                
                //topIndexPath?.map { self.directoryCollectionView.scrollToItem(at: $0, at: UICollectionView.ScrollPosition.bottom, animated: true) }
                selectedIndexPath.map {self.directoryCollectionView.selectItem(at: $0, animated: true, scrollPosition: []) }
                topIndexPath.map { self.directoryCollectionView.scrollToItem(at: $0, at: UICollectionView.ScrollPosition.centeredVertically, animated: true) }
            }
            //
            toggleButton.image = getAppStateIconImage()

            
            /*
            let selectedPaths: [IndexPath]? = directoryCollectionView
                .indexPathsForSelectedItems?
                .compactMap {(indexPath) in
                    self.directoryCollectionView.deselectItem(at: indexPath, animated: true)
                    return indexPath
                }
            */

            // { (finished) in
                /*
                _ = selectedPaths?.compactMap { indexPath in
                    self.directoryCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
                 */
            //}
        }
    }
}

extension DirectoryViewController {
    func configureDataSource() {
        let iconViewCellRegistration = createIconViewCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: directoryCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: iconViewCellRegistration, for: indexPath, item: identifier)
        }
    }
    
    func createIconViewCellRegistration() ->  UICollectionView.CellRegistration<IconViewCell, Item> {
        return UICollectionView.CellRegistration<IconViewCell, Item>{ (cell, indexPath, item) in
            cell.updateWithItem(item)
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(folder.contents)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension DirectoryViewController {
        
    func createListLayout() -> UICollectionViewLayout {
        /*
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
        */
         
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        return UICollectionViewCompositionalLayout.list(using: config)
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
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: getLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        self.directoryCollectionView = collectionView
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

