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

final public class SSDPSession {
    
    public weak var delegate: SSDPSessionDelegate?
    public weak var delegateQueue: OperationQueue?
    
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
            "MX: \(Int(configuration.maxResponseTime))\r\n" +
            "\r\n"
    }()
    
    // MARK: - Init
    
    public convenience init?(configuration: SSDPSessionConfiguration,
                             delegate: SSDPSessionDelegate?  = nil,
                             delegateQueue: OperationQueue? = nil) {
        self.init(socketControllerFactory: SocketControllerFactory(),
                  configuration: configuration)
        
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
    
    init?(socketControllerFactory: SocketControllerFactoryProtocol = SocketControllerFactory(),
          parser: SSDPNodeParserProtocol = SSDPNodeParser(),
          configuration: SSDPSessionConfiguration) {
        
        guard let socketController = socketControllerFactory.createUDPSocketController(host: configuration.host, port: configuration.port, socketFactory: SocketFactory(), callbackQueue: .main) else {
            return nil
        }
        
        self.configuration = configuration
        self.socketController = socketController
        self.parser = parser
        self.searchTimeout = (TimeInterval(configuration.maxBroadcastsBeforeClosing) * configuration.maxResponseTime) + 0.1
        
        self.socketController.delegate = self
    }
    
    // MARK: - Public funcs
    
    public func start() {
        guard configuration.maxBroadcastsBeforeClosing > 0 else {
            delegate?.ssdpSessionDidStopSearch(self,
                                               foundServices: servicesFoundDuringSearch)
            return
        }
        
        sendMSearchMessages()
        
        if #available(OSX 10.12, *) {
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: searchTimeout,
                                                repeats: false,
                                                block: { [weak self] (timer) in
                                                    self?.stop()
                                                })
        } else {
            timeoutTimer = nil
        }
    }
    
    public func stop() {
        close()
        delegate?.ssdpSessionDidStopSearch(self, foundServices: servicesFoundDuringSearch)
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
        
        if configuration.maxBroadcastsBeforeClosing > 1 {
            let window = searchTimeout - configuration.maxResponseTime
            let interval = window / TimeInterval((configuration.maxBroadcastsBeforeClosing - 1))
            
            if #available(OSX 10.12, *) {
                broadcastTimer = Timer.scheduledTimer(withTimeInterval: interval,
                                                      repeats: true,
                                                      block: { [weak self] (timer) in
                                                        self?.socketController.write(message: message)
                                                      })
            } else {
                broadcastTimer = nil
            }
        }
        writeMessageToSocket(message)
    }
    
    func writeMessageToSocket(_ message: String) {
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
