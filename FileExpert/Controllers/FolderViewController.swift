//
//  FolderViewController.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import UIKit
import Foundation

class FolderViewController: BaseListController, UICollectionViewDelegateFlowLayout {
    
    let sheetService = SheetService()
    var directory: Directory? = nil
    
    let cellId = "id"
    let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    let numberOfItemsPerRow: CGFloat = 3.0
    let spacingBetweenCells: CGFloat = 4.0
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.color = .black
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    
        collectionView.register(IconViewCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.fillSuperview()
        
        collectionView.backgroundColor = .white
        
        fetchData()
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
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! IconViewCell
        directory
            .flatMap({ $0.item(at: indexPath.row) })
            .map({ cell.updateUIWithItem($0) })
            //cell.backgroundColor = UIColor.yellow
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.directory?.itemsCount() ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = (2 * sectionInsets.left) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row

        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


}
