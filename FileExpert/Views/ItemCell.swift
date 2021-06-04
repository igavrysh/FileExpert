//
//  ItemCell.swift
//  FileExpert
//
//  Created by new on 6/3/21.
//

import UIKit

// Declare a custom key for a custom `item` property.
extension UIConfigurationStateCustomKey {
    static let item = UIConfigurationStateCustomKey("com.igavrysh.FileExpert.ItemCell.item")
}

// Declare an extension on the cell state struct to provide a typed property for this custom state.
extension UICellConfigurationState {
    var item: Item? {
        set { self[.item] = newValue }
        get { return self[.item] as? Item }
    }
}

// This cell subclass is an abstract class with a property that holds the item the cell is displaying,
// which is added to the cell's configuration state for subclasses to use when updating their configuration.
class ItemCell: UICollectionViewListCell {
    private var item: Item? = nil
    
    func updateWithItem(_ newItem: Item) {
        guard item != newItem else { return }
        item = newItem
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = self.item
        return state
    }
}

class IconCell: ItemCell {
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private let iconView = UIImageView()
    private let nameLabel = UILabel()

    private var customViewConstraints: (nameLabelLeading: NSLayoutConstraint,
                                        nameLabelTrailing: NSLayoutConstraint,
                                        iconViewTrailing: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        // We only need to do anything if we haven't already setup the views and created constraints.
        guard customViewConstraints == nil else { return }
        
        /*
        contentView.addSubview(listContentView)
        contentView.addSubview(iconView)
        contentView.addSubview(nameLabel)
        
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        let defaultHorizontalCompressionResistance = listContentView.contentCompressionResistancePriority(for: .horizontal)
        listContentView.setContentCompressionResistancePriority(defaultHorizontalCompressionResistance - 1, for: .horizontal)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = (
            nameLabelLeading: nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: listContentView.trailingAnchor),
            nameLabelTrailing: iconView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            iconViewTrailing: contentView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor)
        )
        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            constraints.nameLabelLeading,
            constraints.nameLabelTrailing,
            constraints.iconViewTrailing
        ])
        customViewConstraints = constraints
 */
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
        
        // Configure the list content configuration and apply that to the list content view.
        var content = defaultListContentConfiguration().updated(for: state)
        content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
        if state.item is Folder {
            content.image = ItemCell.directoryIcon
        } else {
            content.image = ItemCell.fileIcon
        }
        
        content.text = state.item?.name

        content.axesPreservingSuperviewLayoutMargins = []
        listContentView.configuration = content
        
        // Get the list value cell configuration for the current state, which we'll use to obtain the system default
        // styling and metrics to copy to our custom views.
        let valueConfiguration = UIListContentConfiguration.valueCell().updated(for: state)
        
        
        /*
        // Configure custom image view for the category icon, copying some of the styling from the value cell configuration.
        iconView.image = content.image
        iconView.tintColor = valueConfiguration.imageProperties.resolvedTintColor(for: tintColor)
        iconView.preferredSymbolConfiguration = .init(font: valueConfiguration.secondaryTextProperties.font, scale: .small)
        
        // Configure custom label for the category name, copying some of the styling from the value cell configuration.
        nameLabel.text = state.item?.name
        nameLabel.textColor = valueConfiguration.secondaryTextProperties.resolvedColor()
        nameLabel.font = valueConfiguration.secondaryTextProperties.font
        nameLabel.adjustsFontForContentSizeCategory = valueConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory
        
        // Update some of the constraints for our custom views using the system default metrics from the configurations.
        customViewConstraints?.nameLabelLeading.constant = content.directionalLayoutMargins.trailing
        customViewConstraints?.nameLabelTrailing.constant = valueConfiguration.textToSecondaryTextHorizontalPadding
        customViewConstraints?.iconViewTrailing.constant = content.directionalLayoutMargins.trailing
        //updateSeparatorConstraint()
         */
    }
}

extension ItemCell {
    static let fileIcon = UIImage(systemName: "doc.badge.plus")!
    static let directoryIcon = UIImage(systemName: "folder")!
}
