import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var showKey: Bool = false

    var body: some View {
        ZStack {
            CyberGridBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // Shield icon
                    ZStack {
                        Circle()
                            .fill(CyberTheme.cyberGlow.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40))
                            .foregroundColor(CyberTheme.cyberGlow)
                    }

                    Text("Uchiha Ultralock")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(CyberTheme.textPrimary)

                    Text("Game Optimization Suite")
                        .font(.system(size: 14))
                        .foregroundColor(CyberTheme.textSecondary)

                    // Key input
                    CyberCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("License Key")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(CyberTheme.textSecondary)

                            HStack {
                                if showKey {
                                    TextField("", text: $viewModel.licenseKey)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(CyberTheme.textPrimary)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Enter your license key", text: $viewModel.licenseKey)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(CyberTheme.textPrimary)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }

                                Button(action: { showKey.toggle() }) {
                                    Image(systemName: showKey ? "eye.slash" : "eye")
                                        .font(.system(size: 12))
                                        .foregroundColor(CyberTheme.textSecondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(CyberTheme.bgStart.opacity(0.5))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(CyberTheme.cyberCardBorder, lineWidth: 1))

                            // HWID
                            CopyableRow(
                                label: "HWID",
                                value: viewModel.hwid,
                                copyAction: { val in
                                    UIPasteboard.general.string = val
                                    viewModel.showToast("HWID copied")
                                }
                            )
                        }
                    }

                    // Error
                    if case .error(let msg) = viewModel.authState {
                        Text(msg)
                            .font(.system(size: 12))
                            .foregroundColor(CyberTheme.danger)
                            .multilineTextAlignment(.center)
                    }

                    // Login button
                    Button(action: {
                        Haptics.medium()
                        Task { await viewModel.login() }
                    }) {
                        ZStack {
                            if case .loading(let text) = viewModel.authState {
                                HStack(spacing: 10) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                    Text(text)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                            } else {
                                Text("ACTIVATE")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [CyberTheme.cyberGlow, CyberTheme.tierVip],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(CyberTheme.cyberGlow.opacity(0.5), lineWidth: 1))
                    }
                    .disabled(viewModel.licenseKey.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(viewModel.licenseKey.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    .padding(.top, 4)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
