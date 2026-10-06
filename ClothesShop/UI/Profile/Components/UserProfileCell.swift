import SwiftUI

struct UserProfileCell: View {
    @EnvironmentObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(SwiftGen.Common.email)
                .font(.caption)
                .foregroundColor(.appGray)
            Text(verbatim: viewModel.user.email)
                .font(.body)
                .foregroundColor(.appBlack)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct UserProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AppDIContainer.shared.makeProfileViewModel()
        viewModel.applyPreview(profile: UserProfile(email: "alex@example.com"))
        return UserProfileCell().environmentObject(viewModel)
            .previewThemes()
    }
}
#endif
