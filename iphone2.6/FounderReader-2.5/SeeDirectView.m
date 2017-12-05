//
//  SeeDirectView.m
//  FounderReader-2.5
//
//  Created by lx on 15/8/18.
//
//

#import "SeeDirectView.h"
#import "SeeDirectTableViewCell.h"
#import "DirectFram.h"
#import "SeeMethod.h"
#import "UIView+Extention.h"
#import "SeeViewmodel.h"
#import "TopDiscussmodel.h"
#import "CommentConfig.h"
#import "shareCustomView.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "MoreCell.h"
#import "UIDevice-Reachability.h"
#import "YXLoginViewController.h"
#import "CommentViewControllerGuo.h"
#import "UIImageView+WebCache.h"

#define maxHeightForTitle 70
@interface SeeDirectView()
{
    BOOL _reloading;
}
@property (nonatomic, retain) NSMutableArray *dataArr;
@property (nonatomic, retain) NSMutableArray *livewArr;
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *footView;
@property (nonatomic, retain) UIView *longLine;
@property (nonatomic, retain) NSMutableArray *topArray;
@property (nonatomic, strong) NSString *msg;
@end


@implementation SeeDirectView
{
    NSString *_title;
    NSString *_picUrl;
    NSString *_content;
}
@synthesize arr,mainModel, column;
@synthesize topView,directtableview,livewArr,dataArr,footView,topArray,longLine;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        livewArr = [[NSMutableArray alloc] init];
        dataArr = [[NSMutableArray alloc] init];
        topArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}
// 不用撤销了
-(void)creatTopView:(TopDiscussmodel *)topmodel
{
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/3)];
    topView.tag = 667;
    
    self.topView.userInteractionEnabled = YES;
    
    ImageViewCf *topImageView = [[ImageViewCf alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSWidth/3)];
    topImageView.tag = 661;
    [topImageView sd_setImageWithURL:[NSURL URLWithString:[topmodel.picImage stringByAppendingString:@"@!md31"]] placeholderImage:[Global getBgImage31]];
    UILabel *topSummaryLabel = [[UILabel alloc] init]; //摘要
    topSummaryLabel.tag = 662;
    topSummaryLabel.font = [UIFont fontWithName:[Global fontName] size:(13/320.0)*kSWidth];
    topSummaryLabel.textColor = [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1];
    topSummaryLabel.numberOfLines = 0;
    topSummaryLabel.text = topmodel.content;
    CGFloat height = [self getZSCTextHight:topSummaryLabel.text andWidth:kSWidth-20 andTextFontSize:(13/320.0)*kSWidth];
    if (height > maxHeightForTitle) {
        height = maxHeightForTitle;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 5*kScale;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont fontWithName:[Global fontName] size:(13/320.0)*kSWidth],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    if (!topSummaryLabel.text) {
        topSummaryLabel.text = @"";//设置为空
    }
    NSAttributedString *atrStr = [[NSAttributedString alloc] initWithString:topSummaryLabel.text attributes:attributes];
    topSummaryLabel.attributedText = atrStr;
    
    topSummaryLabel.frame = CGRectMake(10, kSWidth/3, kSWidth-20, height*1.5+10);
    topView.frame = CGRectMake(0, 0, kSWidth, CGRectGetMaxY(topSummaryLabel.frame));
    [self.topView addSubview:topImageView]; // 直播图
    [self.topView addSubview:topSummaryLabel]; // 简介
   // [FounderEventRequest articleviewDateAnaly:self.aid column:self.column.fullColumn];
}

//直播下面的解析
-(void)loadLiveDatasource
{
    //新空云新接口
    //http://h5.newaircloud.com/api/getLiveList?sid=xkycs&id=13314&lastFileID=0&rowNumber=0
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLiveList?sid=%@&id=%d&lastFileID=0&rowNumber=0",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.fileid];
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        
        self.msg = [dataArray valueForKey:@"msg"];
        NSArray *list = [dataArray valueForKey:@"list"];
        hasMore = list.count > 0 ?YES : NO;
        if (!hasMore) {
            longLine.hidden = YES;
        }
        [self.livewArr removeAllObjects];
        for (NSDictionary *dict in list) {
            TopDiscussmodel *newTop = [TopDiscussmodel seeWithDict:dict];
            LiveFrame *liveframe  = [[LiveFrame alloc]init];
            liveframe.topModel = newTop;
            [self.livewArr addObject:liveframe];
            
        }
        NSDictionary *main = [dataArray valueForKey:@"main"];
        
//        NSArray *attachments = [main valueForKey:@"attachments"];
//        _title = [main valueForKey:@"title"];
//        _content = [main valueForKey:@"content"];
//        _picUrl = [[attachments lastObject] objectForKey:@"url"];
        
        TopDiscussmodel *descripetion = [TopDiscussmodel topSeeDirectFromDiction:main];
        
        [self.topArray addObject:descripetion];
        
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.directtableview];
        _reloading = NO;
        [self.directtableview reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        [Global hideTip];
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
}
- (CGFloat)getZSCTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontSize:(NSInteger)fontSize
{
    CGSize size = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:fontSize]};
    size = [textStr boundingRectWithSize:CGSizeMake(width, 1000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size.height;
}
//加载更多的直播评论的数据
-(void)loadLiveMoresource:(NSInteger)startCount
{
    LiveFrame *livewf = [self.livewArr lastObject];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLiveList?sid=%@&id=%d&lastFileID=%d&rowNumber=%ld",[AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid, self.fileid, livewf.topModel.fileID, (long)startCount];
    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSArray *list = [dataArray valueForKey:@"list"];
        if (list.count > 0) {
            hasMore = YES;
        }else{
            hasMore = NO;
        }
        
        for (NSDictionary *dict in list) {
            TopDiscussmodel *newTop = [TopDiscussmodel seeWithDict:dict];
            LiveFrame *liveframe1  = [[LiveFrame alloc]init];
            liveframe1.topModel = newTop;
            [self.livewArr addObject:liveframe1];
            
        }
        
        _reloading = NO;
        [self.directtableview reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        _reloading =NO;
        [Global showTipNoNetWork];
    }];
    
    [request startAsynchronous];
    
}

-(void)creatDirect
{
    [self loadLiveDatasource];

    directtableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, self.height)];
    longLine = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 1, 1500)];
    longLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [directtableview addSubview:longLine];
    [directtableview sendSubviewToBack:longLine];
    
    self.directtableview.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];

    self.directtableview.dataSource=self;
    self.directtableview.delegate=self;
    self.directtableview.separatorStyle = 0;
    [self addSubview:self.directtableview];
    _reloading = NO;

    if (_refreshHeaderView == nil)
    {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.directtableview.bounds.size.height, self.frame.size.width, self.directtableview.bounds.size.height)];
        _refreshHeaderView.delegate = self;
       
        [self.directtableview addSubview:_refreshHeaderView];
        
        [_refreshHeaderView refreshLastUpdatedDate];
        
    }
}

// 一滑动就顶上去
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
// 一松手 顶上去
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseUpAndDownView" object:nil];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    
    _reloading = YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTableViewDataSource) userInfo:nil repeats:NO];
}

//用来加载网络数据
- (void)reloadTableViewDataSource
{
    [self loadLiveDatasource];
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (200 == cell.tag){
        if (![UIDevice networkAvailable]) {
            return;
        }
        if ([cell respondsToSelector:@selector(showIndicator)]) {
            [(MoreCell *)cell showIndicator];
        }
        [self loadLiveMoresource:self.livewArr.count];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.livewArr.count+hasMore;
    
}
//根据model 的数据进行 视频和图片的判断
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.livewArr.count) {
        MoreCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (cell == nil)
            cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        cell.tag = 200;
        [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
        return cell;
    }
    //直播评论的视频
    LiveFrame *livewf = self.livewArr[indexPath.row];
    SeeDirectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoAndImageCell"];
    if (!cell) {
        NSInteger indexrow = indexPath.row;
        cell = [[SeeDirectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil indexRow:indexrow andliveFrame:livewf];
        
    }
    cell.backgroundColor = [UIColor colorWithRed:0xED/255.0 green:0xED/255.0 blue:0xED/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.playerButtonClickedBlock = ^(NSURL *urlStr) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.playerButtonClickedBlock) {
            strongSelf.playerButtonClickedBlock(urlStr);
        }
    };
    [cell directUIFrame:livewf andReuseidentID:nil frames:self.livewArr andIndexpath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.livewArr.count == indexPath.row)
    {
        return 45;
    }else
    {
        return [self.livewArr[indexPath.row] cellHight] +10;
    }
    
}
- (void)shareClick{
    
    [self shareAllButtonClickHandler:nil];
    
}
- (void)shareAllButtonClickHandler:(UIButton *)sender
{
    NSString *url = nil;
    if (self.aid != 0) {//40327
        url = [NSString stringWithFormat:@"%@/live_detail?newsid=%d_%@&app=1",[AppConfig sharedAppConfig].serverIf,self.aid,[AppConfig sharedAppConfig].sid];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@/live_detail?cid=%d&sc=%@&app=1",[AppConfig sharedAppConfig].serverIf,self.fileid,[AppConfig sharedAppConfig].sid];
    }
    
    [shareCustomView shareWithContent:[self newsContent] image:[self newsImage] title:[self newsTitle] url:url type:0 completion:^(NSString *resoultJson){
//        [FounderEventRequest founderEventShareAppinit:self.aid];
//        [FounderEventRequest shareDateAnaly:self.aid column:self.column.fullColumn];
    }];
}
- (id)newsTitle{
    TopDiscussmodel *shareModel = [self.topArray firstObject];
//    if ([self.msg isEqualToString:@"没有相关数据"]) {
//    }
    if ([NSString isNilOrEmpty:shareModel.title]) {
        return self.article.title;;
    }
    else{
        return shareModel.title;
    }
}
- (id)newsContent{
    TopDiscussmodel *shareModel = [self.topArray firstObject];
    if ([NSString isNilOrEmpty:shareModel.content]) {
        return @"";
    }
    else{
        return shareModel.content;
    }
}
- (id)newsImage{
    TopDiscussmodel *shareModel = [self.topArray firstObject];
    if ([NSString isNilOrEmpty:shareModel.picImage]) {
        return [Global getAppIcon];
    }
    else{
        return shareModel.picImage;
    }
}

- (void)addFootView{
    footView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-45, kSWidth, 45)];
    footView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    UIView *topviewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 0.4)];
    if (IS_IPHONE_6P) {
        topviewLine.frame = CGRectMake(0, 0, kSWidth, 0.6);
    }
    topviewLine.alpha = 0.6;
    topviewLine.backgroundColor = [UIColor grayColor];
    [footView addSubview:topviewLine];
    
    
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    
    UIButton *bg = [UIButton buttonWithType:UIButtonTypeCustom];
    [bg setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    if (IS_IPHONE_6)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(32, 8, 290, 30);
        
    }else if (IS_IPHONE_6P)
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(34, 9, 330, 30);
        [bg setImage:[UIImage imageNamed:@"ditect_write6p"] forState:UIControlStateNormal];
        
    }else
    {
        backBtn.frame = CGRectMake(5, 12, 23, 23);
        bg.frame = CGRectMake(30, 8, 240, 30);
    }
    
    [backBtn setImage:[UIImage imageNamed:@"btn-comment-back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick1:) forControlEvents:UIControlEventTouchUpInside];
    [bg addTarget:self action:@selector(commentItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *shareBtn = [SeeMethod newButtonWithFrame:CGRectMake(kSWidth-43, 8, 32, 32) type:UIButtonTypeSystem title:nil target:self UIImage:@"toolbar_share_new" andAction:@selector(shareClick)];
    [footView addSubview:backBtn];
    [footView addSubview:shareBtn];
    [footView addSubview:bg];
    
    [self addSubview:footView];
}
- (void)backClick1:(UIButton *)btn{
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    [controller rightPageNavTopButtons];
    [self.viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:^{
    }];
}

- (void)commentItemClicked:(id)sender
{
    [self writeComment];
    
}

- (void)writeComment
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    
    self.block();
}
@end
