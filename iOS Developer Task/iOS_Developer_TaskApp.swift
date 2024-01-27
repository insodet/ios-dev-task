//
//  iOS_Developer_TaskApp.swift
//  iOS Developer Task
//
//  Created by Roman Sukhorukov on 22.01.2024.
//

import SwiftUI
import CoreData

@main
struct iOS_Developer_TaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
