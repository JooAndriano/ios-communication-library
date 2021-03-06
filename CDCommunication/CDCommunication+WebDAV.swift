//
//  CDCommunication+WebDAV.swift
//  CDCommunication
//
//  Created by Marino Faggiana on 07/05/2020.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@calldrive.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Alamofire
import SwiftyJSON

extension CDCommunication {

    @objc public func createFolder(_ serverUrlFileName: String, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ ocId: String?, _ date: NSDate?, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account

        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, nil, nil, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "MKCOL")
        
        let headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)

        sessionManager.request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, nil, error.errorCode, error.description ?? "")
            case .success( _):
                let ocId = CDCommunicationCommon.shared.findHeader("oc-fileid", allHeaderFields: response.response?.allHeaderFields)
                if let dateString = CDCommunicationCommon.shared.findHeader("date", allHeaderFields: response.response?.allHeaderFields) {
                    if let date = CDCommunicationCommon.shared.convertDate(dateString, format: "EEE, dd MMM y HH:mm:ss zzz") {
                        completionHandler(account, ocId, date, 0, "")
                    } else {
                        completionHandler(account, nil, nil, NSURLErrorBadServerResponse, NSLocalizedString("_invalid_date_format_", value: "Invalid date format", comment: ""))
                    }
                } else {
                    completionHandler(account, nil, nil, NSURLErrorBadServerResponse, NSLocalizedString("_invalid_date_format_", value: "Invalid date format", comment: ""))
                }
            }
        }
    }
     
    @objc public func deleteFileOrFolder(_ serverUrlFileName: String, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account

        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "DELETE")
        
        let headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)

        sessionManager.request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, error.errorCode, error.description ?? "")
            case .success( _):
                completionHandler(account, 0, "")
            }
        }
    }
     
    @objc public func moveFileOrFolder(serverUrlFileNameSource: String, serverUrlFileNameDestination: String, overwrite: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account

        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileNameSource) else {
            completionHandler(account, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "MOVE")
         
        var headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        headers.update(name: "Destination", value: serverUrlFileNameDestination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        if overwrite {
            headers.update(name: "Overwrite", value: "T")
        } else {
            headers.update(name: "Overwrite", value: "F")
        }
         
        sessionManager.request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, error.errorCode, error.description ?? "")
            case .success( _):
                completionHandler(account, 0, "")
            }
        }
    }
     
    @objc public func copyFileOrFolder(serverUrlFileNameSource: String, serverUrlFileNameDestination: String, overwrite: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account

        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileNameSource) else {
            completionHandler(account, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "COPY")
         
        var headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        headers.update(name: "Destination", value: serverUrlFileNameDestination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        if overwrite {
            headers.update(name: "Overwrite", value: "T")
        } else {
            headers.update(name: "Overwrite", value: "F")
        }
         
        sessionManager.request(url, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, error.errorCode, error.description ?? "")
            case .success( _):
                completionHandler(account, 0, "")
            }
        }
    }
     
    @objc public func readFileOrFolder(serverUrlFileName: String, depth: String, showHiddenFiles: Bool = true, requestBody: Data? = nil, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ responseData: Data?, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account
        var files: [CDCommunicationFile] = []
        var serverUrlFileName = String(serverUrlFileName)
        
        if depth == "1" && serverUrlFileName.last != "/" { serverUrlFileName = serverUrlFileName + "/" }
        if depth == "0" && serverUrlFileName.last == "/" { serverUrlFileName = String(serverUrlFileName.remove(at: serverUrlFileName.index(before: serverUrlFileName.endIndex))) }
        
        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, files, nil, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "PROPFIND")
         
        var headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        headers.update(.contentType("application/xml"))
        headers.update(name: "Depth", value: depth)

        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            if requestBody != nil {
                urlRequest.httpBody = requestBody!
            } else {
                urlRequest.httpBody = CDDataFileXML().requestBodyFile.data(using: .utf8)
            }
        } catch {
            completionHandler(account, files, nil, error._code, error.localizedDescription)
            return
        }
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseData { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, files, nil, error.errorCode, error.description ?? "")
            case .success( _):
                if let data = response.data {
                    files = CDDataFileXML().convertDataFile(data: data, showHiddenFiles: showHiddenFiles)
                    completionHandler(account, files, data, 0, "")
                } else {
                    completionHandler(account, files, nil, NSURLErrorBadServerResponse, NSLocalizedString("_error_decode_xml_", value: "Invalid response, error decode XML", comment: ""))
                }
            }
        }
    }
     
    @objc public func searchBodyRequest(serverUrl: String, requestBody: String, showHiddenFiles: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, timeout: TimeInterval = 60, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account
        let httpBody = requestBody.data(using: .utf8)!
     
        search(serverUrl: serverUrl, httpBody: httpBody, showHiddenFiles: showHiddenFiles, customUserAgent: customUserAgent, addCustomHeaders: addCustomHeaders, account: account, timeout: timeout) { (account, files, erroCode, errorDescription) in
            completionHandler(account,files,erroCode,errorDescription)
        }
    }
    
    @objc public func searchLiteral(serverUrl: String, depth: String, literal: String, showHiddenFiles: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, timeout: TimeInterval = 60, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account
        let files: [CDCommunicationFile] = []

        guard let href = CDCommunicationCommon.shared.encodeString("/files/" + CDCommunicationCommon.shared.userId) else {
            completionHandler(account, files, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
        
        let requestBody = String(format: CDDataFileXML().requestBodySearchFileName, href, depth, "%"+literal+"%")
        let httpBody = requestBody.data(using: .utf8)!
     
        search(serverUrl: serverUrl, httpBody: httpBody, showHiddenFiles: showHiddenFiles, customUserAgent: customUserAgent, addCustomHeaders: addCustomHeaders, account: account, timeout: timeout) { (account, files, erroCode, errorDescription) in
            completionHandler(account,files,erroCode,errorDescription)
        }
    }
    
    @objc public func searchMedia(path: String = "", lessDate: Any, greaterDate: Any, elementDate: String, limit: Int, showHiddenFiles: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, timeout: TimeInterval = 60, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ errorCode: Int, _ errorDescription: String) -> Void) {
            
        let account = CDCommunicationCommon.shared.account
        let files: [CDCommunicationFile] = []
        var greaterDateString: String?, lessDateString: String?
        
        guard let href = CDCommunicationCommon.shared.encodeString("/files/" + CDCommunicationCommon.shared.userId + path) else {
            completionHandler(account, files, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
        
        if lessDate is Date || lessDate is NSDate {
            lessDateString = CDCommunicationCommon.shared.convertDate(lessDate as! Date, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
        } else if lessDate is Int {
            lessDateString = String(lessDate as! Int)
        }
        
        if greaterDate is Date || greaterDate is NSDate {
            greaterDateString = CDCommunicationCommon.shared.convertDate(greaterDate as! Date, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
        } else if greaterDate is Int {
            greaterDateString = String(greaterDate as! Int)
        }
        
        if lessDateString == nil || greaterDateString == nil {
            completionHandler(account, files, NSURLErrorBadURL, NSLocalizedString("_invalid_date_format_", value: "Invalid date format", comment: ""))
            return
        }
        
        var requestBody = ""
        if limit > 0 {
            requestBody = String(format: CDDataFileXML().requestBodySearchMediaWithLimit, href, elementDate, elementDate, lessDateString!, elementDate, greaterDateString!, String(limit))
        } else {
            requestBody = String(format: CDDataFileXML().requestBodySearchMedia, href, elementDate, elementDate, lessDateString!, elementDate, greaterDateString!)
        }
        
        let httpBody = requestBody.data(using: .utf8)!
        
        search(serverUrl: CDCommunicationCommon.shared.urlBase, httpBody: httpBody, showHiddenFiles: showHiddenFiles, customUserAgent: customUserAgent, addCustomHeaders: addCustomHeaders, account: account, timeout: timeout) { (account, files, erroCode, errorDescription) in
            completionHandler(account,files,erroCode,errorDescription)
        }
    }
     
    private func search(serverUrl: String, httpBody: Data, showHiddenFiles: Bool, customUserAgent: String?, addCustomHeaders: [String: String]?, account: String, timeout: TimeInterval, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        var files: [CDCommunicationFile] = []
        
        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrl + "/" + CDCommunicationCommon.shared.dav) else {
            completionHandler(account, files, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "SEARCH")
         
        var headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        headers.update(.contentType("text/xml"))
         
        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            urlRequest.httpBody = httpBody
            urlRequest.timeoutInterval = timeout
        } catch {
            completionHandler(account, files, error._code, error.localizedDescription)
            return
        }
         
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseData { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, files, error.errorCode, error.description ?? "")
            case .success( _):
                if let data = response.data {
                    files = CDDataFileXML().convertDataFile(data: data, showHiddenFiles: showHiddenFiles)
                    completionHandler(account, files, 0, "")
                } else {
                    completionHandler(account, files, NSURLErrorBadServerResponse, NSLocalizedString("_error_decode_xml_", value: "Invalid response, error decode XML", comment: ""))
                }
            }
        }
    }
     
    @objc public func setFavorite(fileName: String, favorite: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account
        let serverUrlFileName = CDCommunicationCommon.shared.urlBase + "/" + CDCommunicationCommon.shared.dav + "/files/" + CDCommunicationCommon.shared.userId + "/" + fileName
        
        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "PROPPATCH")
        
        let headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
         
        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            let body = NSString.init(format: CDDataFileXML().requestBodyFileSetFavorite as NSString, (favorite ? 1 : 0)) as String
            urlRequest.httpBody = body.data(using: .utf8)
        } catch {
            completionHandler(account, error._code, error.localizedDescription)
            return
        }
         
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, error.errorCode, error.description ?? "")
            case .success( _):
                completionHandler(account, 0, "")
            }
        }
    }
     
    @objc public func listingFavorites(showHiddenFiles: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ files: [CDCommunicationFile], _ errorCode: Int, _ errorDescription: String) -> Void) {
         
        let account = CDCommunicationCommon.shared.account
        let serverUrlFileName = CDCommunicationCommon.shared.urlBase + "/" + CDCommunicationCommon.shared.dav + "/files/" + CDCommunicationCommon.shared.userId
        var files: [CDCommunicationFile] = []

        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, files, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
         
        let method = HTTPMethod(rawValue: "REPORT")
        
        let headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
         
        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            urlRequest.httpBody = CDDataFileXML().requestBodyFileListingFavorites.data(using: .utf8)
        } catch {
            completionHandler(account, files, error._code, error.localizedDescription)
            return
        }
         
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseData { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, files, error.errorCode, error.description ?? "")
            case .success( _):
                if let data = response.data {
                    files = CDDataFileXML().convertDataFile(data: data, showHiddenFiles: showHiddenFiles)
                    completionHandler(account, files, 0, "")
                } else {
                    completionHandler(account, files, NSURLErrorBadServerResponse, NSLocalizedString("_error_decode_xml_", value: "Invalid response, error decode XML", comment: ""))
                }
            }
        }
    }
    
    @objc public func listingTrash(showHiddenFiles: Bool, customUserAgent: String? = nil, addCustomHeaders: [String: String]? = nil, completionHandler: @escaping (_ account: String, _ items: [CDCommunicationTrash], _ errorCode: Int, _ errorDescription: String) -> Void) {
           
        let account = CDCommunicationCommon.shared.account
        var items: [CDCommunicationTrash] = []
        let serverUrlFileName = CDCommunicationCommon.shared.urlBase + "/" + CDCommunicationCommon.shared.dav + "/trashbin/" + CDCommunicationCommon.shared.userId + "/trash/"
            
        guard let url = CDCommunicationCommon.shared.encodeStringToUrl(serverUrlFileName) else {
            completionHandler(account, items, NSURLErrorBadURL, NSLocalizedString("_invalid_url_", value: "Invalid server url", comment: ""))
            return
        }
        
        let method = HTTPMethod(rawValue: "PROPFIND")
             
        var headers = CDCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        headers.update(.contentType("application/xml"))
        headers.update(name: "Depth", value: "1")

        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            urlRequest.httpBody = CDDataFileXML().requestBodyTrash.data(using: .utf8)
        } catch {
            completionHandler(account, items, error._code, error.localizedDescription)
            return
        }
             
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseData { (response) in
            debugPrint(response)
            
            switch response.result {
            case .failure(let error):
                let error = CDCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, items, error.errorCode, error.description ?? "")
            case .success( _):
                if let data = response.data {
                    items = CDDataFileXML().convertDataTrash(data: data, showHiddenFiles: showHiddenFiles)
                    completionHandler(account, items, 0, "")
                } else {
                    completionHandler(account, items, NSURLErrorBadServerResponse, NSLocalizedString("_error_decode_xml_", value: "Invalid response, error decode XML", comment: ""))
                }
            }
        }
    }
}
