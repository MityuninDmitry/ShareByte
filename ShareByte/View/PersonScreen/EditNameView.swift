//
//  EditNameView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/18/23.
//

import SwiftUI

struct EditNameView: View {
    enum FocusedField {
        case userName
    }
    
    @State var userName: String = ""
    @EnvironmentObject var userVM: UserViewModel
    @State var nameInEditMode = false
    @FocusState private var focusedField: FocusedField?
    
    
    var body: some View {
        HStack(spacing: 0) {
            if nameInEditMode {
                TextField("Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .fontWeight(.semibold)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                    .focused($focusedField, equals: .userName)
                    .submitLabel(.done)
                    .onSubmit({
                        nameInEditMode.toggle()
                        userVM.user.name = userName
                        userVM.saveUser()
                    })
                    .onAppear {
                        focusedField = .userName
                    }
                    .onDisappear {
                        focusedField = nil
                    }
                
            } else {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        Button {
                            nameInEditMode.toggle()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal, 15)
            }
        }
        .onAppear(perform: {
            userName = userVM.user.name ?? ""
        })
        .onChange(of: userVM.user.name ?? "") { newValue in
            userName = newValue
        }
        
    }
}
