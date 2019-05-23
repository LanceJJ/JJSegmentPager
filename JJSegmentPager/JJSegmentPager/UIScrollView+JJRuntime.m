//
//  UIScrollView+JJRuntime.m
//  JJSegmentPager
//
//  Created by Lance on 2019/4/9.
//  Copyright © 2019 Lance. All rights reserved.
//

#import "UIScrollView+JJRuntime.h"
#import <objc/runtime.h>

@implementation UIScrollView (JJRuntime)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jj_swizzleMethodWithOrignalSel:@selector(setContentSize:) replacementSel:@selector(jj_setContentSize:)];
    });
}

- (CGFloat)minContentSizeHeight
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setMinContentSizeHeight:(CGFloat)minContentSizeHeight
{
    objc_setAssociatedObject(self, @selector(minContentSizeHeight), @(minContentSizeHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// replace method
- (void)jj_setContentSize:(CGSize)contentSize
{
    if (contentSize.height < self.minContentSizeHeight) {
        contentSize = CGSizeMake(contentSize.width, self.minContentSizeHeight);
    }
    [self jj_setContentSize:contentSize];
}

// exchange method
+ (BOOL)jj_swizzleMethodWithOrignalSel:(SEL)originalSel replacementSel:(SEL)replacementSel
{
    Method origMethod = class_getInstanceMethod(self, originalSel);
    Method replMethod = class_getInstanceMethod(self, replacementSel);
    
    if (!origMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), [self class]);
        return NO;
    }
    
    if (!replMethod) {
        NSLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), [self class]);
        return NO;
    }
    
    if (class_addMethod(self, originalSel, method_getImplementation(replMethod), method_getTypeEncoding(replMethod)))
    {
        class_replaceMethod(self, replacementSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, replMethod);
    }
    return YES;
}

@end
