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
    let maxResponseTime: TimeInterval
    let maxBroadcastsBeforeClosing: UInt
    
    public init(searchTarget: String,
                host: String,
                port: UInt,
                maxResponseTime: TimeInterval,
                maxBroadcastsBeforeClosing: UInt) {
        
        assert(maxResponseTime >= 1 && maxBroadcastsBeforeClosing <= 5, "maxResponseTime should be between 1 and 5 (inclusive)")
        
        self.searchTarget = searchTarget
        self.host = host
        self.port = port
        self.maxResponseTime = maxResponseTime
        self.maxBroadcastsBeforeClosing = maxBroadcastsBeforeClosing
    }
}

extension SSDPSessionConfiguration {
    public static func makeGeneraConfig(forSearchTarget searchTarget: String = "ssdp:all",
                                        maxResponseTime: TimeInterval = 3,
                                        maxBroadcastsBeforeClosing: UInt = 3) -> SSDPSessionConfiguration {
        let configuration = SSDPSessionConfiguration(searchTarget: searchTarget,
                                                     host: "239.255.255.250",
                                                     port: 1900,
                                                     maxResponseTime: maxResponseTime,
                                                     maxBroadcastsBeforeClosing:
                                                        maxBroadcastsBeforeClosing)
        
        return configuration
    }
}
