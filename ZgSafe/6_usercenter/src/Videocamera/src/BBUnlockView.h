//
//  CellView.h
//  ScreenUnLcoked
//
//  Created by 020 on 13-7-8.
//  Copyright (c) 2013年 赵 文双. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PSWD_KEY @"unlock_pswd"
#define CELLSIZE       63.0f
#define GAP             15.0f
#define originPoint CGPointMake((self.frame.size.width-CELLSIZE*3-GAP*2)/2.0f, (self.frame.size.height-CELLSIZE*3-GAP*2)/2.0)//左上角的格子的origin点

#define R 20.0f //吸附半径
@class BBUnlockView;
@protocol BBUnlockViewDelegate <NSObject>

@optional
- (void)didUnlockSuccessed:(BBUnlockView *)unlockView;
- (void)didUnlockFailed:(BBUnlockView *)unlockView ;
- (void)didSetPasswordCompleted:(BBUnlockView *)unlockView ;
- (void)didTouchBackgroundBegan:(BBUnlockView *)unlockView ;

@end

@interface BBUnlockView : UIView
{
    int _points[200];//划过的点的view的tag值
    int _len;//划过的点的个数
    int flag;//1:重绘连线 2:清空连线
    int _password[9];//开锁密码
    int _lenPswd;//密码长度
    CGPoint _currentPoint;
//    UILabel *_orderLable;//显示连接顺序
    UILabel *_titleLable;
    BOOL _startModifyPswd;
}


@property (nonatomic,assign)id<BBUnlockViewDelegate>delegate;
//是否为修改密码状态
@property (assign,nonatomic)BOOL isModifyPswd;
//将一个点转换为其所在格子的tag
- (int)convertToTag:(CGPoint)aPoint;
//“点亮”指定tag值的格子
- (void)lightCellWithTag:(int)aTag;
//“熄灭”指定tag值的格子
- (void)unlightCellWithTag:(int)aTag;
- (void)getPswd;



@end



