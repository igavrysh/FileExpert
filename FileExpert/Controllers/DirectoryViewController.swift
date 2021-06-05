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
    
    let directory: Directory
    
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
        self.init(directory: Store.shared.rootFolder)
    }
    
    init(directory: Directory) {
        self.directory = directory
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
        applyInitialSnapshot()
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
            DispatchQueue.main.async {
                self.applySnapshot()
            }
        }
        
        if notification.object is AppState {
            
            DispatchQueue.main.async { [self] in
                var topIndexPath: IndexPath?
                
                for cell in self.directoryCollectionView.visibleCells {
                    guard let tip = topIndexPath else {
                        topIndexPath = self.directoryCollectionView.indexPath(for: cell)
                        continue
                    }
                    if let indexPath = self.directoryCollectionView.indexPath(for: cell) {
                        if tip.item > indexPath.item {
                            topIndexPath = indexPath
                        }
                    }
                }
                let selectedIndexPath = self.directoryCollectionView.indexPathsForSelectedItems?.first
                selectedIndexPath.map { self.directoryCollectionView.deselectItem(at: $0, animated: false) }
                directoryCollectionView.setCollectionViewLayout(self.getLayout(), animated: true) { (finished) in
                    self.dataSource.apply(self.dataSource.snapshot(), animatingDifferences: false)
                    self.directoryCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
                    
                    
                    //topIndexPath?.map { self.directoryCollectionView.scrollToItem(at: $0, at: UICollectionView.ScrollPosition.bottom, animated: true) }
                    selectedIndexPath.map {self.directoryCollectionView.selectItem(at: $0, animated: true, scrollPosition: []) }
                    topIndexPath.map { self.directoryCollectionView.scrollToItem(at: $0, at: UICollectionView.ScrollPosition.centeredVertically, animated: true) }
                }
                //
                toggleButton.image = getAppStateIconImage()
            }
            

            
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
    
    func createSimpleGridCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewCell, Item> { (cell, indexPath, item) in
            var content = UIListContentConfiguration.cell()
            if item is Directory {
                content.text = "dir"
            } else {
                content.text = "file"
            }
            content.textProperties.font = .boldSystemFont(ofSize: 38)
            content.textProperties.alignment = .center
            content.directionalLayoutMargins = .zero
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
        }
    }

    
    func createIconViewCellRegistration() ->  UICollectionView.CellRegistration<IconViewCell, Item> {
        return UICollectionView.CellRegistration<IconViewCell, Item>{ (cell, indexPath, item) in
            cell.updateWithItem(item)
        }
    }
    
    func applyInitialSnapshot() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        var folderItemsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        folderItemsSnapshot.append(self.directory.contents)
        dataSource.apply(folderItemsSnapshot, to: .main, animatingDifferences: false)
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.directory.contents)
        self.dataSource.apply(snapshot, animatingDifferences: true)
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
        
        /*
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        return UICollectionViewCompositionalLayout.list(using: config)
         */
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
        
        if directory.isRoot == true {
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
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        if let directory = item as? Directory {
            let vc = DirectoryViewController(directory: directory)
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

