//
//  String+Extensions.swift
//  Tracker
//
//  Created by Kirill on 03.06.2023.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
