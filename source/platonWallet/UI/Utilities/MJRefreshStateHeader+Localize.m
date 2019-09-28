//
//  MJRefreshStateHeader+Localize.m
//  platonWallet
//
//  Created by Admin on 3/6/2019.
//  Copyright © 2019 ju. All rights reserved.
//

#import "MJRefreshStateHeader+Localize.h"
#import <objc/runtime.h>

@implementation MJRefreshStateHeader (Localize)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSel = @selector(setState:);
        SEL swizzledSel = @selector(hook_setState:);

        Method originalMethod = class_getInstanceMethod([self class], originalSel);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
        BOOL didAddMethod = class_addMethod([self class], originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod([self class], swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)hook_setState:(MJRefreshState)state
{
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderIdleText] forState:MJRefreshStateIdle];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderPullingText] forState:MJRefreshStatePulling];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderRefreshingText] forState:MJRefreshStateRefreshing];
    [self hook_setState:state];
}

@end
