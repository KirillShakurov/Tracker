//
//  NSObject+Extensions.swift
//  Tracker
//
//  Created by Kirill on 03.06.2023.
//

import Foundation

extension NSObject {
    func copyObject<T:NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
