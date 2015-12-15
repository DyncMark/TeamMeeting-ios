//
//  FackNavView.m
//  Room
//
//  Created by zjq on 15/12/9.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "FackNavView.h"

@implementation FackNavView

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    //1.获取图形上下文
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    //2.绘图（画线）
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 133.0/255.0, 138.0/255.0, 141.0/255.0, 1);
    
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1);  //线宽
    //设置起点
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height);
    //设置终点
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height);
    //渲染
    CGContextStrokePath(ctx);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
