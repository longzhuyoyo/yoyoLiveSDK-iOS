//
//  HomeCategorySingerViewNew.m
//  Yoyo_new
//
//  Created by kaso on 30/8/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "SingerCell.h"
#import "YoyoApi.h"
#import "UIImageView+WebCache.h"

@implementation SingerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

-(void)setData:(id)data{
    YoyoSingerDetailRecord *singerRecord = (YoyoSingerDetailRecord *)data;
    //直播状态
    self.liveStatusLabel.hidden = NO;
    if (singerRecord.isLive) {
        self.liveStatusLabel.text = @"直播";
    } else{
        self.liveStatusLabel.hidden = YES;
    }
    
    //主播大图
    [self.singerImage sd_setImageWithURL:[NSURL URLWithString:[YoyoApi getFullImageUrl:singerRecord.cover]]];
    self.singerImage.layer.masksToBounds = YES;
    
    //主播名
    self.singerName.text = [NSString stringWithFormat:@"%@|lv.%ld|观众数:%ld", singerRecord.alias, singerRecord.singerLevel, singerRecord.memberNum];
    
    self.liveTitleLabel.text = singerRecord.title;
}

@end
