//
//  UIFont+ApsectsScaling.m
//  platonWallet
//
//  Created by Admin on 17/4/2019.
//  Copyright © 2019 ju. All rights reserved.
//

#import "UIFont+ApsectsScaling.h"
#import <objc/runtime.h>

@implementation UIFont (ApsectsScaling)
    
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        Method original, swizzled;
//
//        original = class_getClassMethod(self, @selector(fontWithName:size:));
//        swizzled = class_getClassMethod(self, @selector(fontWithNameX:size:));
//        method_exchangeImplementations(original, swizzled);
//
//        original = class_getClassMethod(self, @selector(fontWithSize:));
//        swizzled = class_getClassMethod(self, @selector(fontWithSizeX:));
//        method_exchangeImplementations(original, swizzled);
//
//        original = class_getClassMethod(self, @selector(systemFontOfSize:));
//        swizzled = class_getClassMethod(self, @selector(systemFontOfSizeX:));
//        method_exchangeImplementations(original, swizzled);
//
//        original = class_getClassMethod(self, @selector(fontWithDescriptor:size:));
//        swizzled = class_getClassMethod(self, @selector(fontWithDescriptorX:size:));
//        method_exchangeImplementations(original, swizzled);
        
        Class class = [self class];

        SEL originalFontWithNameSel = @selector(fontWithName:size:);
        SEL swizzledFontWithNameSel = @selector(fontWithNameX:size:);

        SEL originalFontWithSizeSel = @selector(fontWithSize:);
        SEL swizzledFontWithSizeSel = @selector(fontWithSizeX:);

        SEL originalSystemFontOfSizeSel = @selector(systemFontOfSize:);
        SEL swizzledSystemFontOfSizeSel = @selector(systemFontOfSizeX:);

        SEL originalFontWithDescriptorSel = @selector(fontWithDescriptor:size:);
        SEL swizzledFontWithDescriptorSel = @selector(fontWithDescriptorX:size:);

        Method originalFontWithNameMethod = class_getClassMethod(self, originalFontWithNameSel);
        Method swizzledFontWithNameMethod = class_getClassMethod(self, swizzledFontWithNameSel);

        Method originalFontWithSizeMethod = class_getClassMethod(self, originalFontWithSizeSel);
        Method swizzledFontWithSizeMethod = class_getClassMethod(self, swizzledFontWithSizeSel);

        Method originalSystemFontOfSizeMethod = class_getClassMethod(self, originalSystemFontOfSizeSel);
        Method swizzledSystemFontOfSizeMethod = class_getClassMethod(self, swizzledSystemFontOfSizeSel);

        Method originalFontWithDescriptorMethod = class_getClassMethod(self, originalFontWithDescriptorSel);
        Method swizzledFontWithDescriptorMethod = class_getClassMethod(self, swizzledFontWithDescriptorSel);

        BOOL didAddMethod1 = class_addMethod(class, originalFontWithNameSel, method_getImplementation(swizzledFontWithNameMethod), method_getTypeEncoding(swizzledFontWithNameMethod));

        BOOL didAddMethod2 = class_addMethod(class, originalFontWithSizeSel, method_getImplementation(swizzledFontWithSizeMethod), method_getTypeEncoding(swizzledFontWithSizeMethod));

        BOOL didAddMethod3 = class_addMethod(class, originalSystemFontOfSizeSel, method_getImplementation(swizzledSystemFontOfSizeMethod), method_getTypeEncoding(swizzledSystemFontOfSizeMethod));

        BOOL didAddMethod4 = class_addMethod(class, originalFontWithDescriptorSel, method_getImplementation(swizzledFontWithDescriptorMethod), method_getTypeEncoding(swizzledFontWithDescriptorMethod));

        if (didAddMethod1 && didAddMethod2 && didAddMethod3 && didAddMethod4) {
            class_replaceMethod(class, swizzledFontWithNameSel, method_getImplementation(originalFontWithNameMethod), method_getTypeEncoding(originalFontWithNameMethod));

            class_replaceMethod(class, swizzledFontWithSizeSel, method_getImplementation(originalFontWithSizeMethod), method_getTypeEncoding(originalFontWithSizeMethod));

            class_replaceMethod(class, swizzledSystemFontOfSizeSel, method_getImplementation(originalSystemFontOfSizeMethod), method_getTypeEncoding(originalSystemFontOfSizeMethod));

            class_replaceMethod(class, swizzledFontWithDescriptorSel, method_getImplementation(originalFontWithDescriptorMethod), method_getTypeEncoding(originalFontWithDescriptorMethod));
        } else {
            method_exchangeImplementations(originalFontWithNameMethod, swizzledFontWithNameMethod);
            method_exchangeImplementations(originalFontWithSizeMethod, swizzledFontWithSizeMethod);
            method_exchangeImplementations(originalSystemFontOfSizeMethod, swizzledSystemFontOfSizeMethod);
            method_exchangeImplementations(originalFontWithDescriptorMethod, swizzledFontWithDescriptorMethod);
        }
    });
}
    
+ (nullable UIFont *)fontWithNameX:(NSString *)fontName size:(CGFloat)fontSize {
    CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
    return [self fontWithNameX:fontName size:fontSize*ratio];
}
    
- (UIFont *)fontWithSizeX:(CGFloat)fontSize {
    CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
    return [self fontWithSizeX:fontSize*ratio];
}
    
+ (UIFont *)systemFontOfSizeX:(CGFloat)fontSize {
    CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
    return [self systemFontOfSizeX:fontSize*ratio];
}
    
+ (UIFont *)fontWithDescriptorX:(UIFontDescriptor *)descriptor size:(CGFloat)pointSize {
    CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
    return [self fontWithDescriptorX:descriptor size:pointSize*ratio];
}

@end
