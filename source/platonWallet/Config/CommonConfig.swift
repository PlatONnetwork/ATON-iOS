//
//  CommonConfig.swift
//  platonWallet
//
//  Created by Admin on 10/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Localize_Swift

struct AppConfig {
    struct Keys {
        static let BuglyAppleID = "e8f57be7d2"
        static let Production_Umeng_key = "5d551ffd3fc1959f6b000113"
        static let Test_Umeng_key = "5d57a9ba570df380e2000b23"
    }

    struct ChainID {
        static let VERSION_074 = "97"
        static let VERSION_0741 = "96"
        static let VERSION_076 = "95"
        static let VERSION_0110 = "101"
        static let VERSION_0120 = "102"
        static let VERSION_0130 = "103"
        static let VERSION_MAINTESTNET = "104"
        static let VERSION_MAINNET = "100"
        static let VERSION_UATNET = "298"
        static let DEV = "103"
        static let TEST1 = "100"
    }

    struct Hrp {
        static let LAT = "lat"
        static let LAX = "lax"
    }

    struct NodeURL {
        static let DefaultNodeURL_Alpha_V071 = ServerURL.HOST.TESTNET + "/rpc"
        static let DefaultNodeURL_Alpha_V071_DEV = ServerURL.HOST.DEVNET + "/rpc"
        static let DefaultNodeURL_UAT = ServerURL.HOST.UATNET + "/rpc"
        static let DefaultNodeURL_MAINTEST = ServerURL.HOST.MAINTESTNET + "/rpc"
        static let DefaultNodeURL_MAIN = ServerURL.HOST.MAINNET + "/rpc"

        #if ENVIROMENT_DEV // UAT
//        test 模拟主网络 链id  =  100       接入地址：58.250.250.234:1000        内部接入地址： 192.168.9.190:1000
//        dev 模拟测试网 链id  =  103       接入地址：58.250.250.234:1100        内部接入地址： 192.168.9.190:443
        static let defaultNodesURL = [
            (nodeURL: AppConfig.NodeURL.DefaultNodeURL_Alpha_V071, desc: "SettingsVC_nodeSet_defaultTestNetwork_test_des", chainId: AppConfig.ChainID.TEST1, isSelected: true, hrp: AppConfig.Hrp.LAT),
            (nodeURL: AppConfig.NodeURL.DefaultNodeURL_Alpha_V071_DEV, desc: "SettingsVC_nodeSet_defaultTestNetwork_develop_des", chainId: AppConfig.ChainID.DEV, isSelected: false, hrp: AppConfig.Hrp.LAX)
        ]
        #elseif ENVIROMENT_UAT // PARALLELNET
        static let defaultNodesURL = [
            (nodeURL: DefaultNodeURL_UAT, desc: "SettingsVC_nodeSet_parallel_des", chainId: AppConfig.ChainID.VERSION_UATNET, isSelected: false, hrp: AppConfig.Hrp.LAX),
        ]
        #else
        /// isShowMainNet用于在构建时决定是否显示主网。下列代码需要与jenkins中的配置相对应
        static let isShowMainNet = true
        static let defaultNodesURL = isShowMainNet == true ? [
            (nodeURL: DefaultNodeURL_MAIN, desc: "SettingsVC_nodeSet_Chuantuo_des", chainId: AppConfig.ChainID.VERSION_MAINNET, isSelected: false, hrp: AppConfig.Hrp.LAT),
            (nodeURL: DefaultNodeURL_MAINTEST, desc: "SettingsVC_nodeSet_NewBaleyworld_des", chainId: AppConfig.ChainID.VERSION_MAINTESTNET, isSelected: false, hrp: AppConfig.Hrp.LAX)]
            : [(nodeURL: DefaultNodeURL_MAINTEST, desc: "SettingsVC_nodeSet_NewBaleyworld_des", chainId: AppConfig.ChainID.VERSION_MAINTESTNET, isSelected: false, hrp: AppConfig.Hrp.LAX)]
        #endif
    }

    struct TimerSetting {
        static let pendingTransactionPollingTimerEnable = true
        static let pendingTransactionPollingTimerInterval = 3
        static let balancePollingTimerInterval = 5
        static let viewControllerUpdateInterval = 3
    }

    struct H5URL {
        struct LisenceURL {
            static var serviceurl: String {
                return SettingService.shareInstance.getCentralizationHost() + (Localize.currentLanguage() == "en" ? "/aton-agreement/en-us/v0760/agreement.html" : "/aton-agreement/zh-cn/v0760/agreement.html")
            }
        }

        struct FAQURL {
            static let faq_en = "https://platon.zendesk.com/hc/en-us/articles/360037373194-Common-questions-about-PlatON-Delegators"
            static let faq_cn = "https://platon.zendesk.com/hc/zh-cn/articles/360037373194-%E5%A7%94%E6%89%98%E4%BA%BA%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98"

            static var faqurl: String {
                return Localize.currentLanguage() == "en" ? faq_en : faq_cn
            }
        }

        struct TutorialURL {
            static let tutorial_en = "https://platon.zendesk.com/hc/en-us/categories/360002193633"
            static let tutorial_cn = "https://platon.zendesk.com/hc/zh-cn/categories/360002193633"

            static var tutorialurl: String {
                return Localize.currentLanguage() == "en" ? tutorial_en : tutorial_cn
            }
        }

        struct FeedbackURL {
            static let feedback_en = "https://platon.zendesk.com/hc/en-us"
            static let feedback_cn = "https://platon.zendesk.com/hc/zh-cn"

            static var feedbackurl: String {
                return Localize.currentLanguage() == "en" ? feedback_en : feedback_cn
            }
        }

        struct PrivacyPolicyURL {
            static var policyurl: String {
                return SettingService.shareInstance.getCentralizationHost() + (Localize.currentLanguage() == "en" ? "/aton-agreement/en-us/privacyAgreement.html" : "/aton-agreement/zh-cn/privacyAgreement.html")
            }        }
    }

    struct ServerURL {
        struct HOST {
            static let UATNET = "https://aton.uat.platon.network"
            static let MAINTESTNET = "https://aton.test.platon.network"
            static let MAINNET = "https://aton.main.platon.network"
            static let TESTNET = "http://58.250.250.234:1000"
//            static let TESTNET = "http://192.168.9.190:1000"
            static let DEVNET = "http://58.250.250.234:1100"
//            static let DEVNET = "http://192.168.9.190:443"
        }
        static let PATH = "/app/v0760"
    }

    struct AppInfo {
        static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    struct OvertimeTranction {
        static let overtime = 2*60*60*1000
    }
}

extension String {
    var chainid: String {
        #if ENVIROMENT_DEV // UAT
        switch self {
        case AppConfig.NodeURL.DefaultNodeURL_Alpha_V071_DEV:
            return AppConfig.ChainID.DEV
        default:
            return AppConfig.ChainID.TEST1
        }
        #elseif ENVIROMENT_UAT // PARALLELNET
        return AppConfig.ChainID.VERSION_UATNET
        #else
        switch self {
        case AppConfig.NodeURL.DefaultNodeURL_MAIN:
            return AppConfig.ChainID.VERSION_MAINNET
        default:
            return AppConfig.ChainID.VERSION_MAINTESTNET
        }
        #endif
    }
}
