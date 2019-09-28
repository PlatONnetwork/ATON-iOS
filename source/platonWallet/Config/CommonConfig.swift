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
            (nodeURL: AppFramework.sharedInstance.AppEnvConfig.getConfigURLInfo().NodeRPCURL, desc: "SettingsVC_nodeSet_defaultTestNetwork_Amigo_des", isSelected: true)
            //            (nodeURL: DefaultNodeURL_UAT, desc: "SettingsVC_nodeSet_defaultTestNetwork_des", isSelected: false),
            //            (nodeURL: DefaultNodeURL_PRODUCT, desc: "SettingsVC_nodeSet_defaultProductNetwork_des", isSelected: false)
        ]
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
            static let serviceurl_en = ""
            static let serviceurl_cn = ""
            
            static var serviceurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? serviceurl_cn : serviceurl_en
            }
        }
        
        struct FAQURL {
            static let faq_en = ""
            static let faq_cn = ""
            
            static var faqurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? faq_cn : faq_en
            }
        }
        
        struct TutorialURL {
            static let tutorial_en = ""
            static let tutorial_cn = ""
            
            static var tutorialurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? tutorial_cn : tutorial_en
            }
        }
        
        struct FeedbackURL {
            static let feedback_en = ""
            static let feedback_cn = ""
            
            static var feedbackurl: String {
                return GetCurrentSystemSettingLanguage() == "cn" ? feedback_cn : feedback_en
            }
        }
    }
    
    struct ServerURL {
        struct HOST {
            static let UATNET = ""
            static let PRODUCTNET = ""
            static let TESTNET = ""
            static let DEVNET = ""
        }
        static let PATH = ""
    }
    
}
