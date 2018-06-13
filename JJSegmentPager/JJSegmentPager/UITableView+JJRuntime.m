//
//  UITableView+JJRuntime.m
//  JJSegmentPager
//
//  Created by Lance on 2018/6/12.
//  Copyright © 2018年 Lance. All rights reserved.
//

#import "UITableView+JJRuntime.h"
#import <objc/runtime.h>


@implementation UITableView (JJRuntime)

// 定义关联的key
static const char *key_didReloadData = "didReloadData";

- (void (^)(void))didReloadData
{
    return objc_getAssociatedObject(self, key_didReloadData);
}

- (void)setDidReloadData:(void (^)(void))didReloadData
{
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, key_didReloadData, didReloadData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //进行方法交换，目的：让UITableView reloadData的时候可以被监听到
        Class class_UITableView = NSClassFromString(@"UITableView");
        
        
        SEL originalSelector = @selector(reloadData);
        SEL swizzledSelector = @selector(swizzlingReloadData);
        
        Method originalMethod = class_getInstanceMethod(class_UITableView, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class_UITableView, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class_UITableView,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class_UITableView,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzlingReloadData
{
    [self swizzlingReloadData];
    
    if (self.didReloadData) {
        self.didReloadData();
    }
    
}

@end
