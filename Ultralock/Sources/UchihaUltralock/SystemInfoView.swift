import SwiftUI

struct SystemInfoView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer().frame(height: 10)

                // MARK: - Device Info
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Device", icon: "iphone")

                        infoRow(label: "Model",     value: DeviceUtils.deviceModel)
                        infoRow(label: "iOS",       value: DeviceUtils.osVersion)
                        infoRow(label: "Chip",      value: DeviceUtils.chipName)
                        infoRow(label: "CPU Cores", value: "\(DeviceUtils.cpuCores)")
                        infoRow(label: "RAM",       value: DeviceUtils.totalRAM)
                    }
                }

                // MARK: - Display
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Display", icon: "tv")

                        infoRow(label: "Resolution",  value: DeviceUtils.screenResolution)
                        infoRow(label: "Refresh Rate", value: "\(DeviceUtils.refreshRate) Hz")
                    }
                }

                // MARK: - Battery
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Battery", icon: "battery.100")

                        infoRow(label: "Level", value: "\(DeviceUtils.batteryPercent)%")

                        HStack {
                            Image(systemName: "speedometer")
                                .font(.system(size: 12))
                                .foregroundColor(CyberTheme.cyberGlow)
                                .frame(width: 20)
                            Text("FPS")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(CyberTheme.textSecondary)
                            Spacer()
                            Text("\(viewModel.fps)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(viewModel.fps >= 55
                                    ? CyberTheme.success
                                    : viewModel.fps >= 30
                                    ? CyberTheme.warning
                                    : CyberTheme.danger)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Storage Info (approximate)
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Storage", icon: "externaldrive")

                        if let (free, total) = storageValues() {
                            let used = total - free
                            let pct = total > 0 ? Double(used) / Double(total) : 0
                            infoRow(label: "Total", value: formatBytes(total))
                            infoRow(label: "Used",  value: formatBytes(used))
                            infoRow(label: "Free",  value: formatBytes(free))

                            ProgressView(value: pct)
                                .tint(pct > 0.85 ? CyberTheme.danger : CyberTheme.cyberGlow)
                        } else {
                            infoRow(label: "Storage", value: "N/A")
                        }
                    }
                }

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Helpers
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)
        }
        .padding(.vertical, 3)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        return String(format: "%.1f GB", gb)
    }

    private func storageValues() -> (free: Int64, total: Int64)? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let url = paths.first else { return nil }
        do {
            if #available(iOS 16.0, *) {
                let keys: Set<URLResourceKey> = [
                    .volumeAvailableCapacityForImportantUsageKey,
                    .volumeTotalCapacityKey
                ]
                let values = try url.resourceValues(forKeys: keys)
                if let free = values.volumeAvailableCapacityForImportantUsage,
                   let total = values.volumeTotalCapacity {
                    return (Int64(free), Int64(total))
                }
            } else {
                let keys: Set<URLResourceKey> = [
                    .volumeAvailableCapacityKey,
                    .volumeTotalCapacityKey
                ]
                let values = try url.resourceValues(forKeys: keys)
                if let free = values.volumeAvailableCapacity,
                   let total = values.volumeTotalCapacity {
                    return (Int64(free), Int64(total))
                }
            }
            return nil
        } catch {
            return nil
        }
    }
}
