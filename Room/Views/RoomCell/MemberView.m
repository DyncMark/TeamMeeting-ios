//
//  MemberView.m
//  Room
//
//  Created by zjq on 15/12/30.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "MemberView.h"

@interface MemberView()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *numberLabel;
- (void)layout;
@end

@implementation MemberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        self.imageView.backgroundColor = [UIColor redColor];
        
        self.numberLabel = [UILabel new];
        [self addSubview:self.numberLabel];
        self.numberLabel.textAlignment = NSTextAlignmentLeft;
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.backgroundColor = [UIColor grayColor];
        [self layout];
    }
    return self;
}
- (void)layout
{
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    
     NSLayoutConstraint * constraint1 = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.f];
    
    NSLayoutConstraint * constraint2 = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant: 0];
    
    NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0];
    
    NSLayoutConstraint * constraint4 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    
    NSLayoutConstraint * constraint5 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeRight multiplier:1.0f constant: .0f];
    
    NSLayoutConstraint * constraint6 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0];
    
    NSLayoutConstraint * constraint7 = [NSLayoutConstraint constraintWithItem:_numberLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:.0f];
    
    
    [self addConstraint:constraint];
    [self addConstraint:constraint1];
    [self addConstraint:constraint2];
    [self addConstraint:constraint3];
    [self addConstraint:constraint4];
    [self addConstraint:constraint5];
    [self addConstraint:constraint6];
    [self addConstraint:constraint7];
    
}

- (void)setNum:(NSString*)num
{
    self.numberLabel.text = num;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
