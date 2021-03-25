//
//  SSDPNodeParserProtocol.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

protocol SSDPNodeParserProtocol {
    func parse(_ data: Data) -> SSDPNode?
}
