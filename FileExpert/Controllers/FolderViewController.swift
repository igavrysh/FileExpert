//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit
import Foundation

struct StyleInfo {
    let cellId: String
    let flow: UICollectionViewDelegateFlowLayout
    let nextIconImage: UIImage
}

class FolderViewController: BaseListController,
                            UICollectionViewDelegateFlowLayout
{
    let sheetService = SheetService()
    var directory: Directory? = nil
    var appState: AppState
    
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
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.color = .black
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    } ()
    
    var toggleButton = UIBarButtonItem()
    
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
        collectionView.register(
            IconViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.icons))
        collectionView.register(
            ListViewCell.self,
            forCellWithReuseIdentifier: getCellId(for: DirectoryViewStyle.list))
        collectionView.backgroundColor = .white
        
        if let currDir = self.directory {
            self.title = currDir.name
        } else {
            self.title = "File Expert"
        }
        toggleButton.style = .plain
        toggleButton.target = self
        toggleButton.action = #selector(onToggleButtonTap(_:))
        toggleButton.image = getNextImageIcon()
        self.navigationItem.rightBarButtonItem = toggleButton
    }
    
    @objc func onToggleButtonTap(_ sender: AnyObject) {
        self.appState.toggleNextStyle()
        // TODO: refactor appstate to be observable and every FolderController should observe changes in it and
        // react accordingly
        _ = self.navigationController?.viewControllers.map{ $0 as? FolderViewController }.map{ $0?.updateUI() }
        updateUI()
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? IconViewCell {
            cell.highlight()
        }
        if let newDir = directory?.directory(at: indexPath.item) {
            let childVC = FolderViewController(appState: self.appState)
            childVC.directory = newDir
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(childVC, animated: true)
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ItemView
        directory
            .flatMap({ $0.item(at: indexPath.item) })
            .map({ cell.updateUIWithItem($0) })
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.directory?.itemsCount() ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? IconViewCell {
            cell.highlight()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? IconViewCell {
            cell.unhighlight()
        }
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
    
}
