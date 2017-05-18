//
//  BBNoticeSender.m
//  ZgSafe
//
//  Created by box on 14-1-11.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBNoticeSender.h"

#define NOTICE_LABEL_HEIGHT 20.0f

@interface BBNoticeSender()
{
    
}

@property (nonatomic,retain)UILabel *textLable;

@end

@implementation BBNoticeSender

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        self.clipsToBounds = YES;
        
        _textLable = [[UILabel alloc]init];
        _textLable.backgroundColor = [UIColor blackColor];
        _textLable.font = [UIFont systemFontOfSize:14.];
        _textLable.textColor = [UIColor whiteColor];
        _textLable.textAlignment = NSTextAlignmentCenter;
        _textLable.numberOfLines = 0;
        
        _showFullLine = NO;
    }
    return self;
}

- (void)dealloc
{
    [_textLable release];
    [super dealloc];
}


+ (void)showNotice:(NSString *)notice
{
    if (appDelegate.EyesVCShowwing) {
        return;
    }
    

    
//    notice = @"123";
    BBNoticeSender *noticeSender = [[BBNoticeSender alloc]init];
    
    noticeSender.textLable.text = notice;
    
    CGSize size = [notice sizeWithFont:noticeSender.textLable.font
       constrainedToSize:CGSizeMake(320, 60)
           lineBreakMode:noticeSender.textLable.lineBreakMode];
//12 -- 14.316
    NSInteger n = (NSInteger)(size.height / 16.702f);

    noticeSender.textLable.frame = CGRectMake(0
                                              , 0
                                              , 320
                                              , NOTICE_LABEL_HEIGHT*n);
    if (noticeSender.showFullLine) {
        noticeSender.frame = CGRectMake(0
                                        , -NOTICE_LABEL_HEIGHT*n
                                        , 320
                                        , NOTICE_LABEL_HEIGHT*n);
    }else{
        noticeSender.frame = CGRectMake(0
                                        , -NOTICE_LABEL_HEIGHT
                                        , 320
                                        , NOTICE_LABEL_HEIGHT);
    }
    
    [noticeSender addSubview:noticeSender.textLable];
    [noticeSender makeKeyAndVisible];
    [appDelegate.window makeKeyAndVisible];
    

    [UIView animateWithDuration:0.5f animations:^{
        noticeSender.center = CGPointMake(noticeSender.center.x
                                          , noticeSender.center.y
                                          +NOTICE_LABEL_HEIGHT*(noticeSender.showFullLine?n:1));
    }completion:^(BOOL finished) {
        if (noticeSender.showFullLine
            || (!noticeSender.showFullLine && n==1)) {
            [NSTimer scheduledTimerWithTimeInterval:2.0f
                                             target:noticeSender
                                           selector:@selector(removeNoticeSender:)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:noticeSender
                                           selector:@selector(scrollToNextLine:)
                                           userInfo:nil
                                            repeats:YES];
        }
    }];
}

- (void)removeNoticeSender:(NSTimer *)timer
{
    [UIView animateWithDuration:0.5f animations:^{
        self.center = CGPointMake(self.center.x, -self.frame.size.height/2.0f);
    }completion:^(BOOL finished) {
        [self release];
    }];
}

/*!
 *@description  滚动到下一行
 *@function     scrollToNextLine:
 *@param        timer
 *@return       (void)
 */
- (void)scrollToNextLine:(NSTimer *)timer
{
    CGRect frame = _textLable.frame;
    frame.origin.y -= self.frame.size.height;
    if (frame.origin.y+frame.size.height <= self.frame.size.height) {
        //还没滚道尽头
        [UIView animateWithDuration:0.5f animations:^{
            _textLable.frame = frame;
        }];
    }else{
        //滚到尽头了
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(removeNoticeSender:)
                                       userInfo:nil
                                        repeats:NO];
        [timer invalidate];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
