//
//  Persistence.swift
//  Diets
//
//  Created by Roman Sukhorukov on 10.05.2023.
//

import CoreData

public struct PersistenceController {
    
    public static let sampleBaseName = "Sample"
    public static let baseFilesExtensions = ["sqlite"]
    
    public static var shared: PersistenceController = PersistenceController()

    public let container: NSPersistentContainer
    
    private var baseURL: URL? {
        container.persistentStoreDescriptions.first?.url ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .allDomainsMask).first?.appendingPathComponent("\(PersistenceController.baseName).sqlite")
    }
    
    fileprivate static let baseName = "iOS_Developer_Task"
    
    private func copyBaseFiles() {
        PersistenceController
            .baseFilesExtensions
            .map{ Bundle.main.url(forResource: PersistenceController.sampleBaseName, withExtension: $0) }
            .compactMap{ $0 }
            .forEach { url in
                guard let toURL = baseURL?.deletingPathExtension().appendingPathExtension(url.pathExtension) else {
                    return
                }
                try? FileManager.default.copyItem(at: url, to: toURL)
            }
    }
    
    private func changeStore(forMode mode: Mode) {
        switch mode {
        case .baseFromResources:
            guard let baseURL else {
                fatalError("Can't retrieve base url")
            }
            if !FileManager.default.fileExists(atPath: baseURL.path) {
                copyBaseFiles()
            }
        case .inMemory:
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
    public init(mode: Mode = .baseFromResources) {
        guard let modelURL = Bundle.main.url(forResource: PersistenceController.baseName, withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Can't create Coredata model")
        }
        container = .init(name: PersistenceController.baseName, managedObjectModel: objectModel)
        changeStore(forMode: mode)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public enum Mode {
        case baseFromResources
        case inMemory
    }
}

public class CustomPathContainer: NSPersistentContainer {
    public override class func defaultDirectoryURL() -> URL {
        if let changedDefaultDirectory {
            return changedDefaultDirectory
        } else {
            return super.defaultDirectoryURL()
        }
    }
    
    private static var changedDefaultDirectory: URL? = nil
    
    static func changeDefaultDirectory(to url: URL) {
        changedDefaultDirectory = url
    }
    
}

private extension URL {
    var isBaseURL: Bool {
        self.pathExtension.lowercased() == "sqlite"
    }
    
    var baseDirectory: URL {
        isBaseURL ? self.deletingLastPathComponent() : self
    }
    
    var baseURL: URL {
        isBaseURL ? self : self.appendingPathComponent("\(PersistenceController.baseName).sqlite")
    }
}
