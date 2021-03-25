//
//  SSDPNode.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

public struct SSDPNode {
    public let cacheControl: Date
    public let location: URL
    public let server: String
    public let searchTarget: String
    public let uniqueServiceName: String
    public let otherHeaders: [String: String]
    
    public init(cacheControl: Date,
                location: URL,
                server: String,
                searchTarget: String,
                uniqueServiceName: String,
                otherHeaders: [String: String]) {
        self.cacheControl = cacheControl
        self.location = location
        self.server = server
        self.searchTarget = searchTarget
        self.uniqueServiceName = uniqueServiceName
        self.otherHeaders = otherHeaders
    }
}

extension SSDPNode: Equatable {
    public static func == (lhs: SSDPNode, rhs: SSDPNode) -> Bool {
        return lhs.location == rhs.location &&
            lhs.server == rhs.server &&
            lhs.searchTarget == rhs.searchTarget &&
            lhs.uniqueServiceName == rhs.uniqueServiceName
    }
}
