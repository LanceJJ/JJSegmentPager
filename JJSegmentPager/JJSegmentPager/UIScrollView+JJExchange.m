//
//  UIScrollView+JJExchange.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "UIScrollView+JJExchange.h"
#import <objc/runtime.h>

@implementation UIScrollView (JJExchange)

// 定义关联的key
static const char *key_jj_replaceScrollViewDidScrollBlock = "jj_replaceScrollViewDidScrollBlock";

- (void (^)(UIScrollView *scrollView))jj_replaceScrollViewDidScrollBlock
{
    return objc_getAssociatedObject(self, key_jj_replaceScrollViewDidScrollBlock);
}

- (void)setJj_replaceScrollViewDidScrollBlock:(void (^)(UIScrollView * _Nonnull))jj_replaceScrollViewDidScrollBlock
{
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, key_jj_replaceScrollViewDidScrollBlock, jj_replaceScrollViewDidScrollBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class_UIScrollView = NSClassFromString(@"UIScrollView");

        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(jj_setDelegate:);

        Method originalMethod = class_getInstanceMethod(class_UIScrollView, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class_UIScrollView, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class_UIScrollView,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class_UIScrollView,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}

- (void)jj_setDelegate:(id<UIScrollViewDelegate>)delegate
{
    [self jj_setDelegate:delegate];
    
    if (([self isMemberOfClass:[UIScrollView class]] || [self isMemberOfClass:[UITableView class]] || [self isMemberOfClass:[UICollectionView class]]) && delegate) {
        
        [self exchangeScrollViewDelegateMethod:delegate];
    }
}

- (void)exchangeScrollViewDelegateMethod:(id<UIScrollViewDelegate>)delegate
{
    Class originalClass = [delegate class];
    SEL originalSel = @selector(scrollViewDidScroll:);
    Class replacedClass = [self class];
    SEL replacedSel = @selector(jj_replace_scrollViewDidScroll:);
    SEL orginReplaceSel = @selector(jj_add_scrollViewDidScroll:);
    
    // 原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    // 替换的实例方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    
    // 如果没有实现 delegate 方法，则手动动态添加
    if (!originalMethod) {
        Method orginReplaceMethod = class_getInstanceMethod(replacedClass, orginReplaceSel);

        BOOL didAddOriginMethod = class_addMethod(originalClass, originalSel, method_getImplementation(orginReplaceMethod), method_getTypeEncoding(orginReplaceMethod));
        if (didAddOriginMethod) {
            NSLog(@"did Add Origin Replace Method");
            
            //添加成功之后，重置代理，交换方法
            self.delegate = nil;
            self.delegate = delegate;
        }
        return;
    }

    BOOL didAddMethod =
    class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    // 添加成功，交换方法
    if (didAddMethod) {
        NSLog(@"class_addMethod succeed --> (%@)", NSStringFromSelector(replacedSel));
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        method_exchangeImplementations(originalMethod, newMethod);
    // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换
    } else {
        NSLog(@"class_addMethod fail --> (%@)", NSStringFromSelector(replacedSel));
    }
    
}

- (void)jj_replace_scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"replace_scrollViewDidScroll-%f-%@", scrollView.contentOffset.y, [self class]);
    [self jj_replace_scrollViewDidScroll:scrollView];
    
    if (scrollView.jj_replaceScrollViewDidScrollBlock) {
        scrollView.jj_replaceScrollViewDidScrollBlock(scrollView);
    }
}

- (void)jj_add_scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"jj_add_scrollViewDidScroll-%f-%@", scrollView.contentOffset.y, [self class]);
}

@end
