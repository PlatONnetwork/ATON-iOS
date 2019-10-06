//
//  CommonConfig.swift
//  platonWallet
//
//  Created by Admin on 10/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct AppConfig {
    struct Keys {
        //        static let BuglyAppleID = ""
        static let BuglyAppleID = ""
        static let Production_Umeng_key = ""
        static let Test_Umeng_key = ""
    }
    
    struct NodeURL {
        static let DefaultNodeURL_Alpha_V071 = ServerURL.HOST.TESTNET + "/rpc"
        static let DefaultNodeURL_UAT = ServerURL.HOST.UATNET + "/rpc"
        static let DefaultNodeURL_PRODUCT = ServerURL.HOST.PRODUCTNET + "/rpc"
        
        static let defaultNodesURL = [
            (nodeURL: AppConfig.NodeURL.DefaultNodeURL_Alpha_V071, desc: "SettingsVC_nodeSet_defaultTestNetwork_Amigo_des", isSelected: true)
            ,(nodeURL: DefaultNodeURL_UAT, desc: "SettingsVC_nodeSet_defaultTestNetwork_des", isSelected: false),
            (nodeURL: DefaultNodeURL_PRODUCT, desc: "SettingsVC_nodeSet_defaultProductNetwork_des", isSelected: false)
        ]
    }
    
    struct TimerSetting {
        static let pendingTransactionPollingTimerEnable = true
        static let pendingTransactionPollingTimerInterval = 3
        static let balancePollingTimerInterval = 5
    }
    
    struct H5URL {
        struct lisenceURL {
            static let serviceurl_en = "http://192.168.9.190:1000/aton-agreement/en-us/agreement.html"
            static let serviceurl_cn = "http://192.168.9.190:1000/aton-agreement/zh-cn/agreement.html"
            
            static var serviceurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? serviceurl_cn : serviceurl_en
            }
        }
        
        struct FAQURL {
            static let faq_en = "https://platon.zendesk.com/hc/en-us/categories/360002174434"
            static let faq_cn = "https://platon.zendesk.com/hc/zh-cn/categories/360002174434"
            
            static var faqurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? faq_cn : faq_en
            }
        }
        
        struct TutorialURL {
            static let tutorial_en = "https://platon.zendesk.com/hc/en-us/categories/360002193633"
            static let tutorial_cn = "https://platon.zendesk.com/hc/zh-cn/categories/360002193633"
            
            static var tutorialurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? tutorial_cn : tutorial_en
            }
        }
        
        struct FeedbackURL {
            static let feedback_en = "https://platon.zendesk.com/hc/en-us"
            static let feedback_cn = "https://platon.zendesk.com/hc/zh-cn"
            
            static var feedbackurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? feedback_cn : feedback_en
            }
        }
    }
    
    struct ServerURL {
        struct HOST {
            static let UATNET = "https://aton.test.platon.network"
            static let PRODUCTNET = "https://aton.main.platon.network"
            static let TESTNET = "http://192.168.9.190:1000"
            static let DEVNET = "http://192.168.9.190:443"
        }
        static let PATH = "/app/v0700"
    }
    
}
