//
//  UINavigationBar+Category.m
//  Room
//
//  Created by zjq on 15/12/9.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "UINavigationBar+Category.h"
#import "FackNavView.h"
#import <objc/runtime.h>

@implementation UINavigationBar (Category)
static char overlayKey;

- (FackNavView *)overlay
{
    return objc_getAssociatedObject(self, &overlayKey);
}
- (void)setOverlay:(FackNavView *)overlay
{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rm_setBackgroundColor:(UIColor *)backgroundColor
{
    if (!self.overlay) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
        self.overlay = [[FackNavView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 64)];
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.overlay atIndex:0];
    }
    self.overlay.backgroundColor = backgroundColor;
}

@end
