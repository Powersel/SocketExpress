//
//  DateFactory.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

protocol DateFactoryProtocol {
    func currentDate() -> Date
}

final class DateFactory: DateFactoryProtocol {
    func currentDate() -> Date {
        return Date()
    }
}
