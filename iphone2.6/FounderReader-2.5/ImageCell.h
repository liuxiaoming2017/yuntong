//
//  ImageCell.h
//  FounderReader-2.5
//
//  Created by sa on 15-1-5.
//
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import "ImageViewCf.h"

@interface ImageCell : TableViewCell {
    ImageViewCf *thumbnail;
    UILabel   *titleLabel;
    UILabel   *summaryLabel;
    UILabel *dateLabel;
    UIImageView *cellBgView;
    UIImageView *thumbnailbackground;
}

- (void)showThumbnail:(BOOL)show;
-(void)configimageCellWithArticle:(Article *)article;

@end