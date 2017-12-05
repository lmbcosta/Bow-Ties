//
//  Bowtie+CoreDataProperties.swift
//  Bow Ties
//
//  Created by Luis  Costa on 05/12/17.
//  Copyright © 2017 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> {
        return NSFetchRequest<Bowtie>(entityName: "Bowtie")
    }

    @NSManaged public var name: String?
    @NSManaged public var isFavourite: Bool
    @NSManaged public var lastWorn: NSDate?
    @NSManaged public var rating: Double
    @NSManaged public var id: UUID?
    @NSManaged public var url: URL?
    @NSManaged public var photoData: NSData?
    @NSManaged public var tintColor: NSObject?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var searchKey: String?

}
