//
//  TabManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
class TabManager: ObservableObject {
    static let shared = TabManager()
    
    var seletedTabId: Int

    private init(selectedTabId: Int = 0) {
        self.seletedTabId = selectedTabId
    }
}
