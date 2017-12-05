//
//  SetupVoicePlayerPageController.m
//  FounderReader-2.5
//
//  Created by Julian on 16/8/12.
//
//

#import "SetupVoicePlayerPageController.h"
#import "ASValueTrackingSlider.h"
#import "ColumnBarConfig.h"
#import "UIView+Extention.h"
#import "FontSettingsController.h"
#import "NewsListConfig.h"
#import "ColorStyleConfig.h"

#define kRowCount 4

@interface SetupVoicePlayerPageController ()<ASValueTrackingSliderDataSource, ASValueTrackingSliderDelegate>
{
    NSDictionary *_voiceDict;
    
    NSArray *_voiceAttributeArr;
}
@end

@implementation SetupVoicePlayerPageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _voiceDict = @{
                  @"xiaoyan" : NSLocalizedString(@"优美女音普通话",nil),
                  @"xiaoyu" : NSLocalizedString(@"浑厚男音普通话",nil),
                  @"vixm" : NSLocalizedString(@"标准女音粤语",nil),
                  @"vixl" : NSLocalizedString(@"标准女音台湾话",nil)
                  };
    
    
    _voiceAttributeArr = @[@"VoiceSpeed", @"VoiceTone",@"VoiceVolume"];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = UIColorFromString(@"237,237,237");
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goLastPageBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    navTitleLabel.text = NSLocalizedString(@"语音播报设置",nil);
    navTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.textColor = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    self.navigationItem.titleView = navTitleLabel;
    
}

-(void)goLastPageBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*kHScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //无需复用
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    UIView *selectBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, cell.contentView.height)];
    selectBgView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectBgView;
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 49*kHScale, kSWidth, 1*kHScale)];
    lineView.backgroundColor = UIColorFromString(@"237,237,237");
    [cell.contentView addSubview:lineView];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 60, 50*kHScale)];
    contentLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].leftUserNameFontSize-2];
    [cell.contentView addSubview:contentLabel];
    NSArray *voiceTextArr = @[@"播报员", @"语速", @"音调", @"音量"];
    contentLabel.text = voiceTextArr[indexPath.row];
    
    if (indexPath.row == 0) {
        UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(kSWidth - 30, (50*kHScale - 26)/2.0f, 26, 26)];
        backImage.image = [UIImage imageNamed:@"setRight"];
        [cell.contentView addSubview:backImage];
        
        NSString *selectAnnouncerKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"VoiceAnnouncer"];
        NSString *selectAnnouncer = _voiceDict[selectAnnouncerKey];
        //计算尺寸
         NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName,nil];
        CGSize announcerSize = [selectAnnouncer boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        UILabel *voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(backImage.x-announcerSize.width, (50*kHScale - announcerSize.height)/2.0f, announcerSize.width, announcerSize.height)];
        voiceLabel.text = selectAnnouncer;
        voiceLabel.textColor = UIColorFromString(@"150,150,150");
        voiceLabel.backgroundColor = [UIColor clearColor];
    
        [cell.contentView addSubview:voiceLabel];
    }else {
        
        ASValueTrackingSlider *slider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(70, 10*kHScale, kSWidth - 70 - 15, 30*kHScale)];
        UIImage *sliderImage = [self originImage:[UIImage imageNamed:@"setvoice_slider"] scaleToSize:CGSizeMake(28, 28)];
        [slider setThumbImage:sliderImage forState:UIControlStateNormal];
        slider.maximumValue = 100.0;
        slider.value = [[NSUserDefaults standardUserDefaults] integerForKey:_voiceAttributeArr[indexPath.row - 1]];
        slider.popUpViewCornerRadius = 3.0;
        [slider setMaxFractionDigitsDisplayed:0];
        slider.popUpViewColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        slider.font = [UIFont fontWithName:@"GillSans-Bold" size:17];
        slider.textColor = [UIColor whiteColor];
//        slider.popUpViewWidthPaddingFactor = 1.7;
//        slider.popUpViewHeightPaddingFactor = 1;
//        slider.dataSource = self;
        slider.delegate = self;
        [cell.contentView addSubview:slider];
        cell.tag = indexPath.row;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        FontSettingsController *controller = [[FontSettingsController alloc] init];
        controller.isSetupVoice = YES;
        [self.navigationController pushViewController:controller animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - ASValueTrackingSliderDataSource
- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    value = roundf(value);
    NSString *s;
    if (value < -10.0) {
        s = @"❄️Brrr!⛄️";
    } else if (value > 29.0 && value < 50.0) {
        s = [NSString stringWithFormat:@"😎 %@ 😎", [slider.numberFormatter stringFromNumber:@(value)]];
    } else if (value >= 50.0) {
        s = @"I’m Melting!";
    }
    return s;
}

#pragma mark - ASValueTrackingSliderDelegate
- (void)sliderWillDisplayPopUpView:(ASValueTrackingSlider *)slider;
{
    UITableViewCell *cell = (UITableViewCell *)slider.superview.superview;
    cell.selected = YES;
    for (NSInteger i = 1; i < kRowCount; i++) {
        UITableViewCell *rowCell = (UITableViewCell *)[self.view viewWithTag:i];
        if (cell != rowCell) {
            rowCell.selected = NO;
        }
    }
}

- (void)sliderDidHidePopUpView:(ASValueTrackingSlider *)slider
{
    UITableViewCell *cell = (UITableViewCell *)slider.superview.superview;
    [[NSUserDefaults standardUserDefaults] setInteger:slider.value forKey:_voiceAttributeArr[cell.tag - 1]];
}

- (UIImage *) originImage:(UIImage*)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

@end
