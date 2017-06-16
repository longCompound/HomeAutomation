//
//  ZGZDDetailCell.m
//  ZgSafe
//
//  Created by Mark on 2017/6/16.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGZDDetailCell.h"

static UILabel * caculateLabel;

@interface ZGZDDetailCell () {
    __weak IBOutlet UILabel *_infoLabel;
}

@end

@implementation ZGZDDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _infoLabel.frame = CGRectMake(20, 10, self.width - 40, self.height - 20);
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _infoLabel.frame = CGRectMake(20, 10, self.width - 40, self.height - 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfoDic:(NSDictionary *)infoDic
{
    _infoDic = infoDic;
    if (infoDic && [infoDic isKindOfClass:[NSDictionary class]]) {
        _infoLabel.text = [[self class] getInfoDescription:_infoDic];
    }
}

+ (CGFloat)caculateHeight:(NSDictionary *)infoDic
{
    if (!infoDic || ![infoDic isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    if (!caculateLabel) {
        caculateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 18)];
        caculateLabel.font = [UIFont systemFontOfSize:15];
        caculateLabel.numberOfLines = 0;
    }
    caculateLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 18);
    NSString * content = [self getInfoDescription:infoDic];
    caculateLabel.text = content;
    [caculateLabel sizeToFit];
    return caculateLabel.height + 20;
}

+ (NSString *)getInfoDescription:(NSDictionary *)infoDic
{
    NSString * ZDName = infoDic[@"ZDName"];
    NSString * ZDStatus = infoDic[@"ZDStatus"];
    NSString * ZDMoney = infoDic[@"ZDMoney"];
    NSString * CreateTime = infoDic[@"CreateTime"];
    NSString * PayTime = infoDic[@"PayTime"];
    NSMutableString *content = [[NSMutableString alloc] initWithString:ZDName];
    [content appendFormat:@" : %@",ZDStatus];
    if (ZDMoney && ZDMoney.length > 0) {
        [content appendFormat:@"\n账单金额 : %@",ZDMoney];
        if (CreateTime && CreateTime.length > 0) {
            [content appendFormat:@"\n出账日期 : %@",CreateTime];
        } else {
            [content appendString:@"\n出账日期 : %@"];
        }
        if (PayTime && PayTime.length > 0) {
            [content appendFormat:@"\n付款日期 : %@",PayTime];
        } else {
            [content appendString:@"\n付款日期 : 未付款"];
        }
    }
    return content;
}

@end
