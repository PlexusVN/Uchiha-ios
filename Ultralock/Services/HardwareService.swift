import UIKit

struct HardwareService {
    static func collect() -> HardwareInfo {
        let device = UIDevice.current
        let screen = UIScreen.main
        let scale = screen.scale
        let bounds = screen.nativeBounds
        let storage = getStorageInfo()
        device.isBatteryMonitoringEnabled = true
        let battery = Int(device.batteryLevel * 100)

        return HardwareInfo(
            chipset: machineName(),
            cpuCores: ProcessInfo.processInfo.processorCount,
            cpuFreq: "",
            gpu: "Apple GPU",
            ramTotal: formatMemory(ProcessInfo.processInfo.physicalMemory),
            ramAvailable: formatMemory(getAvailableMemory()),
            storageTotal: storage.total,
            storageAvail: storage.avail,
            screenRes: "\(Int(bounds.width))x\(Int(bounds.height))",
            screenSize: String(format: "%.1f\"", screen.bounds.size.width / scale),
            refreshRate: Int(max(screen.maximumFramesPerSecond, 60)),
            density: "\(Int(scale))x",
            iosVer: device.systemVersion,
            device: machineName(),
            manufacturer: "Apple",
            model: device.model,
            batteryPct: battery,
            batteryTemp: 0
        )
    }

    private static func formatMemory(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        return String(format: "%.1f GB", gb)
    }

    private static func getAvailableMemory() -> UInt64 {
        var pages = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / 4)
        let result = withUnsafeMutablePointer(to: &pages) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return UInt64(pages.free_count + pages.inactive_count) * UInt64(vm_page_size)
    }

    private static func getStorageInfo() -> (total: String, avail: String) {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            let total = (attrs[.systemSize] as? NSNumber)?.uint64Value ?? 0
            let free = (attrs[.systemFreeSize] as? NSNumber)?.uint64Value ?? 0
            return (formatMemory(total), formatMemory(free))
        } catch {
            return ("Unknown", "Unknown")
        }
    }

    private static func machineName() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
}
