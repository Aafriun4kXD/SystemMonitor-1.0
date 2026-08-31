import Foundation
import UIKit

class MonitoringService: ObservableObject {
    @Published var stats = SystemStats()
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    private func updateStats() {
        stats.cpuUsage = getCPUUsage()
        let ram = getRAMInfo()
        stats.ramUsed = ram.used
        stats.ramTotal = ram.total
        let battery = getBatteryInfo()
        stats.batteryLevel = battery.level
        stats.batteryState = battery.state
    }
    
    func getCPUUsage() -> Double {
        var totalUsage: Double = 0
        var threadsList: thread_act_array_t?
        var threadsCount = mach_msg_type_number_t(0)
        
        guard task_threads(mach_task_self_, &threadsList, &threadsCount) == KERN_SUCCESS else { return 0 }
        guard let threads = threadsList else { return 0 }
        
        for index in 0..<Int(threadsCount) {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let result = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threads[index], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            
            if result == KERN_SUCCESS && threadInfo.flags & TH_FLAGS_IDLE == 0 {
                totalUsage += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threads)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return totalUsage
    }
    
    func getRAMInfo() -> (used: Double, total: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return (0, 0) }
        let usedMB = Double(info.resident_size) / 1024 / 1024
        let totalMB = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
        return (usedMB, totalMB)
    }
    
    func getBatteryInfo() -> (level: Int, state: String) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        let state: String
        switch UIDevice.current.batteryState {
        case .charging: state = "Charging"
        case .full: state = "Full"
        case .unplugged: state = "Battery"
        default: state = "Unknown"
        }
        return (level, state)
    }
}
