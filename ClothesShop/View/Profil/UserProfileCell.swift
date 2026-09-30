//
//  UserProfileCell.swift
//  ClothesShop
//
//  Created by Alex on 26.09.2026.
//

import SwiftUI

struct UserProfileCell: View {
    @EnvironmentObject var viewModel: MainViewModel

    private var avatar: Image? {
        viewModel.user.image.flatMap(Image.init(base64String:))
    }

    var body: some View {
        HStack {
            // Раньше тут был force unwrap: пустая/битая строка base64 роняла приложение.
            if let avatar = avatar {
                avatar
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            }

            VStack {
                HStack {
                    Text(viewModel.user.name)
                        .bold()
                        .font(.system(size: 24))
                        .foregroundColor(Color.appBlack)
                    Spacer()
                }

                HStack {
                    Text(verbatim: "\(viewModel.user.age)")
                        .foregroundColor(Color.appGray)
                        .font(.system(size: 12))
                    Spacer()
                }
            }
        }
    }
}

struct UserProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileCell().environmentObject(MainViewModel())
    }
}
