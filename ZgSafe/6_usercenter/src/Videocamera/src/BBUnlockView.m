//
//  CellView.m
//  ScreenUnLcoked
//
//  Created by 020 on 13-7-8.
//  Copyright (c) 2013年 赵 文双. All rights reserved.
//

#import "BBUnlockView.h"

@implementation BBUnlockView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _len = 0;
        flag = 0;
        //获取密码
        [self getPswd];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect
{
    // Drawing code 
    
    if (1==flag) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 10.0f);
        [[[UIColor yellowColor] colorWithAlphaComponent:0.4] set];
        
        
        for (int i=1; i<_len; i++) {
            
            UIImageView *imgView = (UIImageView *)[self viewWithTag:_points[i-1]];
            UIImageView *imgView2 = (UIImageView *)[self viewWithTag:_points[i]];
            CGContextMoveToPoint(context, imgView.center.x,imgView.center.y );
            CGContextAddLineToPoint(context, imgView2.center.x,imgView2.center.y);
        }
        if (_len)
        {
            UIImageView *imgView = (UIImageView *)[self viewWithTag:_points[_len-1]];
            CGContextMoveToPoint(context, imgView.center.x,imgView.center.y );
            CGContextAddLineToPoint(context, _currentPoint.x,_currentPoint.y);
            CGContextStrokePath(context);
        }
    }
    else if(2==flag)
    {
    }
    else if(0 == flag)
    {
        
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 40)];
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.backgroundColor = [UIColor clearColor];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLable];
        [_titleLable release];
        
        if (_isModifyPswd) {
            BlueBoxer *user = [BlueBoxerManager getCurrentUser];
            if (user.gestureUnlock) {
                _startModifyPswd = NO;
                _titleLable.text = @"请绘制当前解锁图案";
            }else{
                _startModifyPswd = YES;
                _titleLable.text = @"请设置解锁图案";
            }
        }else{
            _titleLable.text = @"请绘制解锁图案";
        }
        
        for (int i=0; i<9; i++)
        {
            UIImageView *cell = [[UIImageView alloc]initWithFrame:CGRectMake(
                                                                             originPoint.x
                                                                             +(i%3)*(CELLSIZE+GAP),
                                                                             
                                                                             originPoint.y
                                                                             + (CELLSIZE+GAP)*((int)(i/3)),
                                                                             
                                                                             CELLSIZE,
                                                                             CELLSIZE)];
            
            [cell setImage:[UIImage imageNamed:@"unselected"]];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setTag:10001+i];
            [self addSubview:cell];
            [cell release];
        }
        flag=1;
    }
    
    
}


//- (void)setPswd
//{
//    _isModifyPswd = YES;
//}

- (void)getPswd
{
    BlueBoxer *user = [BlueBoxerManager getCurrentUser];
    
    NSArray *arr = user.gestureUnlock;
    
    if (arr)
    {
        _lenPswd = [arr count];
        
        for (int i=0; i<_lenPswd; i++)
        {
            _password[i] = [((NSNumber *)[arr objectAtIndex:i]) intValue];
        }
    }
    else
    {
//        //初始密码
//        _points[0] = 10001;
//        _points[1] = 10002;
//        _points[2] = 10003;
//        _len = 3;
//        
//        [self savePswd];
    }
}


- (void)savePswd
{
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:9];
    
    for (int i=0; i<_len; i++) {
        _password[i] = _points[i];
    }
    _lenPswd = _len;
    for (int i=0; i<_lenPswd; i++)
    {
        [arr addObject:[NSNumber numberWithInt:_password[i]]];
    }
    BlueBoxer *user = [BlueBoxerManager getCurrentUser];
    user.gestureUnlock = arr;
    [BlueBoxerManager archiveCurrentUser:user];
  
}


- (BOOL)checkPswd
{
    if (_len != _lenPswd) {
        return NO;
    }
    //检测密码是否正确
    for(int i=0;i<_len;i++)
    {
        if (_points[i] != _password[i]) {
            
            return NO;
        }
    }
    return YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (int i=0; i<9; i++)
    {
        [self unlightCellWithTag:10001+i];
    }
    flag=2;
    [self setNeedsDisplay];
    
    if (_startModifyPswd && _len) {
        
        if (_len<4) {
            UtilAlert(@"不能小于4个点",nil);
            return;
        }
        _isModifyPswd = NO;
        [self savePswd];
        if (_delegate && [_delegate respondsToSelector:@selector(didSetPasswordCompleted:)]) {
            [_delegate didSetPasswordCompleted:self];
        }
        
        
        [UIView animateWithDuration:0.5f animations:^{
            self.alpha = 0.;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
        return;
        
    }
    
    if(_len)
    {
        //检测密码是否正确
        BOOL suc = [self checkPswd];
        
        if (!_isModifyPswd) {
            if (suc) {
                /*!成功*/
                if (_delegate && [_delegate respondsToSelector:@selector(didUnlockSuccessed:)]) {
                    [_delegate didUnlockSuccessed:self];
                }
            }else{
                /*!失败*/
                if (_delegate && [_delegate respondsToSelector:@selector(didUnlockFailed:)]) {
                    [_delegate didUnlockFailed:self];
                }
            }
        }
        
        //是修改密码
        else{
            
            if (!_startModifyPswd) {
                
                if (suc) {
                    _titleLable.text = @"验证成功！请绘制新的解锁图案";
                    _startModifyPswd = YES;
                }else{
                    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:NOTICE_TITLE message:@"解锁图案不正确" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alter show];
                    [alter release];
                }
            }
            
        }
        
        
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //删除之前的所有点
    _len=0;
    flag=1;
    
    for (int i=0; i<9; i++)
    {
        [self unlightCellWithTag:10001+i];
    }
    
    CGPoint point = [[touches anyObject]locationInView:self];

    //转换为该点所在的格子的tag值
    _points[0] = [self convertToTag:point];
    
    if(0==_points[0] && (point.y<originPoint.y || point.y>originPoint.y
                         + (CELLSIZE+GAP)*3)  )
    {
        if (_delegate && [_delegate respondsToSelector:@selector(didTouchBackgroundBegan:)]) {
            [_delegate didTouchBackgroundBegan:self];
        }
        return;
    }
    
    
    if (0 != _points[0])
    {
        _len++;
        [self lightCellWithTag:_points[0]];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self];
    _currentPoint = point; 
    [self setNeedsDisplay];
    
    //转换为该点所在的格子的tag值
    _points[_len] = [self convertToTag:point];
    //不在园内 返回
    if (0 == _points[_len]) {
        return;
    }
    //检测是否已经经过了该点
    for (int i=0; i<_len; i++) {
        if (_points[i]==_points[_len]) {
            return;
        }
    }
    
    
    if(_points[_len]!=_points[_len-1])
    {
        [self lightCellWithTag:_points[_len]];
        _len++;
        NSMutableString *orderString = [NSMutableString stringWithString:@"顺序:"];
        for (int i=0; i<_len; i++) {
            [orderString appendFormat:@"%d",_points[i]%10000 ];
        }
//        _orderLable.text = orderString;
        [self setNeedsDisplay];
    }
}

//将一个点转换为其所在格子的tag
- (int)convertToTag:(CGPoint)aPoint
{
    int x = (aPoint.x - originPoint.x)/(CELLSIZE+GAP);
    int y = (aPoint.y-originPoint.y)/(CELLSIZE+GAP);
    if (y>2)
    {
        y=2;
    }
    else if (y<0)
    {
        y=0;
    }
//    NSLog(@"p.x=%f  p.y=%f  x=%d  y=%d  CELLSIZE=%f n=%f",aPoint.x,aPoint.y,x,y,CELLSIZE,aPoint.y/CELLSIZE);
    int tag=y * 3 + x + 10001;
    UIImageView *imgView = (UIImageView *)[self viewWithTag:tag];
    
    //判断点是否在圆内
    float length = sqrtf( (aPoint.x-imgView.center.x)*(aPoint.x-imgView.center.x) + (aPoint.y-imgView.center.y)*(aPoint.y-imgView.center.y) );
    if (length<=R)
    {
        return tag;
    }
    else
    {
        return 0;
    }
}

//“点亮”指定tag值的格子
- (void)lightCellWithTag:(int)aTag
{
    UIImageView *imgView = (UIImageView *)[self viewWithTag:aTag];
    [imgView setImage:[UIImage imageNamed:@"selected" ]];
}

//“熄灭”指定tag值的格子
- (void)unlightCellWithTag:(int)aTag
{
    UIImageView *imgView = (UIImageView *)[self viewWithTag:aTag];
    [imgView setImage:[UIImage imageNamed:@"unselected"]];
}



@end
