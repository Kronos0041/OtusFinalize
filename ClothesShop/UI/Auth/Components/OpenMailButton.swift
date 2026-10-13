import SwiftUI

/// Ссылка «Открыть Gmail / Почту»: для адресов Gmail — приложение Gmail (или сайт, если его нет),
/// для остальных — приложение «Почта».
struct OpenMailButton: View {
    let email: String
    @Environment(\.openURL) private var openURL

    private var isGmail: Bool {
        let domain = email.split(separator: "@").last?.lowercased() ?? ""
        return domain == "gmail.com" || domain == "googlemail.com"
    }

    var body: some View {
        Button {
            if isGmail, let app = URL(string: "googlegmail://"), let web = URL(string: "https://mail.google.com") {
                openURL(app) { accepted in
                    if !accepted { openURL(web) }
                }
            } else if let mail = URL(string: "message://") {
                openURL(mail)
            }
        } label: {
            Text(isGmail ? SwiftGen.Auth.Verification.openGmail : SwiftGen.Auth.Verification.openMail)
                .font(.system(size: 16, weight: .medium))
                .underline()
                .foregroundStyle(Color.appBlack)
        }
        .buttonStyle(.plain)
    }
}
