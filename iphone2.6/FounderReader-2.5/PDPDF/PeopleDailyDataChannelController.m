//
//  PeopleDailyDataChannelController.m
//  FounderReader-2.5
//
//  Created by ld on 14-3-18.
//
//

#import "PeopleDailyDataChannelController.h"
#import "ColumnBarConfig.h"
#import "AppStartInfo.h"
#import "NSString+Helper.h"
#import "FileLoader.h"
#import "PDFpaper.h"
#import "AppConfig.h"
#import "PDFPageDataModel.h"

@interface PeopleDailyDataChannelController ()
{
    UILabel *_headerLabel;
}

@end

@implementation PeopleDailyDataChannelController
@synthesize pdfTableView, selectedDate;
@synthesize paperArray, allPages, pagesWithArticle;

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    if (!self.pdfTableView) {
        [self setupPDFTableView];
    }
    
    [self loadPapers];
    self.pagesWithArticle = [[NSMutableArray alloc] init];
}

-(void)setupPDFTableView
{
    pdfTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];

    pdfTableView.frame = CGRectMake(0, 0, kSWidth, self.view.bounds.size.height - kNavBarHeight - kTabBarHeight);
    
    self.pdfTableView.dataSource = self;
    self.pdfTableView.delegate = self;
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kSWidth, 32)];
    //绘制cell分界线占满整个cell宽度 无效
    self.pdfTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //剔除tableview出数据之前现满屏空白cell
    [self.pdfTableView setTableFooterView:[[UIView alloc] init]];
    self.pdfTableView.tableHeaderView = _headerLabel;
    [self.view addSubview:self.pdfTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)loadPapers
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getPapers?sid=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid];

    FileLoader *request = [FileLoader fileLoaderWithUrl:urlString];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if (dataDic) {
            NSArray *Arry = [dataDic objectForKey:@"papers"];
            if (Arry.count) {
                self.paperArray = [PDFpaper papersFromArray:Arry];
                [self loadPapersFinished];
            }
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        
    }];
    [request startAsynchronous];
}

-(void)loadPapersFinished
{
    PDFpaper *paper = [self.paperArray firstObject];
    
    [self loadPaperLayouts:paper.paperId date:@""];
    
}

- (void)loadPaperLayouts:(NSString*)paperId date:(NSString *)date
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/getLayouts?sid=%@&cid=%@&date=%@",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,paperId,date];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setCompletionBlock:^(NSData *data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        if (dataDic) {
            NSArray *Arry = [dataDic objectForKey:@"layouts"];
            //最顶上日期
            self.selectedDate = [NSString stringWithFormat:@"   %@", Arry[0][@"date"]];
            _headerLabel.text = self.selectedDate;
            if (Arry.count) {
                
                self.allPages = [PDFPageDataModel pagesFromArray:Arry];
                [self.pagesWithArticle removeAllObjects];
                for(int i = 0; i < self.allPages.count; i++){
                    PDFPageDataModel *page = [self.allPages objectAtIndex:i];
                    if(page.articlesList.count > 0){
                        [self.pagesWithArticle addObject:page];
                    }
                }
                [self loadAllPagesFinishedForOnePaper];
            }
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        
    }];
    [request startAsynchronous];
}

-(void)loadAllPagesFinishedForOnePaper
{
    
}
@end
