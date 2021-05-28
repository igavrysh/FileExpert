//
//  HorizontalStackView.swift
//  FileExpert
//
//  Created by new on 5/28/21.
//

import UIKit

class HorizontalStackView: UIStackView {
    
    init(arrangedSubviews: [UIView], spacing: CGFloat = 0) {
        super.init(frame: .zero)
        arrangedSubviews.forEach({ addArrangedSubview($0) })
        self.axis = .horizontal
        self.spacing = spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
