//
//  UDPSocketError.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

enum UDPSocketError: Error {
    case addressCreationFailure
    case writeError(underlayingError: Error)
    case readError(underlayingError: Error)
}
