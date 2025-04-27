import Foundation
import DiskArbitration

class USBWatcher: ObservableObject {
    private var session: DASession?

    @Published var mountedVolumes: [String] = []

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        session = DASessionCreate(kCFAllocatorDefault)

        guard let session = session else {
            print("Failed to create Disk Arbitration session")
            return
        }

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        DARegisterDiskAppearedCallback(session, nil, { (disk, context) in
            if let context = context {
                let watcher = Unmanaged<USBWatcher>.fromOpaque(context).takeUnretainedValue()
                watcher.diskAppeared(disk: disk)
            }
        }, context)

        DARegisterDiskDisappearedCallback(session, nil, { (disk, context) in
            if let context = context {
                let watcher = Unmanaged<USBWatcher>.fromOpaque(context).takeUnretainedValue()
                watcher.diskDisappeared(disk: disk)
            }
        }, context)

        DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }

    private func stopMonitoring() {
        if let session = session {
            DASessionUnscheduleFromRunLoop(session, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }
    }

    private func diskAppeared(disk: DADisk) {
        guard let desc = DADiskCopyDescription(disk) as NSDictionary?,
              let volumePath = desc[kDADiskDescriptionVolumePathKey] as? URL else {
            return
        }

        DispatchQueue.main.async {
            let path = volumePath.path
            if !self.mountedVolumes.contains(path) {
                self.mountedVolumes.append(path)
                print("Disk appeared at \(path)")
            }
        }
    }

    private func diskDisappeared(disk: DADisk) {
        guard let desc = DADiskCopyDescription(disk) as NSDictionary?,
              let volumePath = desc[kDADiskDescriptionVolumePathKey] as? URL else {
            return
        }

        DispatchQueue.main.async {
            let path = volumePath.path
            self.mountedVolumes.removeAll { $0 == path }
            print("Disk disappeared from \(path)")
        }
    }
}
