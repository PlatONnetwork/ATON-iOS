//
//  ATONConfig.swift
//  platonWallet
//
//  Created by Admin on 27/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation


struct ATONConfig {
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
}
