//
//  PresentationTabManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import Foundation
class PresentationTabManager: ObservableObject {
    static let shared = PresentationTabManager()
    
    @Published var seletedTabId: PresentationState

    private init(selectedTabId: PresentationState = .Selecting) {
        self.seletedTabId = selectedTabId
    }
    
    func nextTab()  {
        switch seletedTabId {
        case .Selecting:
            seletedTabId = .Uploading
        case .Uploading:
            seletedTabId = .Presentation
        case .Presentation:
            seletedTabId = .Selecting
        }
    }
    
    func goTab(state: PresentationState) {
        self.seletedTabId = state
    }
    
}
