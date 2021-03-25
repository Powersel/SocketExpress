//
//  SSDPSessionDelegate.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

public protocol SSDPSessionDelegate: class {
    func ssdpSession(_ ssdpSession: SSDPSession,
                     didFindService service: SSDPNode)
    func ssdpSession(_ ssdpession: SSDPSession,
                     didEncounterError error: SSDPSessionError)
    func ssdpSessionDidStopSearch(_ ssdpSession: SSDPSession,
                                  foundServices: [SSDPNode])
}
