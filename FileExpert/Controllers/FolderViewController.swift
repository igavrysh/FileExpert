//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit
import Foundation

enum FolderStyle: Int {
    case icons
    case list
}

class FolderViewController: BaseListController,
                            UICollectionViewDelegateFlowLayout
{
    var style: FolderStyle
    
    let sheetService = SheetService()
    var directory: Directory? = nil
    
    let cellId = "id"
    
    var flows: [UICollectionViewDelegateFlowLayout] = [IconsFlowLayout()]
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.color = .black
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    } ()
    
    init(style: FolderStyle) {
        self.style = style
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blue
        collectionView.register(IconViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        if let currDir = self.directory {
            self.title = currDir.name
        } else {
            self.title = "File Expert"
            view.addSubview(activityIndicatorView)
            activityIndicatorView.fillSuperview()
            fetchData()
        }
        
        let emailButton = UIBarButtonItem(
            image: UIImage(systemName: "envelope")!, landscapeImagePhone: UIImage(systemName: "envelope")!,
            style: .plain,
            target: self,
            action: #selector(action(_:)))
        self.navigationItem.rightBarButtonItem = emailButton
    }
    
    @objc func action(_ sender: AnyObject) {
        Swift.debugPrint("CustomRightViewController IBAction invoked")
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
            let childVC = FolderViewController(style: .icons)
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
        guard let size = currentFlow().collectionView?(
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
        guard let insets = currentFlow().collectionView?(
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
        guard let spacing = currentFlow().collectionView?(
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
        guard let spacing = currentFlow().collectionView?(
                collectionView,
                layout: collectionViewLayout,
                minimumInteritemSpacingForSectionAt: section
        ) else {
            return CGFloat.zero
        }
        return spacing
    }
    
    func currentFlow() -> UICollectionViewDelegateFlowLayout {
        return flows[style.rawValue]
    }
}
