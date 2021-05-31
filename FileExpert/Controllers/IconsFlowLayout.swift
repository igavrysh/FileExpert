//
//  IconsFlowLayout.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import UIKit

class IconsFlowLayout: NSObject, UICollectionViewDelegateFlowLayout {
    
    let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    let numberOfItemsPerRow: CGFloat = 3.0
    let spacingBetweenCells: CGFloat = 4.0
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let safeAreaWidth = collectionView.bounds.width
            - collectionView.safeAreaInsets.left
            - collectionView.safeAreaInsets.right
        let totalSpacing = (2 * sectionInsets.left)
            + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        let width = (safeAreaWidth - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return spacingBetweenCells
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    
}
