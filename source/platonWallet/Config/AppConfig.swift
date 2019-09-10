//
//  AppConfig.swift
//  platonWallet
//
//  Created by Ned on 2019/8/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct AppConfig {
    struct Keys {
//        static let BuglyAppleID = "e8f57be7d2"
        static let BuglyAppleID = "beeb997bda"
        static let Production_Umeng_key = "5d551ffd3fc1959f6b000113"
        static let Test_Umeng_key = "5d57a9ba570df380e2000b23"
    }
    
    struct NodeURL {
        static let DefaultNodeURL_Alpha_V071 = "http://192.168.9.190:1000/rpc"
    }
    
    struct TimerSetting {
        static let blockNumberQueryTimerEnable = true
        static let blockNumberQueryTimerInterval = 8
        static let pendingTransactionPollingTimerEnable = true
        static let pendingTransactionPollingTimerInterval = 3
        static let notPendingTransactionPollingTimerInterval = 10
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
            static let TESTNET = "http://192.168.9.190:1000"
            static let DEVNET = "http://192.168.9.190:443"
        }
        static let PATH = "/app/v0700"
    }
}
