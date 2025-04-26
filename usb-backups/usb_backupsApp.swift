//
//  usb_backupsApp.swift
//  usb-backups
//
//  Created by Alexander Starnikov on 26.04.2025.
//

import SwiftUI

@main
struct usb_backupsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
