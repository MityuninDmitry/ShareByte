//
//  SnapCarouselHelperView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/4/23.
//

import SwiftUI

struct SnapCarouselHelperView: UIViewRepresentable {
    var pageWidth: CGFloat
    var pageCount: Int
    @Binding var index: Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) ->  UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView {
                scrollView.decelerationRate = .fast
                scrollView.delegate = context.coordinator
                context.coordinator.pageCount = pageCount
                context.coordinator.pageWidth = pageWidth
                
                
                scrollView.setContentOffset(CGPoint(x: index * Int(pageWidth), y: 0), animated: true)
            }
        }
        
        
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: SnapCarouselHelperView
        var pageCount: Int = 0
        var pageWidth: CGFloat = 0
        init(parent: SnapCarouselHelperView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // print(scrollView.contentOffset.x)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let targetEnd = scrollView.contentOffset.x + (velocity.x * 60)
            let targetIndex = (targetEnd / pageWidth).rounded()
            
            let index = min(max(Int(targetIndex), 0),pageCount - 1)
            parent.index = index
            
            targetContentOffset.pointee.x = targetIndex * pageWidth
        }
        
        
        
    }
}

#Preview {
    ImageItemsView()
        .preferredColorScheme(.dark)
}
