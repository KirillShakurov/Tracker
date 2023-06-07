//
//  AnalyticService.swift
//  Tracker
//
//  Created by Kirill on 28.05.2023.
//

import YandexMobileMetrica

enum Event: String {
    case open
    case close
    case click
}

enum Screen: String {
    case main = "Main"
}

final class AnalyticService {

    static let shared = AnalyticService()

    private init() {}

    func sendEvent(event: Event, screen: Screen = .main, parameters: [String: String] = [:]) {
        var param = ["screen": screen.rawValue]
        parameters.forEach({
            param[$0.key] = $0.value
        })
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: param)
        print(event.rawValue, param)
    }
}
