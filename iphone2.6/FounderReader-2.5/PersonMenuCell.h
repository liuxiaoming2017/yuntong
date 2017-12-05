//
//  PersonMenuCell.h
//  FounderReader-2.5
//
//  Created by mac on 2017/6/19.
//
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "PersonMenu.h"
@interface PersonMenuCell : UITableViewCell
@property (nonatomic,strong)UIImageView * headIV;
@property (nonatomic,strong)UILabel * nameLabel;
@property (nonatomic,strong)UIImageView * moreIV;
@property (nonatomic,strong)UIView* lineView;
@property (nonatomic,strong)PersonMenu * menu;
+(instancetype)creatPersonalMenuCellWithTableView:(UITableView*)tableView;
@end
