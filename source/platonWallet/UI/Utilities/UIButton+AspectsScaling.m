//
//  UIButton+AspectsScaling.m
//  platonWallet
//
//  Created by Admin on 19/4/2019.
//  Copyright © 2019 ju. All rights reserved.
//

#import "UIButton+AspectsScaling.h"
#import <objc/runtime.h>

@implementation UIButton (AspectsScaling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSel = @selector(initWithCoder:);
        SEL swizzledSel = @selector(initWithCoderX:);
        Method originalMethod = class_getInstanceMethod([self class], originalSel);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
        BOOL didAddMethod = class_addMethod([self class], originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod([self class], swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSel = @selector(initWithFrame:);
        swizzledSel = @selector(initWithFrameX:);
        originalMethod = class_getInstanceMethod([self class], originalSel);
        swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
        didAddMethod = class_addMethod([self class], originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod([self class], swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (instancetype)initWithCoderX:(NSCoder *)aDecoder {
    self = [self initWithCoderX:aDecoder];
    if (self) {
        CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.font.pointSize*ratio];
    }
    
    return self;
}

- (instancetype)initWithFrameX:(CGRect)frame {
    self = [self initWithFrameX:frame];
    if (self) {
        CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.font.pointSize*ratio];
    }
    
    return self;
}

@end
