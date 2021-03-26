//
//  SSDPNodeParser.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import os

private enum SSDPNodeResponseKey: String {
    case cacheControl = "CACHE-CONTROL"
    case location = "LOCATION"
    case server = "SERVER"
    case searchTarget = "ST"
    case uniqueServiceName = "USN"
}

final class SSDPNodeParser: SSDPNodeParserProtocol {
    
    private let dateFactory: DateFactoryProtocol
    
    init(dateFactory: DateFactoryProtocol =  DateFactory()) {
        self.dateFactory = dateFactory
    }
    
    func parse(_ data: Data) -> SSDPNode? {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        var responseDict = parseResponseIntoDictionary(responseString)
        
        guard let cacheControl = parseCacheControl(responseDict[SSDPNodeResponseKey.cacheControl.rawValue]),
              let location = parseLocation(responseDict[SSDPNodeResponseKey.location.rawValue]),
              let server = responseDict[SSDPNodeResponseKey.server.rawValue],
              let searchTarget = responseDict[SSDPNodeResponseKey.searchTarget.rawValue],
              let uniqueServiceName = responseDict[SSDPNodeResponseKey.uniqueServiceName.rawValue] else {
            return nil
        }
        
        responseDict.removeValue(forKey: SSDPNodeResponseKey.cacheControl.rawValue)
        responseDict.removeValue(forKey: SSDPNodeResponseKey.location.rawValue)
        responseDict.removeValue(forKey: SSDPNodeResponseKey.server.rawValue)
        responseDict.removeValue(forKey: SSDPNodeResponseKey.searchTarget.rawValue)
        responseDict.removeValue(forKey: SSDPNodeResponseKey.uniqueServiceName.rawValue)
        
        return SSDPNode(cacheControl: cacheControl,
                        location: location,
                        server: server,
                        searchTarget: searchTarget,
                        uniqueServiceName: uniqueServiceName,
                        otherHeaders: responseDict)
    }
    
    private func parseResponseIntoDictionary(_ response: String) -> [String: String] {
        var elements = [String: String]()
        for element in response.split(separator: "\r\n") {
            let keyValuePair = element.split(separator: ":", maxSplits: 1)
            guard keyValuePair.count == 2 else {
                continue
            }
            
            let key = String(keyValuePair[0]).uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let value = String(keyValuePair[1]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            elements[key] = value
        }
        
        return elements
    }
    
    private func parseCacheControl(_ value: String?) -> Date? {
        guard let cacheControlRange = value?.range(of: "[0-9]+$", options: .regularExpression),
              let cacheControlString = value?[cacheControlRange],
              let cacheControlTimeInterval = TimeInterval(cacheControlString) else {
            return nil
        }
        
        let currentDate = dateFactory.currentDate()
        return currentDate.addingTimeInterval(cacheControlTimeInterval)
    }
    
    private func parseLocation(_ value: String?) -> URL? {
        guard let urlString = value,
              let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
}
