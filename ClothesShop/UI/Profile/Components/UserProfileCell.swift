import SwiftUI

struct UserProfileCell: View {
    @Environment(ProfileViewModel.self) private var viewModel

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
        UserProfileCell()
            .environment(AppDIContainer.preview().makeLoadedProfileViewModel())
            .previewThemes()
    }
}
#endif
