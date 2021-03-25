//
//  SSDPSession.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import os

public enum SSDPSessionError: Error {
    case searchAborted(Error)
}

protocol SSDPSearchSessionProtocol {
    var delegate: SSDPSessionDelegate? { get set }
    
    func start()
    func stop()
}

public class SSDPSession: SSDPSearchSessionProtocol {
    
    weak var delegate: SSDPSessionDelegate?
    weak var delegateQueue: OperationQueue?
    
    private let socketController: UDPSocketControllerProtocol
    private let configuration: SSDPSessionConfiguration
    private let parser: SSDPNodeParserProtocol
    
    private var servicesFoundDuringSearch = [SSDPNode]()
    
    private let searchTimeout: TimeInterval
    
    private var broadcastTimer: Timer?
    private var timeoutTimer: Timer?
    
    private lazy var mSearchMessage = {
        // Each line must end in `\r\n`
        return "M-SEARCH * HTTP/1.1\r\n" +
            "HOST: \(configuration.host):\(configuration.port)\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "ST: \(configuration.searchTarget)\r\n" +
            "MX: \(Int(configuration.maximumWaitResponseTime))\r\n" +
            "\r\n"
    }()
    
    //    public init(configuration: SSDPSessionConfiguration) {
    //
    //    }
    //
    //    public init(configuration: SSDPSessionConfiguration,
    //                delegate: SSDPSessionDelegate?  = nil,
    //                delegateQueue: OperationQueue? = nil) {
    //
    //    }
    
    // MARK: - Init
    
    init?(configuration: SSDPSessionConfiguration,
          socketControllerFactory: SocketControllerFactoryProtocol = SocketControllerFactory(),
          parser: SSDPNodeParserProtocol = SSDPNodeParser()) {
        
        guard let socketController = socketControllerFactory.createUDPSocketController(host: configuration.host, port: configuration.port, socketFactory: SocketFactory(), callbackQueue: .main) else {
            return nil
        }
        
        self.socketController = socketController
        self.configuration = configuration
        self.parser = parser
        self.searchTimeout = (TimeInterval(configuration.maximumBroadcastsBeforeClosing) * configuration.maximumWaitResponseTime) + 0.1
        
        self.socketController.delegate = self
    }
    
    // MARK: - Public funcs
    
    public func start() {
        guard configuration.maximumBroadcastsBeforeClosing > 0 else {
            delegate?.ssdpSessionDidStopSearch(self,
                                               foundServices: servicesFoundDuringSearch)
            return
        }
        
        //        os_log(.info, "SSDP search session starting")
        sendMSearchMessages()
        
        if #available(OSX 10.12, *) {
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: searchTimeout,
                                                repeats: false,
                                                block: { [weak self] (timer) in
                                                    self?.searchTimedOut()
                                                })
        } else {
            
        }
    }
    
    public func stop() {
        //        os_log(.info, "SSDP search session stopping")
        close()
        delegate?.ssdpSessionDidStopSearch(self,
                                           foundServices: servicesFoundDuringSearch)
    }
    
    func searchTimedOut() {
        //        os_log(.info, "SSDP search timed out")
        stop()
    }
    
    // MARK: - Close
    
    func close() {
        broadcastTimer?.invalidate()
        broadcastTimer = nil
        
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        
        if socketController.state.isActive {
            socketController.close()
        }
    }
    
    // MARK: Write
    
    func sendMSearchMessages() {
        let message = mSearchMessage
        
        if configuration.maximumBroadcastsBeforeClosing > 1 {
            let window = searchTimeout - configuration.maximumWaitResponseTime
            let interval = window / TimeInterval((configuration.maximumBroadcastsBeforeClosing - 1))
            
            if #available(OSX 10.12, *) {
                broadcastTimer = Timer.scheduledTimer(withTimeInterval: interval,
                                                      repeats: true,
                                                      block: { [weak self] (timer) in
                                                        self?.socketController.write(message: message)
                                                      })
            } else {
                
            }
        }
        writeMessageToSocket(message)
    }
    
    func writeMessageToSocket(_ message: String) {
        //        os_log(.info, "Writing to socket: \r%{public}@", message)
        socketController.write(message: message)
    }
}

extension SSDPSession: UDPSocketControllerDelegate {
    
    func controller(_ controller: UDPSocketControllerProtocol,
                    didReceiveResponse response: Data) {
        guard !response.isEmpty,
              let service = parser.parse(response),
              searchedForService(service),
              !servicesFoundDuringSearch.contains(service) else {
            return
        }
        
        //            os_log(.info, "Received a valid service response")
        
        servicesFoundDuringSearch.append(service)
        delegate?.ssdpSession(self, didFindService: service)
    }
    
    func controller(_ controller: UDPSocketControllerProtocol,
                    didEncounterError error: Error) {
        let wrappedError = SSDPSessionError.searchAborted(error)
        delegate?.ssdpSession(self, didEncounterError: wrappedError)
        close()
    }
    
    func searchedForService(_ service: SSDPNode) -> Bool {
        return service.searchTarget.contains(configuration.searchTarget) ||
            configuration.searchTarget == "ssdp:all"
    }
}
