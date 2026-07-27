import SwiftUI

struct SystemInfoView: View {
    let hardwareInfo: HardwareInfo
    @ObservedObject var fpsMonitor: FpsMonitor

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // FPS & Performance
                HStack(spacing: 16) {
                    statCircle(value: "\(Int(fpsMonitor.state.currentFps))", label: "FPS", color: fpsColor)
                    statCircle(value: "\(Int(fpsMonitor.state.maxRefreshRate))", label: "Hz", color: .uchihaAccent)
                    statCircle(value: String(format: "%.1f", fpsMonitor.state.frameTimeMs), label: "ms", color: .cyberTextSecondary)
                }
                .padding(.top, 8)

                // Device Info
                infoSection("THIẾT BỊ") {
                    infoRow("Dòng máy", hardwareInfo.device)
                    infoRow("Model", hardwareInfo.model)
                    infoRow("iOS", hardwareInfo.iosVer)
                    infoRow("Chip", hardwareInfo.chipset)
                    infoRow("GPU", hardwareInfo.gpu)
                    infoRow("Nhân CPU", "\(hardwareInfo.cpuCores)")
                }

                // RAM
                infoSection("RAM") {
                    ramBar(total: hardwareInfo.ramTotal, available: hardwareInfo.ramAvailable)
                    infoRow("Tổng", hardwareInfo.ramTotal)
                    infoRow("Khả dụng", hardwareInfo.ramAvailable)
                }

                // Storage
                infoSection("BỘ NHỚ") {
                    storageBar(total: hardwareInfo.storageTotal, available: hardwareInfo.storageAvail)
                    infoRow("Tổng", hardwareInfo.storageTotal)
                    infoRow("Trống", hardwareInfo.storageAvail)
                }

                // Display
                infoSection("MÀN HÌNH") {
                    infoRow("Độ phân giải", hardwareInfo.screenRes)
                    infoRow("Mật độ", hardwareInfo.density)
                    infoRow("Tần số quét", "\(hardwareInfo.refreshRate)Hz")
                }

                // Battery
                infoSection("PIN") {
                    infoRow("Mức pin", "\(hardwareInfo.batteryPct)%")
                    if hardwareInfo.batteryTemp > 0 {
                        infoRow("Nhiệt độ", String(format: "%.1f°C", hardwareInfo.batteryTemp))
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private var fpsColor: Color {
        if fpsMonitor.state.currentFps >= 60 { return .green }
        if fpsMonitor.state.currentFps >= 45 { return .orange }
        return .red
    }

    private func statCircle(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                    .frame(width: 56, height: 56)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.uchihaCaption(size: 8))
                .foregroundColor(.gray)
        }
    }

    private func infoSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.uchihaHeading(size: 10))
                .foregroundColor(.uchihaAccent)
                .padding(.bottom, 2)
            content()
        }
        .padding(10)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.15), lineWidth: 1))
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.uchihaBody(size: 10))
                .foregroundColor(.white)
        }
    }

    private func ramBar(total: String, available: String) -> some View {
        let totalGB = Double(total.replacingOccurrences(of: " GB", with: "")) ?? 4
        let availGB = Double(available.replacingOccurrences(of: " GB", with: "")) ?? 2
        let used = totalGB - availGB
        let pct = totalGB > 0 ? used / totalGB : 0
        return VStack(spacing: 4) {
            ProgressView(value: pct)
                .tint(pct > 0.8 ? .neonRed : .uchihaAccent)
            HStack {
                Text("Đã dùng: \(String(format: "%.1f", used)) GB")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
                Spacer()
                Text("Trống: \(available)")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
            }
        }
    }

    private func storageBar(total: String, available: String) -> some View {
        let totalGB = Double(total.replacingOccurrences(of: " GB", with: "")) ?? 64
        let availGB = Double(available.replacingOccurrences(of: " GB", with: "")) ?? 32
        let used = totalGB - availGB
        let pct = totalGB > 0 ? used / totalGB : 0
        return VStack(spacing: 4) {
            ProgressView(value: pct)
                .tint(pct > 0.8 ? .neonRed : .uchihaAccent)
            HStack {
                Text("Đã dùng: \(String(format: "%.1f", used)) GB")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
                Spacer()
                Text("Trống: \(available)")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
            }
        }
    }
}
