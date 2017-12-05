//
//  NoNetWorkPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoNetWorkPageController.h"
#import "Utilities.h"
#import "UIButton+Block.h"
#import "UIView+Extention.h"
#import "AppConfig.h"

static NSString *cellStr=@"cellstr1";
@interface NoNetWorkPageController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UIActivityIndicatorView *activity;

@property(nonatomic,strong)UICollectionView *collection;
@property(nonatomic,strong)NSArray *imageArr;


@end

@implementation NoNetWorkPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.view addSubview:self.logoImageView];
//    [self.view addSubview:self.startButton];
    [self.view addSubview:self.activity];
    
    self.imageArr=[NSArray arrayWithObjects:@"guide1",@"guide2",@"guide3", nil];
    [self.view addSubview:self.collection];
    
    NSString *filePath = docDirPathFromURL([AppConfig sharedAppConfig].startConfigUrl);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        [appDelegate() loadFasterStart];
    }
}

-(void)setFinishBlock:(FinishDataBlock)finishedBlock{
    _finishedBlock = finishedBlock;
}

-(void)onWebError:(id)sender{
    if(_finishedBlock){
        _finishedBlock(self);
    }
}

- (UICollectionView *)collection
{
    if(!_collection){
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing=0;
    layout.minimumInteritemSpacing=0;
    layout.itemSize=CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _collection=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
    _collection.delegate=self;
    _collection.dataSource=self;
    
    [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellStr];
    _collection.pagingEnabled=YES;
    _collection.bounces=NO;
    _collection.showsHorizontalScrollIndicator=NO;
    }
    return _collection;
}

- (void)setupBackgroudView {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:launchImage]];
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSWidth/2.f - 173/2.f, kSHeight/2.f-150, 173, 135)];
        _logoImageView.image = [UIImage imageNamed:@"icon_start_logo"];
    }
    return _logoImageView;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] initWithFrame:CGRectMake((kSWidth - 150)/2.f, kSHeight/2.f+150, 150, 34)];
        _startButton.backgroundColor = [UIColor colorWithRed:19/255.f green:183/255.f blue:246/255.f alpha:1];
        [_startButton setTitle:@"点我 即刻开启!" forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _startButton.layer.cornerRadius = 17;
        _startButton.layer.masksToBounds = YES;
        __weak __typeof (self)weakSelf = self;
        [_startButton addAction:^(UIButton *btn) {
            [weakSelf.activity startAnimating];
            [appDelegate() loadFasterStart];
        }];
    }
    return _startButton;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_activity hidesWhenStopped];
        [_activity setCenter:self.view.center];
        _activity.y = _activity.y+50;
        [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        _activity.color=[UIColor blackColor];

    }
    return _activity;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellStr forIndexPath:indexPath];
    UIImageView *imageV=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageV.image=[UIImage imageNamed:self.imageArr[indexPath.row]];
    
    [cell.contentView addSubview:imageV];
    return cell;
}

- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page=(NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width+0.5)%5;
    if(page==self.imageArr.count-1){
        [self.activity startAnimating];
        [appDelegate() loadFasterStart];
    }
    
}


@end
