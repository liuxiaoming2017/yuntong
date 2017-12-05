//
//  VideoCell.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoCell.h"
#import "NewsListConfig.h"
#import "NSString+Helper.h"
#import "UIImageView+WebCache.h"

@interface VideoCell()<SBPlayerDelegate>

@property (strong, nonatomic) UIButton *playButton;
@end

@implementation VideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.videoBackView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0)];
        self.videoBackView.userInteractionEnabled=YES;
        [self.contentView addSubview:self.videoBackView];
        
        cellBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.videoBackView.frame.size.width, self.videoBackView.frame.size.height)];
        //cellBgView.frame = CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0);
        cellBgView.contentMode = UIViewContentModeScaleToFill;
        cellBgView.image = [UIImage imageNamed:@"middle_cell_background"];
        [self.videoBackView addSubview:cellBgView];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        self.playButton.frame = CGRectMake(cellBgView.frame.origin.x+cellBgView.frame.size.width/2.0-40, cellBgView.frame.origin.y+cellBgView.frame.size.height/2.0-40, 80, 80);
        [self.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.videoBackView addSubview:self.playButton];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.videoBackView.frame.origin.x+10, self.videoBackView.frame.origin.y+self.videoBackView.frame.size.height+10, self.videoBackView.frame.size.width-20, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = [NewsListConfig sharedListConfig].middleCellTitleTextColor;
        [self.contentView addSubview:titleLabel];
        
        summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y+titleLabel.frame.size.height+10, 80, 20)];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellSummaryFontSize];
        summaryLabel.textColor = [NewsListConfig sharedListConfig].middleCellSummaryTextColor;
        summaryLabel.numberOfLines = 0;
        summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:summaryLabel];
 
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(summaryLabel.frame.origin.x+summaryLabel.frame.size.width, summaryLabel.frame.origin.y, 120, 20)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize];
        dateLabel.textColor = [NewsListConfig sharedListConfig].middleCellDateTextColor;
        dateLabel.numberOfLines = 0;
        dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:dateLabel];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, dateLabel.frame.origin.y+dateLabel.frame.size.height+12, kSWidth, 1)];
        imgV.backgroundColor=[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
        [self.contentView addSubview:imgV];
        
        
    }
    return self;
}

-(void)configBigimageWithArticle:(Article *)article
{
    titleLabel.text=article.title;
    [cellBgView sd_setImageWithURL:[NSURL URLWithString:article.imageUrlBig] placeholderImage:[Global getBgImage43]];
    cellBgView.backgroundColor=[UIColor orangeColor];
    summaryLabel.text = @"20人阅读";
    NSString *dateStr = article.publishTime;
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    dateLabel.text = intervalSinceNow(dateStr);
    
}

-(NSString *)dateToStr:(NSString*)date
{
    if ([NSString isNilOrEmpty:date]) {
        return @"";
    }
    date = [date stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    if (date.length >16) {
        NSString *subStr1 = [date substringWithRange:NSMakeRange(5, 11)];
        return subStr1;
    }
    return @"";
}

- (void)shouldToPlay
{
    [self.videoBackView addSubview:self.player];
    //self.player.frame=CGRectMake(10, 10, kSWidth-20, (kSWidth-20)*9/16.0);
    self.player.frame=CGRectMake(0, 0, kSWidth-20, (kSWidth-20)*9/16.0);
}

- (SBPlayer *)player
{
    if (!_player) {
        _player = [[SBPlayer alloc] initWithUrl:[NSURL URLWithString:self.article.videoUrl]];
        _player.playerSuperView  = self.videoBackView;
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor blackColor];
        //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        _player.mode = SBLayerVideoGravityResizeAspectFill;
        _player.delegate = self;
    }
    return _player;
}

- (void)playVideo:(UIButton *)sender
{
    
    [sender setSelected:!sender.isSelected];
    if ([self.delegate respondsToSelector:@selector(playButtonClick:)]) {
        
        [self.delegate playButtonClick:sender];
    }
}


- (void)setRow:(NSInteger)row
{
    _row = row;
    self.playButton.tag = 788+row;
}

@end
