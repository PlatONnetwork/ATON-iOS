//
//  UILabel+AspectsScaling.m
//  platonWallet
//
//  Created by Admin on 17/4/2019.
//  Copyright © 2019 ju. All rights reserved.
//

#import "UILabel+AspectsScaling.h"
#import <Aspects/Aspects.h>

@implementation UILabel (AspectsScaling)

+ (void)load {
    NSError * error = nil;
    [self aspect_hookSelector:@selector(initWithCoder:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, NSCoder * coder) {
        [info.instance scaleFont];
    } error:&error];
    [self aspect_hookSelector:@selector(initWithFrame:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, CGRect frame) {
        [info.instance scaleFont];
    } error:&error];
    //以下是log方法，可以不要
#if DEBUG
    [self aspect_hookSelector:@selector(scaleFont) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
        UILabel * label = info.instance;
        NSLog(@"UILabel: Before Scaling font size: %f", label.font.pointSize);
    } error:&error];
    [self aspect_hookSelector:@selector(scaleFont) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
        UILabel * label = info.instance;
        NSLog(@"UILabel: After Scaling font size: %f", label.font.pointSize);
    } error:&error];
#endif
}
    
- (void)scaleFont {
    CGFloat ratio = CGRectGetWidth(UIScreen.mainScreen.bounds) / (CGFloat)375;
    self.font = [UIFont fontWithDescriptor:self.font.fontDescriptor size:self.font.pointSize * ratio];
}
    
@end
