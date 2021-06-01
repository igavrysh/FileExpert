//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit

struct StyleInfo {
    let cellId: String
    let flow: UICollectionViewDelegateFlowLayout
    let nextIconImage: UIImage
}


class FolderViewController: BaseListController,
                            UICollectionViewDelegateFlowLayout
{
    
    var folder: Folder = Store.shared.rootFolder {
        didSet {
            collectionView.reloadData()
            if folder === folder.store?.rootFolder {
                title = .fileExpert
            } else {
                title = folder.name
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(folder: Folder) {
        self.init()
        self.folder = folder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var appState: AppState = AppState(style: .icons)
    
    let info: [DirectoryViewStyle: StyleInfo] = [
        DirectoryViewStyle.icons : StyleInfo(
            cellId: "iconViewCellId",
            flow: IconsFlowLayout(),
            nextIconImage: UIImage(systemName: "text.justify")!.imageWith(newSize: CGSize.init(width: 24, height: 16))
        ),
        DirectoryViewStyle.list : StyleInfo(
            cellId: "listViewCellId",
            flow: ListFlowLayout(),
            nextIconImage: UIImage(systemName: "square.grid.3x2.fill")!.imageWith(newSize: CGSize.init(width: 24, height: 16))
        )]
    
    func getCellId(for ownStyle: DirectoryViewStyle) -> String {
        return info[ownStyle]!.cellId
    }
    
    func getCellId() -> String {
        return getCellId(for: appState.style)
    }
    
    func getFlow() -> UICollectionViewDelegateFlowLayout  {
        return info[appState.style]!.flow
    }
    
    func getNextImageIcon() -> UIImage {
        return info[appState.style]!.nextIconImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChangeNotification(_:)),
            name: Store.changeNotification,
            object: nil)
        
        Store.shared.load()
    }
    
    func setupUI() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.register(
            IconViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.icons))
        collectionView.register(
            ListViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.list))
        collectionView.backgroundColor = .white
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            if #available(iOS 11.0, *) {
                flowLayout.sectionInsetReference = .fromSafeArea
            }
        }
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
        
        if let changeReason = userInfo[Item.changeReasonKey] as? String {
            let newValue = userInfo[Item.newValueKey]
            let oldValue = userInfo[Item.oldValueKey]
            switch (changeReason, newValue, oldValue) {
            case let (Item.added, (newIndex as Int)?, _):
                
                DispatchQueue.main.async { [weak self] in
                    if self?.folder.contents.count == 1 {
                        self?.collectionView.reloadData()
                        return
                    }
                    
                    self?.collectionView.insertItems(at: [IndexPath(row: newIndex, section: 0)])
                }
            default:
                collectionView.reloadData()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemView {
            cell.highlight()
        }
        /*
        if let newDir = directory?.directory(at: indexPath.item) {
            let childVC = FolderViewController(appState: self.appState)
            childVC.directory = newDir
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(childVC, animated: true)
        }
        */
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemView {
            cell.unhighlight()
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cellId = getCellId()
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ItemView else {
            return UICollectionViewCell()
        }
        
        cell.updateWith(folder.contents[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folder.contents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        /*
        if let cell = collectionView.cellForItem(at: indexPath) as? IconViewCell {
            cell.highlight()
        }
 */
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        /*
        if let cell = collectionView.cellForItem(at: indexPath) as? IconViewCell {
            cell.unhighlight()
        }
 */
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let size = getFlow().collectionView?(
                collectionView,
                layout: collectionViewLayout,
                sizeForItemAt: indexPath
        ) else {
            return CGSize.zero
        }
        return size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let insets = getFlow().collectionView?(
                collectionView,
                layout: collectionViewLayout,
                insetForSectionAt: section
        ) else {
            return UIEdgeInsets.zero
        }
        return insets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let spacing = getFlow().collectionView?(
                collectionView,
                layout: collectionViewLayout,
                minimumLineSpacingForSectionAt: section
        ) else {
            return CGFloat.zero
        }
        return spacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let spacing = getFlow().collectionView?(
                collectionView,
                layout: collectionViewLayout,
                minimumInteritemSpacingForSectionAt: section
        ) else {
            return CGFloat.zero
        }
        return spacing
    }
 
    
    
    
    /*
    
    let sheetService = SheetService()
    var directory: Directory? = nil
    
    
    func getCellId(for ownStyle: DirectoryViewStyle) -> String {
        return info[ownStyle]!.cellId
    }
    
    func getCellId() -> String {
        return getCellId(for: appState.style)
    }
    
    func getFlow() -> UICollectionViewDelegateFlowLayout  {
        return info[appState.style]!.flow
    }
    
    func getNextImageIcon() -> UIImage {
        return info[appState.style]!.nextIconImage
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.color = .black
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    } ()
    
    var toggleButton = UIBarButtonItem()
    var userButton = UIBarButtonItem()
    var addFileButton = UIBarButtonItem()
    var addDirectoryButton = UIBarButtonItem()
    
    init(appState: AppState) {
        self.appState = appState
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if self.directory == nil {
            view.addSubview(activityIndicatorView)
            activityIndicatorView.fillSuperview()
            fetchData()
        }
    }
    
    func setupUI() {
        self.view.backgroundColor = .blue
        setupCollectionView()
        setupTitle()
        setupToolbar()
    }
    
    func setupCollectionView() {
        collectionView.register(
            IconViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.icons))
        collectionView.register(
            ListViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.list))
        collectionView.backgroundColor = .white
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            if #available(iOS 11.0, *) {
                flowLayout.sectionInsetReference = .fromSafeArea
            }
        }
    }
    
    func setupTitle() {
        if let currDir = self.directory {
            self.title = currDir.name
        } else {
            self.title = "File Expert"
        }
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
        self.toggleButton = genButtonWithImage(getNextImageIcon())
        self.addFileButton = genButtonWithImage(UIImage(systemName: "doc.badge.plus")!)
        self.addDirectoryButton = genButtonWithImage(UIImage(systemName: "plus.rectangle.on.folder")!)
        self.userButton = genButtonWithImage(UIImage(systemName: "person")!)
        self.navigationItem.rightBarButtonItems = [self.toggleButton, self.addDirectoryButton, self.addFileButton]
        
        if directory?.isRootDirectory ?? true == true {
            self.navigationItem.leftBarButtonItem = userButton
        }
    }
    
    @objc func onToolbarButtonTap(_ sender: NSObject) {
        self.appState.toggleNextStyle()
        // TODO: refactor appstate to be observable and every FolderController should observe changes in it and
        // react accordingly
        if sender == self.toggleButton {
            _ = self.navigationController?.viewControllers.map{ $0 as? FolderViewController }.map{ $0?.updateUI() }
            updateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = self.collectionView.indexPathsForSelectedItems?.map { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ItemView {
                cell.unhighlight()
            }
        }
    }
    
    fileprivate func updateUI() {
        toggleButton.image = getNextImageIcon()
        self.collectionView.reloadData()
    }
    
    // TODO: make model observable so that it notifies controller when it loads / refreshes / receives updates
    fileprivate func fetchData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.sheetService.fetchSheet(completion: { [weak self] (sheet: Sheet?, error: Error?) -> () in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let sheet = sheet {
                    self?.directory = dirFromSheet(sheet)
                    DispatchQueue.main.async {
                        self.map {
                            $0.activityIndicatorView.stopAnimating()
                            $0.updateUI()
                        }
                    }
                }
            })
        }
    }
    
  
 */
    

    
}


fileprivate extension String {
    static let fileExpert = NSLocalizedString("File Expert", comment: "Heading for the list of files and Folders")
}
