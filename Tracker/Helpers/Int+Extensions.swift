//
//  Int+Extensions.swift
//  Tracker
//
//  Created by Kirill on 30.03.2023.
//

import Foundation

extension Int {
    func days() -> String {
        var ending: String!
        if "1".contains("\(self % 10)")      { ending = "Day".localized() }
        if "234".contains("\(self % 10)")    { ending = "OfDay".localized()  }
        if "567890".contains("\(self % 10)") { ending = "Days".localized() }
        if 11...14 ~= self % 100             { ending = "Days".localized() }
        return "\(self) " + ending
    }
}
