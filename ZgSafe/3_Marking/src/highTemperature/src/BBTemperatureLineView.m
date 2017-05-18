//
//  BBTemperatureLineView.m
//  ZgSafe
//
//  Created by box on 13-11-6.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBTemperatureLineView.h"

@interface BBTemperatureLineView()
@property (retain, nonatomic) IBOutlet UILabel *currentTemperature;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *fromLabel;
@property (nonatomic, retain) IBOutlet UILabel *toLabel;

@end

@implementation BBTemperatureLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)dealloc {
    [_fromLabel release];
    [_toLabel release];
    [_dateLabel release];
    [_currentTemperature release];
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (!_temperatureArr) {
        return;
    }
    
    CGFloat max = 0;
    for (NSString *str in _temperatureArr) {
        if ([str floatValue] > max) {
            max = [str floatValue];
        }
    }
    
    CGFloat zeroY = 250.;//X轴对应的高度（0摄氏度）
    CGFloat scaleHeight = 135.;//绘图区域的高度
    
    
    if (max==0.0f) {
        max = 10.0f;
        zeroY = 190.0f;
    }
    
//    if (appDelegate.window.frame.size.height == 480.) {
//        zeroY *= 1.;
//        scaleHeight *= 1.;
//    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    for (int i = 0; i<_temperatureArr.count; i++) {
        
        CGFloat value = [_temperatureArr[i] floatValue];
        CGFloat height = value/max*scaleHeight;
        CGRect dotFrame = CGRectMake(START_X+(WIDTH+GAP)*i
                                     , zeroY - height
                                     , 10, 10);
        
        //画线
        if (i>0) {
            
            [[UIColor whiteColor]set];
            CGContextSetLineWidth(context, 4);
            
            CGFloat lastHeight = [_temperatureArr[i-1] floatValue]/max*scaleHeight;
            CGRect lastDotFrame = CGRectMake(START_X+(WIDTH+GAP)*(i-1)
                                         , zeroY - lastHeight
                                         , 10, 10);
            
            CGContextMoveToPoint(context
                                 
                                 ,START_X
                                 +(WIDTH+GAP)*i
                                 +dotFrame.size.width/2.
                                 
                                 , zeroY
                                 - height
                                 +dotFrame.size.width/2.);
            
            CGContextAddLineToPoint(context
                                    
                                    ,START_X
                                    +(WIDTH+GAP)*(i-1)
                                    +dotFrame.size.width/2.
                                    
                                    , zeroY
                                    - lastHeight
                                    +dotFrame.size.width/2.);
            CGContextStrokePath(context);
            
            
            [[UIImage imageNamed:@"temperature_dot"] drawInRect:lastDotFrame];
        }
        
        if (i == _temperatureArr.count-1) {
            
            [[UIImage imageNamed:@"temperature_dot"] drawInRect:dotFrame];
        }
        
        //标值
        [[UIColor getColorWithRed:240 andGreen:181 andBlue:76]set];
        NSString *tempStr = [NSString stringWithFormat:@"%d℃",(NSInteger)([_temperatureArr[i] floatValue]+0.5f)];
        if (i%2) {
            [tempStr drawAtPoint:CGPointMake(dotFrame.origin.x-10
                                             , dotFrame.origin.y-15)
                        withFont:[UIFont systemFontOfSize:12]];
        }else{
            [tempStr drawAtPoint:CGPointMake(dotFrame.origin.x-10
                                             , dotFrame.origin.y+10)
                        withFont:[UIFont systemFontOfSize:12]];
        }
    }
}

- (void)setDateStr:(NSString *)dateStr
{
    if ([_dateStr isEqualToString:dateStr]) {
        return ;
    }
    _dateStr = dateStr;
    self.dateLabel.text = self.dateStr;
}

- (void)setFromTime:(NSString *)fromTime
{
    if ([_fromTime isEqualToString:fromTime]) {
        return;
    }
    _fromTime = fromTime;
    self.fromLabel.text = self.fromTime;
}

- (void)setToTime:(NSString *)toTime
{
    if ([self.toTime isEqualToString:toTime]) {
        return ;
    }
    _toTime = toTime;
    self.toLabel.text = self.toTime;
}

- (void)setCurTemp:(NSString *)curTemp
{
    if (self.curTemp && [self.curTemp isEqualToString:curTemp]) {
        return ;
    }
    _curTemp = curTemp;
    self.currentTemperature.text = self.curTemp;
}


@end
