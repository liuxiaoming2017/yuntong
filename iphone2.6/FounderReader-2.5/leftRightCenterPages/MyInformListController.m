//
//  MyInformListController.m
//  FounderReader-2.5
//
//  Created by ld on 15-1-7.
//
//

#import "MyInformListController.h"
#import "MyInform.h"
#import "NSString+Helper.h"
#import "MoreCell.h"
#import "UIDevice-Reachability.h"
#import "InformPageController.h"
#import "NSArray+Plist.h"
#import "InformPageController.h"
#import "InformAttachment.h"
#import "AppStartInfo.h"

#define informCount 20

@interface MyInformListController ()
{
    NSInteger hasLocal;
}

//爆料

@property(nonatomic,retain) NSArray *informAttacnmentArry;
@property(nonatomic,retain) NSDictionary *localInformDic;
@property(nonatomic,retain) NSArray *localInformArry;

@end

@implementation MyInformListController
@synthesize informAttacnmentArry;
@synthesize localInformArry,localInformDic;

-(void)dealloc
{
    self.informAttacnmentArry = nil;
    self.localInformDic = nil;
    self.localInformArry = nil;
    
//    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor whiteColor];
    
    [self dataFromLocal];
	[self updateNoDataLabel];
    
    [self rightPageNavTopButtons];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self titleLableWithTitle:@"我的爆料"];
    [self downLoadData];
    [self hasLocalInform];
}

-(void)goRightPageBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)sender heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row &&  hasLocal )
    {
        [self gotoInformPage:nil];
    }
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (0 == indexPath.row &&  hasLocal )
   {
       return indexPath;
   }
    return nil;
}
#pragma mark - table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.dataArray.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row &&  hasLocal)
    {
       MiddleCell *localCell = [tableView dequeueReusableCellWithIdentifier:@"localInformMiddleCell"];
        
        if (!localCell){
            localCell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"localInformMiddleCell"];

        }
        NSString *title = [self.localInformDic objectForKey:kTitle_inform];
        if (!title) {
            title = @"";
        }
        NSDate *date = [self.localInformDic objectForKey:kSaveDate_inform];
        NSString *dateStr = [NSString stringFromDate:date withFormate:@"yyyy-MM-dd"];
        [localCell configMyLocalInformCellWithTitle:title thumbnailImage:[self localInformImage] status:@"未提交" date:dateStr];
       
        localCell.selectedBackgroundView = nil;
        localCell.backgroundColor = [UIColor whiteColor];
        return localCell;
    }
    else if ((indexPath.row == self.dataArray.count &&  !hasLocal)||(indexPath.row == self.dataArray.count+1 && hasLocal))
    {
        MoreCell *moreCell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (!moreCell)
        {
            moreCell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
            moreCell.contentView.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
        }
        
        moreCell.tag = 200;
        [moreCell configWithTitle:@"" summary:@"" date:@""  thumbnailUrl:@"" columnId:0];
        return moreCell;
    }else
    {
        TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"InformMiddleCell"];
        
        if (!cell){
            cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InformMiddleCell"];
            
        }
        
        MyInform *inform = nil;
        if (hasLocal) {
            inform = [self.dataArray objectAtIndex:indexPath.row-1];
        }else
        {
            inform = [self.dataArray objectAtIndex:indexPath.row];
        }
        NSString *imageUrl = @"";
        self.informAttacnmentArry = inform.attachments;
        if (self.informAttacnmentArry.count) {
            imageUrl = [self thumbnailImageUrl];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[inform.createTime doubleValue]/1000];
        NSString *dateStr = [NSString stringFromDate:date withFormate:@"yyyy-MM-dd"];
        [cell configMyInformCellWithTitle:inform.title thumbnailUrl:imageUrl status:@"已提交" date:dateStr];
        
        cell.selectedBackgroundView = nil;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
}

- (void)downLoadData
{
    [super downLoadData];
    NSString *userid = [Global userId];
    if (!userid.length) {
        return;
    }
    NSString *myInformUrl = [NSString stringWithFormat:@"%@getMyInformInfos?userId=%@&count=%d&lastId=0&rowNumber=0", [AppStartInfo sharedAppStartInfo].disclosureServer,userid,informCount];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myInformUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request.ifCache = YES;
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        
        NSArray *array = [dic objectForKey:@"disclosures"];
        
        if ([array isKindOfClass:[NSArray class]]) {
            if (array.count) {
                self.dataArray = [MyInform myInformsFromArray:array];
            }
        }
        hasMore = [[dic objectForKey:@"hasMore"] boolValue];
        [self downLoadDataFinished];
        
        if (self.dataArray.count) {
            [self headerView];
        }

    }];
    
    [request setFailedBlock:^(NSError *error) {
        [self downLoadDataFail];
        
    }];
    
    [request startAsynchronous];
}


-(void)dataFromLocal
{
    //我的爆料
    NSString *userid = [Global userId];
    if (!userid.length) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@getMyInformInfos?userId=%@&count=%d&lastId=0&rowNumber=0", [AppStartInfo sharedAppStartInfo].disclosureServer,userid,informCount];
    NSData *data = [NSData dataWithContentsOfFile:cachePathFromURL(urlString)];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
    NSArray *array = [dic objectForKey:@"disclosures"];
    if ([array isKindOfClass:[NSNull class]]) {
        
    }else{
        if (array.count) {
            self.dataArray = [MyInform myInformsFromArray:array];
        }
    }
    hasMore = [[dic objectForKey:@"hasMore"] boolValue];
    [self.basicTableView reloadData];
}

-(NSString *)thumbnailImageUrl
{
    NSString *imageurl = @"";
    for (NSDictionary *dic in self.informAttacnmentArry) {
        imageurl = [dic objectForKey:@"attachmentUrl"];
        if ([imageurl hasSuffix:@".jpg"] ||[imageurl hasSuffix:@".jpeg"]) {
            imageurl = [imageurl stringByAppendingString:@"&size=2"];
            return imageurl;
        }
    }
    return imageurl;
}

- (void)downLoadMoreData
{
    [super downLoadMoreData];
    
    MyInform *inform = [self.dataArray lastObject];
    
    NSString *userid = [Global userId];
    if (!userid.length) {
        return;
    }
     NSString *myInformUrl = [NSString stringWithFormat:@"%@getMyInformInfos?userId=%@&count=%d&lastId=%@&rowNumber=%d", [AppStartInfo sharedAppStartInfo].disclosureServer,userid,informCount,inform.informId,self.dataArray.count-1];
    FileLoader *request = [FileLoader fileLoaderWithUrl:[myInformUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request.ifCache = YES;
    [request setCompletionBlock:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        NSArray *arry = [dic objectForKey:@"disclosures"];
        if ([arry isKindOfClass:[NSArray class]]) {
            
            if (arry.count) {
                NSArray *informArray = [MyInform myInformsFromArray:arry];
                NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.dataArray];
                [tmpArray addObjectsFromArray:informArray];
                self.dataArray = tmpArray;
            }
        }
        hasMore = [[dic objectForKey:@"hasMore"] boolValue];
        [self downLoadMoreDataFinished];
        
    }];
    
    [request setFailedBlock:^(NSError *error) {
        [self downLoadMoreDataFail];
        
    }];
    
    [request startAsynchronous];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = self.dataArray.count;
    if (hasMore) {
        ++count;
    }
    
    if (indexPath.row >= count-1) {
        
        if (hasMore)
        {
            if (![UIDevice networkAvailable]) {
                [self noNetworkAvailable];
                return;
            }
            MoreCell *cell = (MoreCell *)[self.basicTableView viewWithTag:200];
            [cell showIndicator];
            [self downLoadMoreData];
        }
    }
}

-(void)updateNoDataLabel
{
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"您还没有任何爆料哦！"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,str.length)];
    
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"我要爆料>>>"];
    [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,str2.length)];
    
    [str appendAttributedString:str2];
    self.noDataLabel.attributedText = str;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoInformPage:)];
    
    [self.noDataLabel addGestureRecognizer:recognizer];
    self.noDataLabel.userInteractionEnabled = YES;
 
}

-(void)gotoInformPage:(UITapGestureRecognizer *)tapGestureRecognizer
{
    
    InformPageController *controller = [[InformPageController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
 
}


-(void)headerView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.view.bounds.size.width-40, 35)];
    label.text = @"我要爆个料";
    label.font = [UIFont boldSystemFontOfSize:16];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"informHeader.jpg"]];
    image.frame = CGRectMake(0, 0, self.view.bounds.size.width, 41);
    [image addSubview:label];
 
   
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoInformPage:)];
    
    [label addGestureRecognizer:recognizer];
    label.userInteractionEnabled = YES;
    image.userInteractionEnabled = YES;
  
    
    self.basicTableView.tableHeaderView = image;
 
}

-(NSInteger )hasLocalInform
{
    NSString *dicFilePath = [self textLocalPath];
    NSString *arryFilePath = [self attachmentLocalPath];
    if (isFileExists(dicFilePath)) {
        self.localInformDic = [NSDictionary dictionaryWithContentsOfFile:dicFilePath];
        if ([self.localInformDic isKindOfClass:[NSNull class]] ) {
            hasLocal = 0;
            return hasLocal;
        }
        if (self.localInformDic.count) {
            hasLocal = 1;
        }
        else{
            hasLocal = 0;
        }
    }else if (isFileExists(arryFilePath)){
        NSArray *ar = [NSArray readFromPlistFile:arryFilePath];
        if ([ar isKindOfClass: [NSNull class]]) {
            hasLocal = 0;
            return hasLocal;
        }
        if (ar.count) {
            self.localInformArry = [NSMutableArray arrayWithArray:ar];
            hasLocal = 1;
        }
        else{
            hasLocal = 0;
        }
    }
    else{
        hasLocal = 0;
    }
    return hasLocal;
}

-(NSString *)attachmentLocalPath
{
    NSString *userId = [Global userId];
    if ([NSString isNilOrEmpty:userId]) {
        return @"";
    }
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@.plist",kSaveInformAttachmentsFileName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}

-(NSString *)textLocalPath
{
    NSString *userId = [Global userId];
    if ([NSString isNilOrEmpty:userId]) {
        return @"";
    }
    NSString *lastComponent = [NSString stringWithFormat:@"%@%@",kSaveInformTextFileName,userId];
    NSString *attachmentFilePath = [cacheDirPath() stringByAppendingPathComponent:lastComponent];
    return attachmentFilePath;
}
-(UIImage *)localInformImage
{
    for (InformAttachment *iAtt in self.localInformArry) {
        if ([iAtt.fileName isEqualToString:@"image.jpg"]) {
            UIImage *image = [UIImage imageWithData:iAtt.data];
            return image;
        }
    }
    return nil;
}
@end
