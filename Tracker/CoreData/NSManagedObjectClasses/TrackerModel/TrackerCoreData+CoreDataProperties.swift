//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 09/02/2025.
//
//

import Foundation
import CoreData
import UIKit

extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var record: NSSet?

}

// MARK: Generated accessors for record
extension TrackerCoreData {

    @objc(addRecordObject:)
    @NSManaged public func addToRecord(_ value: TrackerRecordCoreData)

    @objc(removeRecordObject:)
    @NSManaged public func removeFromRecord(_ value: TrackerRecordCoreData)

    @objc(addRecord:)
    @NSManaged public func addToRecord(_ values: NSSet)

    @objc(removeRecord:)
    @NSManaged public func removeFromRecord(_ values: NSSet)

}

extension TrackerCoreData : Identifiable {

}
