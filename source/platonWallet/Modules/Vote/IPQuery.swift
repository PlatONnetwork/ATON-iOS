//
//  IPQuery.swift
//  platonWallet
//
//  Created by Ned on 24/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Alamofire

let queryURL = "http://ip-api.com/batch"

let IPListPerRequest = 50

class IPQuery: BaseService {
    
    static let sharedInstance = IPQuery()
    var queryingIpArray = [[String]]()
    let queue = DispatchQueue(label: "batchQueryIPs")
    
    func getIPGeoInfoFromDB(ipList: [String]) -> [String:IPGeoInfo] {
        
        //filter exist IpGeoInfo in DB
        let existedIpInfos = IPGeoPersistence.filter(isIncludedIp: ipList)
        let existedIps = existedIpInfos.map { (info) -> String in
            return info.ipAddr
        }
        var dic = [String:IPGeoInfo]()
        for info in existedIpInfos {
            dic[info.ipAddr] = info
        }
        var ipSet = Set(ipList)
        ipSet.subtract(existedIps)
        let notExistIps = ipSet.sorted()
        for notExistIp in notExistIps {
            dic[notExistIp] = IPGeoInfo()
        }
        batchQueryIPs(ipList: notExistIps, completion: nil)
        return dic
    }

    private func batchQueryIPs(ipList: [String], completion: PlatonCommonCompletion?) {
        
        guard queryingIpArray.count == 0 && ipList.count > 0 else {
            return
        }
        let count = ipList.count / IPListPerRequest
        for i in 0...count{
            let start = i*IPListPerRequest
            let end = min(ipList.count, (i+1)*IPListPerRequest)
            queryingIpArray.append(Array(ipList[start..<end]))
        }
        
        queue.async {
            for i in 0..<self.queryingIpArray.count {
                self.queryIPs(ipList: self.queryingIpArray[i]) { (res, data) in
                    
                    switch res{
                    case .success:
                        if let res = data as? [IPGeoInfo] {
                            IPGeoPersistence.add(infos: res)
                        }
                    case .fail( _, _):
                        break
                    }
                    self.queryingIpArray.remove(at: i)
                }
            }
        }
        
    }
    
    private func queryIPs(ipList: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var values = [[String:String]]()
        for ip in ipList{
            let singleQuery = [
                "query": ip,
                "fields": "countryCode,query",
                ]
            values.append(singleQuery)
        }
        var request = URLRequest(url: try! queryURL.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
                
            case .success(let resp):
                
                guard let resp = resp as? [[String:String]] else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
                    return
                }
                
                self.successCompletionOnMain(obj: processCountryInfo(data: resp) as AnyObject, completion: &completion)
                    
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
            }
        }
        
    }
    
}

func processCountryInfo(data: [[String:String]]) -> [IPGeoInfo] {
    
    var result = [IPGeoInfo]()
    for country in data{
        let countryItem = IPGeoInfo()
        countryItem.countryCode = country["countryCode"] ?? ""
        countryItem.ipAddr = country["query"] ?? ""
        countryItem.updateTime = Int(Date().timeIntervalSince1970)
        result.append(countryItem)
    }
    return result
}
