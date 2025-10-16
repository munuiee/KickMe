//
//  RentalDatas+CoreDataProperties.swift
//  KickMe
//
//  Created by 박혜연 on 10/16/25.
//
//

import Foundation
import CoreData


extension RentalDatas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RentalDatas> {
        return NSFetchRequest<RentalDatas>(entityName: "RentalDatas")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var boardNum: String?
    @NSManaged public var startTime: String?
    @NSManaged public var rentalTime: String?
    @NSManaged public var isReturned: Bool

}

extension RentalDatas : Identifiable {

}
