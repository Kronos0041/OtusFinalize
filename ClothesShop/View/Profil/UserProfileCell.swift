import SwiftUI

struct UserProfileCell: View {
    @EnvironmentObject var viewModel: MainViewModel

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
        UserProfileCell().environmentObject(MainViewModel(previewProfile: ProfileViewState(email: "alex@example.com")))
            .previewThemes()
    }
}
#endif
