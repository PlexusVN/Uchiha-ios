import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        ZStack {
            switch viewModel.authState {
            case .verified:
                MainContainer(viewModel: viewModel)

            default:
                LoginView(viewModel: viewModel)
                    .transition(.opacity)
            }

            // Toast overlay
            if let msg = viewModel.toastMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(viewModel.toastIsError ? Color(hex: 0xCC0000) : CyberTheme.cyberGlow)
                        .clipShape(Capsule())
                        .shadow(color: CyberTheme.cyberGlow.opacity(0.4), radius: 10)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.3), value: viewModel.toastMessage)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.authState)
        .onAppear {
            Task { await viewModel.restoreSessionIfNeeded() }
        }
    }
}
