//
//  SSDPSessionConfiguration.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

public struct SSDPSessionConfiguration {
    let searchTarget: String
    let host: String
    let port: UInt
    let maximumWaitResponseTime: TimeInterval
    let maximumBroadcastsBeforeClosing: UInt
    
    
    public init(searchTarget: String,
                host: String,
                port: UInt,
                maximumWaitResponseTime: TimeInterval,
                maximumBroadcastsBeforeClosing: UInt) {
        
        assert(maximumWaitResponseTime >= 1 && maximumWaitResponseTime <= 5, "maximumWaitResponseTime should be between 1 and 5 (inclusive)")
        
        self.searchTarget = searchTarget
        self.host = host
        self.port = port
        self.maximumWaitResponseTime = maximumWaitResponseTime
        self.maximumBroadcastsBeforeClosing = maximumBroadcastsBeforeClosing
    }
}

extension SSDPSessionConfiguration {
    
    public static func makeConfig(forSearchTarget searchTarget: String,
                                  maximumWaitResponseTime: TimeInterval = 3,
                                  maximumBroadcastsBeforeClosing: UInt = 3) -> SSDPSessionConfiguration {
        let configuration = SSDPSessionConfiguration(searchTarget: searchTarget,
                                                     host: "239.255.255.250",
                                                     port: 1900,
                                                     maximumWaitResponseTime: maximumWaitResponseTime,
                                                     maximumBroadcastsBeforeClosing:
                                                        maximumBroadcastsBeforeClosing)
        
        return configuration
    }
}
