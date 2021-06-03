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
    
    static let changeNotification = Notification.Name("AppStateChanged")
    
    static let shared = AppState(style: .icons)
    
    private var styleInternal: DirectoryViewStyle
    
    var style: DirectoryViewStyle {
        get { return styleInternal }
    }
    
    func toggleNextStyle() {
        let prevStyle = self.style
        self.styleInternal = getNextStyle()
        NotificationCenter.default.post(name: Store.changeNotification, object: self, userInfo: [
                                            AppState.previousStyle: prevStyle,
                                            AppState.style: self.style])
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

extension AppState {
    static let previousStyle = "previousStyle"
    static let style = "style"
}

