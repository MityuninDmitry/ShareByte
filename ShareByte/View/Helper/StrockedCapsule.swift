//
//  StrockedCapsule.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/18/23.
//

import Foundation
import SwiftUI

struct StrockedCapsule: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                Capsule()
                    .stroke(lineWidth: 1)
            }
            .contentShape(Capsule())
    }
}


struct StrockedFilledCapsule: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background{
                Capsule()
                    .fill(Dict.appIndigo)
                    .opacity(0.8)
                    .overlay {
                        Capsule()
                            .stroke(lineWidth: 1)
                            .fill(.black)
                    }
                    
            }
            .contentShape(Capsule())
    }
}
