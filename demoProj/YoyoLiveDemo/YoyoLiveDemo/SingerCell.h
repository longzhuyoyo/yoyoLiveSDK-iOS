//
//  HomeCategorySingerViewNew.h
//  Yoyo_new
//
//  Created by kaso on 30/8/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *liveTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *liveStatusLabel;
@property (nonatomic, weak) IBOutlet UIImageView *singerImage;
@property (nonatomic, weak) IBOutlet UILabel *singerName;

-(void)setData:(id) data;

@end
