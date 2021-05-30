//
//  AppState.swift
//  FileExpert
//
//  Created by new on 5/29/21.
//

import Foundation

enum DirectoryViewStyle {
    case icons
    case list
}

class AppState {
    
    static let shared = AppState(style: .icons)
    
    private var styleInternal: DirectoryViewStyle
    
    var style: DirectoryViewStyle {
        get { return styleInternal }
    }
    
    func toggleNextStyle() {
        self.styleInternal = getNextStyle()
    }
    
    func getNextStyle() -> DirectoryViewStyle {
        switch (style) {
        case DirectoryViewStyle.icons:
            return DirectoryViewStyle.list
        case DirectoryViewStyle.list:
            return  DirectoryViewStyle.icons
        }
    }
    
    init(style: DirectoryViewStyle) {
        self.styleInternal = style
    }
    
}
