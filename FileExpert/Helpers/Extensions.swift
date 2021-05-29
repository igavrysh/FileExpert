//
//  Extensions.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont, numberOfLines: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.numberOfLines = numberOfLines
    }
}

extension UILabel {
    @discardableResult func fitFontForSize(
        _ constrainedSize: CGSize,
        maxFontSize: CGFloat = 100,
        minFontSize: CGFloat = 5,
        accuracy: CGFloat = 1
    ) -> CGSize {
        assert(maxFontSize > minFontSize)

        var minFontSize = minFontSize
        var maxFontSize = maxFontSize
        var fittingSize = constrainedSize

        while maxFontSize - minFontSize > accuracy {
            let midFontSize: CGFloat = ((minFontSize + maxFontSize) / 2)
            font = font.withSize(midFontSize)
            fittingSize = sizeThatFits(constrainedSize)
            if fittingSize.height <= constrainedSize.height
                && fittingSize.width <= constrainedSize.width {
                minFontSize = midFontSize
            } else {
                maxFontSize = midFontSize
            }
        }
        return fittingSize
    }
    
    @discardableResult func fontSizeToFitSize(
        _ constrainedSize: CGSize,
        maxFontSize: CGFloat = 100,
        minFontSize: CGFloat = 5,
        accuracy: CGFloat = 1
    ) -> CGFloat {
        assert(maxFontSize > minFontSize)

        var minFontSize = minFontSize
        var maxFontSize = maxFontSize
        var fittingSize = constrainedSize

        while maxFontSize - minFontSize > accuracy {
            let midFontSize: CGFloat = ((minFontSize + maxFontSize) / 2)
            font = font.withSize(midFontSize)
            fittingSize = sizeThatFits(constrainedSize)
            if fittingSize.height <= constrainedSize.height
                && fittingSize.width <= constrainedSize.width {
                minFontSize = midFontSize
            } else {
                maxFontSize = midFontSize
            }
        }
        return (minFontSize + maxFontSize) / 2
    }
}

extension UIImageView {
    convenience init(cornerRadius: CGFloat) {
        self.init(image: nil)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

extension UIButton {
    convenience init(title: String) {
        self.init(type: .system)
        self.setTitle(title, for: .normal)
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }

        return image.withRenderingMode(self.renderingMode)
    }
}
