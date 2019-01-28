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

enum ISO3166: String {
    case en = "en"
    case zh_CN = "zh-CN"
}


class CountryArea {
    var ipAddr: String = ""
    var countryCode : String = ""
    var country: String = ""
}

class IPQuery: BaseService {
    
    static let sharedInstance = IPQuery()

    func batchQueryIPs(ipList: [String],localized: ISO3166?, completion: PlatonCommonCompletion?) {
        var completion = completion
        var ipll : [[String]] = []
        if ipList.count > IPListPerRequest{
            let count = ipList.count / IPListPerRequest
            for i in 0...count{
                if (i+1)*IPListPerRequest < ipList.count{
                    ipll.append(Array(ipList[i*IPListPerRequest..<(i+1)*IPListPerRequest]))
                }else{
                    ipll.append(Array(ipList[i*IPListPerRequest..<ipList.count]))
                }
            }
        }else{
            ipll.append(ipList)
        }
        
        let queue = DispatchQueue(label: "batchQueryIPs")
        let semaphore = DispatchSemaphore(value: 1)
        var countryAreaMap : [Dictionary<String,CountryArea>] = []
        queue.async {
            for item in ipll{
                self.queryIPs(ipList: item, localized: localized) { (result, data) in
                    switch result{
                        
                    case .success:
                        if let res = data as? [Dictionary<String,CountryArea>]{
                            countryAreaMap.append(contentsOf: res)
                        }
                    case .fail(let code, let message):
                        self.failCompletionOnMainThread(code: code!, errorMsg: message!, completion: &completion)
                    }
                    semaphore.signal()
                }
                if semaphore.wait(timeout: .now() + 10.0) == .timedOut{
                    self.timeOutCompletionOnMainThread(completion: &completion)
                }
            }
            
            self.successCompletionOnMain(obj: countryAreaMap as AnyObject, completion: &completion)
        }
    
    }
    
    
    func queryIPs(ipList: [String],localized: ISO3166?, completion: PlatonCommonCompletion?) {
        var completion = completion
        var values : [Dictionary<String,String>] = []
        for ip in ipList{
            let singleQuery = [
                "query": ip,
                "fields": "country,countryCode,query",
                "lang": localized?.rawValue,
                ]
            values.append(singleQuery as! [String : String])
        }
        var request = URLRequest(url: try! queryURL.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        request.httpMethod = "POST"
    
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
                
            case .success(_):
                do{
                    guard response.data != nil , response.data?.count != 0, let map = try? JSONSerialization.jsonObject(with: response.data!, options: []) else {
                        self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
                        return
                    }
                    
                    self.successCompletionOnMain(obj: processCountryInfo(countries: map as! [Dictionary<String, String>]) as AnyObject, completion: &completion)
                    
                }
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
            }
        }
        
    }
    
}

func processCountryInfo(countries: [Dictionary<String,String>]) -> [Dictionary<String,CountryArea>]{
    var result : [Dictionary<String,CountryArea>] = []
    for country in countries{
        if let ip = country["query"]{
            let countryItem = CountryArea()
            countryItem.country = rightCountryname(countryName: country["country"] ?? "")
            countryItem.countryCode = country["countryCode"] ?? ""
            countryItem.ipAddr = country["query"] ?? ""
            result.append([ip:countryItem])
        }
    }
    return result
}

func rightCountryname(countryName: String) -> String{
    if countryName.range(of: "台湾")?.lowerBound != nil{
        return "中国台湾"
    }
    
    if countryName.range(of: "澳门")?.lowerBound != nil{
       return "中国澳门"
    }
    
    if countryName.range(of: "香港")?.lowerBound != nil{
        return "中国香港"
    }
    
    if countryName.lowercased().range(of: "taiwan".lowercased())?.lowerBound != nil{
        return "Taiwan, China"
    }
    
    if countryName.lowercased().range(of: "hongkong")?.lowerBound != nil{
        return "Hongkong, China"
    }
    
    if countryName.lowercased().range(of: "macau")?.lowerBound != nil{
        return "Macau, China"
    }
    
    if countryName.lowercased().range(of: "macao")?.lowerBound != nil{
        return "Macao, China"
    }
    
    return countryName
}
