//
//  ProfileView.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        List {
            Section("Профиль") {
                UserProfileCell()
                    .environmentObject(viewModel)
            }

            Section("Изменить имя") {
                TextField("Имя", text: $viewModel.user.name)
            }

            Section {
                Button("Выйти из аккаунта", role: .destructive, action: viewModel.signOut)

                if let error = viewModel.signOutError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(Color.appRed)
                }
            }
        }
        .onAppear(perform: viewModel.loadProfile)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
