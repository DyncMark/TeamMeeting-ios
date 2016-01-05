//
//  GetRoomView.m
//  Room
//
//  Created by zjq on 15/11/19.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "GetRoomView.h"
#import "CustomInputAccessoryView.h"

#define GetRoomViewHeight 60
#define TextViewHeight 24
@interface GetRoomView()<UITextFieldDelegate,CustomInputAccessoryViewDelegate>
{
    UIView *textInputView;  // 输入栏view
    
    UITextField *textInputTextView; // 输入框
    
    UIImageView *dismissButton;  // 隐藏view;
    
    UIView *parentsView;
    
    BOOL isChangeName;
    
    NSString *roomName;
    
    UITapGestureRecognizer *tapGesture;
}
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isPrivateMetting;
@end

@implementation GetRoomView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withParView:(UIView*)parview
{
    self = [super initWithFrame:frame];
    if ( self) {
        
        parentsView = parview;
        
        self.backgroundColor = [UIColor clearColor];
        
//        dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        dismissButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        [dismissButton addTarget:self action:@selector(dismissGetRoomView) forControlEvents:UIControlEventTouchUpInside];
        [parview addSubview:dismissButton];
        [parview sendSubviewToBack:dismissButton];
        
        dismissButton.hidden = YES;
        if (ISIPAD) {
             textInputView = [[UIView alloc] initWithFrame:CGRectMake(0, -GetRoomViewHeight, ISIPADMainList, GetRoomViewHeight)];
        }else{
             textInputView = [[UIView alloc] initWithFrame:CGRectMake(0, -GetRoomViewHeight, frame.size.width, GetRoomViewHeight)];
        }
        
        textInputView.backgroundColor = [UIColor clearColor];// [UIColor colorWithRed:36.0/255.0 green:65.0/255.0 blue:89.0/255.0 alpha:1.0];
        [self addSubview:textInputView];
        
        UIImageView *lineDown = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(textInputView.frame)-.5, CGRectGetWidth(textInputView.frame), .5)];
        lineDown.backgroundColor = [UIColor colorWithRed:133.0/255.0 green:138.0/255.0 blue:141.0/255.0 alpha:1];
        [textInputView addSubview:lineDown];
        
        textInputTextView = [[UITextField alloc] initWithFrame:CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, CGRectGetWidth(textInputView.frame) - 30, TextViewHeight)];
   
        [self addSubview:textInputTextView];
        CustomInputAccessoryView *customInputView = [[CustomInputAccessoryView alloc] initWithTextField:textInputTextView];
        customInputView.delegate = self;
        textInputTextView.placeholder = @"房间名字";
        [textInputTextView setValue:[UIColor colorWithRed:146.0/255.0 green:160.0/255.0 blue:169.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
         [textInputTextView setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
        
        textInputTextView.tintColor = [UIColor colorWithRed:235.0/255.0 green:139.0/255.0 blue:75.0/255.0 alpha:1.0];
        
        textInputTextView.font = [UIFont boldSystemFontOfSize:16];
        
        textInputTextView.textColor =[UIColor whiteColor];
        textInputTextView.returnKeyType = UIReturnKeyDone;
        textInputTextView.delegate = self;
       
        [parview addSubview:self];
        [parview sendSubviewToBack:self];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGetRoomView)];
        [parview addGestureRecognizer:tapGesture];
        tapGesture.enabled = NO;
        
    }
    return self;
}


- (void)showGetRoomView
{
    tapGesture.enabled = YES;
    self.isShow = YES;
    
    isChangeName = NO;
    roomName = @"";
    
    [parentsView bringSubviewToFront:self];
    dismissButton.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        CGRect rect = textInputView.bounds;
        rect.origin.y = 0;
        textInputView.frame = rect;
        
        CGRect rectTextView = textInputTextView.bounds;
        rectTextView.origin.y = (GetRoomViewHeight -TextViewHeight)/2;
        rectTextView.origin.x = 15;
        textInputTextView.frame = rectTextView;
        dismissButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }completion:^(BOOL finished) {
        [textInputTextView becomeFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            textInputView.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:65.0/255.0 blue:89.0/255.0 alpha:1.0];
        }];
       
        if (delegate && [delegate respondsToSelector:@selector(showCancleButton)]) {
            [delegate showCancleButton];
        }
    }];
}
- (void)showWithRenameRoom:(NSString*)room
{
    self.isShow = YES;
    tapGesture.enabled = YES;
    
    isChangeName = YES;
    roomName = room;
    
    [parentsView bringSubviewToFront:self];
     dismissButton.hidden = NO;
    
    textInputTextView.text = roomName;
    [textInputTextView becomeFirstResponder];
    [UIView animateWithDuration:.3 animations:^{
        CGRect rect = textInputView.bounds;
        rect.origin.y = 0;
        textInputView.frame = rect;
        
        CGRect rectTextView = textInputTextView.bounds;
        rectTextView.origin.y = (GetRoomViewHeight -TextViewHeight)/2;
        rectTextView.origin.x = 15;
        textInputTextView.frame = rectTextView;
       textInputView.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:65.0/255.0 blue:89.0/255.0 alpha:1.0];
        dismissButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }completion:^(BOOL finished) {
        
        if (delegate && [delegate respondsToSelector:@selector(showCancleButton)]) {
            [delegate showCancleButton];
        }
    }];
    
}

- (void)dismissView
{
    self.isShow = NO;
    tapGesture.enabled = NO;
    dismissButton.hidden = YES;
    [textInputTextView resignFirstResponder];
    dismissButton.backgroundColor = [UIColor clearColor];
    if (isChangeName) {
        if (delegate && [delegate respondsToSelector:@selector(cancleRename:)]) {
            [delegate cancleRename:roomName];
        }
         textInputTextView.text = @"";
        [UIView animateWithDuration:0.2 animations:^{
            textInputView.frame = CGRectMake(0, -GetRoomViewHeight, textInputView.frame.size.width, textInputView.bounds.size.height);
            textInputTextView.frame = CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, textInputTextView.frame.size.width, textInputTextView.frame.size.height);
            textInputView.alpha = 0;
        
        }completion:^(BOOL finished) {
           [parentsView sendSubviewToBack:self];
            textInputView.alpha = 1;
            dismissButton.hidden = NO;
            textInputView.backgroundColor = [UIColor clearColor];
        }];
        
    }else{
        if (delegate && [delegate respondsToSelector:@selector(cancleGetRoom)]) {
            [delegate cancleGetRoom];
        }
        
        CGRect rect1 = textInputView.bounds;
        rect1.origin.x = -textInputView.frame.size.width/2;
        
        CGRect rect2 = textInputTextView.bounds;
        rect2.origin.x = -textInputTextView.frame.size.width/2;
        
        [UIView animateWithDuration:0.2 animations:^{
            textInputView.alpha = 0;
            textInputView.frame = rect1;
            
            textInputTextView.alpha = 0;
            textInputTextView.frame = rect2;
            
        }completion:^(BOOL finished) {
            textInputView.frame = CGRectMake(0, -GetRoomViewHeight, textInputView.frame.size.width, textInputView.bounds.size.height);
            textInputView.alpha = 1;
            
            textInputTextView.frame = CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, textInputTextView.bounds.size.width, textInputTextView.bounds.size.height);
            textInputTextView.alpha = 1;
            textInputView.backgroundColor = [UIColor clearColor];
            textInputTextView.text = @"";
            
            dismissButton.hidden = NO;
            textInputView.backgroundColor = [UIColor clearColor];
            [parentsView sendSubviewToBack:self];
        }];
    }
}

- (void)dismissGetRoomView
{
    if (!self.isShow) {
        return;
    }
    if (isChangeName) {
        if (textInputTextView.text.length == 0) {
            CGPoint point  = textInputTextView.layer.position;
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
            shake.duration = 0.1;
            shake.autoreverses = YES;
            shake.repeatCount = 4;
            shake.fromValue = [NSValue valueWithCGPoint:point];
            shake.toValue = [NSValue valueWithCGPoint:CGPointMake(point.x+10, point.y)];
            [textInputTextView.layer addAnimation:shake forKey:@"move-layer"];
            
        }else{
            self.isShow = NO;
            tapGesture.enabled = NO;
            dismissButton.hidden = YES;
            [textInputTextView resignFirstResponder];
            dismissButton.backgroundColor = [UIColor clearColor];
            
            if (delegate && [delegate respondsToSelector:@selector(renameRoomNameScuess:)]) {
                [delegate renameRoomNameScuess:textInputTextView.text];
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                textInputView.frame = CGRectMake(0, -GetRoomViewHeight, CGRectGetWidth(textInputView.frame), textInputView.bounds.size.height);
                textInputTextView.frame = CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, textInputTextView.frame.size.width, textInputTextView.frame.size.height);
                textInputView.alpha = 0;
                 textInputTextView.alpha = 0;
            }completion:^(BOOL finished) {
             
                textInputView.alpha = 1;
                
                textInputTextView.alpha = 1;
                
                textInputTextView.text = @"";
                textInputView.backgroundColor = [UIColor clearColor];
                
                [parentsView sendSubviewToBack:self];

            }];
            
        }
    }else{
        self.isShow = NO;
        tapGesture.enabled = NO;
        dismissButton.hidden = YES;
        [textInputTextView resignFirstResponder];
        dismissButton.backgroundColor = [UIColor clearColor];
        
        if (textInputTextView.text.length>0) {
            [UIView animateWithDuration:0.2 animations:^{
                textInputView.alpha = 0;
                textInputTextView.frame = CGRectMake(textInputTextView.frame.origin.x, textInputTextView.frame.origin.y - 8, textInputTextView.frame.size.width, textInputTextView.frame.size.height);
            }completion:^(BOOL finished) {
                textInputView.frame = CGRectMake(0, -GetRoomViewHeight, CGRectGetWidth(textInputView.frame), textInputView.bounds.size.height);
                textInputView.alpha = 1;
                
                textInputTextView.frame = CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, textInputTextView.frame.size.width, textInputTextView.frame.size.height);
                textInputTextView.text = @"";
                
                dismissButton.hidden = NO;
                
                textInputView.backgroundColor = [UIColor clearColor];
                
                [parentsView sendSubviewToBack:self];
            }];
            if (delegate && [delegate respondsToSelector:@selector(getRoomWithRoomName:withPrivateMetting:)]) {
                [delegate getRoomWithRoomName:textInputTextView.text withPrivateMetting:self.isPrivateMetting];
            }
            
        }else{
            if (delegate && [delegate respondsToSelector:@selector(cancleGetRoom)]) {
                [delegate cancleGetRoom];
            }
            CGRect rect1 = textInputView.bounds;
            rect1.origin.x = -textInputView.frame.size.width/2;
            
            CGRect rect2 = textInputTextView.bounds;
            rect2.origin.x = -textInputTextView.frame.size.width/2;
            
            [UIView animateWithDuration:0.2 animations:^{
                textInputView.alpha = 0;
                textInputView.frame = rect1;
                
                textInputTextView.alpha = 0;
                textInputTextView.frame = rect2;
                
            }completion:^(BOOL finished) {
                textInputView.frame = CGRectMake(0, -GetRoomViewHeight, CGRectGetWidth(textInputView.frame), textInputView.bounds.size.height);
                textInputView.alpha = 1;
                
                textInputTextView.frame = CGRectMake(15, -(GetRoomViewHeight-TextViewHeight)/2, textInputTextView.bounds.size.width, textInputTextView.bounds.size.height);
                textInputTextView.alpha = 1;
                
                textInputTextView.text = @"";
                textInputView.backgroundColor = [UIColor clearColor];
                dismissButton.hidden = NO;
                
                [parentsView sendSubviewToBack:self];
            }];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissGetRoomView];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self dismissGetRoomView];
    return YES;
}
#pragma mark - CustomInputAccessoryViewDelegate
- (void) customInputAccessoryViewDelegateOpenPrivate:(BOOL)isOpen
{
    self.isPrivateMetting = isOpen;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
