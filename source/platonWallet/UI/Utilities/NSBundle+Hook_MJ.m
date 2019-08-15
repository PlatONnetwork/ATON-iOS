//
//  NSBundle+Hook_MJ.m
//  platonWallet
//
//  Created by Admin on 31/5/2019.
//  Copyright © 2019 ju. All rights reserved.
//

#import "NSBundle+Hook_MJ.h"
#import <MJRefresh/MJRefresh.h>

@implementation NSBundle (Hook_MJ)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSel = @selector(mj_localizedStringForKey:value:);
        SEL swizzledSel = @selector(hook_mj_localizedStringForKey:value:);
        
        Method originalMethod = class_getClassMethod([NSBundle class], originalSel);
        Method swizzledMethod = class_getClassMethod(self, swizzledSel);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}



+ (NSString *)hook_mj_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *language = [userDefaults objectForKey:@"LCLCurrentLanguageKey"];
    if (language == nil) {
        NSArray *availableLanguages = NSBundle.mainBundle.localizations;
        NSString *preferredLanguage = NSBundle.mainBundle.preferredLocalizations.firstObject;
        if ([availableLanguages containsObject:preferredLanguage]) {
            language = preferredLanguage;
        } else {
            language = @"en";
        }
    }
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mj_refreshBundle] pathForResource:language ofType:@"lproj"]];
    return [bundle localizedStringForKey:key value:nil table:@"Localizable"];
}

@end
