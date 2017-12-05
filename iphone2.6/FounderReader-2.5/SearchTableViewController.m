//
//  SearchTableViewController.m
//  FounderReader-2.5
//
//  Created by sa on 15-7-16.
//
//

#import "SearchTableViewController.h"
#import "BATableView.h"
#import "pinyin.h"
#import "Column.h"
@interface SearchTableViewController ()<BATableViewDelegate>
@property (nonatomic, retain) BATableView *contactTableView;
@property (nonatomic, retain) NSMutableArray * dataSource;
@property UISearchBar *searchBar;
@end

@implementation SearchTableViewController
@synthesize searchBar,contactTableView;
@synthesize columns;
@synthesize delegate;
// 创建tableView
- (void) createTableView {
    contactTableView = [[BATableView alloc] initWithFrame:self.view.bounds];
    self.contactTableView.delegate = self;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    searchBar.translucent = YES;
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.showsCancelButton = NO;
    [searchBar sizeToFit];
    searchBar.delegate = self;
    [self.contactTableView.tableView setTableHeaderView:searchBar];
    [self.view addSubview:self.contactTableView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *nsmus = [[NSMutableArray alloc] initWithArray:columns];
    [nsmus removeObjectAtIndex:0];
    dataSoureResult = [self sortByFirstLetter:nsmus];
 
    
    self.dataSource = dataSoureResult;
    dataSoureFilterResult = dataSoureResult;
    
    
    //self.dataSource = @[@{@"indexTitle": @"A",@"data":@[@"阿柳", @"alfred", @"ain", @"abdul", @"anastazja", @"angelica"]},@{@"indexTitle": @"D",@"data":@[@"dennis" , @"deamon", @"destiny", @"dragon", @"dry", @"debug", @"drums"]},@{@"indexTitle": @"F",@"data":@[@"法克鱿", @"France", @"friends", @"family", @"老张", @"funeral"]},@{@"indexTitle": @"M",@"data":@[@"Mark", @"Madeline"]},@{@"indexTitle": @"N",@"data":@[@"Nemesis", @"nemo", @"name"]},@{@"indexTitle": @"O",@"data":@[@"Obama", @"Oprah", @"Omen", @"OMG OMG OMG", @"O-Zone", @"Ontario"]},@{@"indexTitle": @"Z",@"data":@[@"Zeus", @"Zebra", @"zed"]}];
    
    [self createTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0, 0, 15, 20);
//    [button setImage:[UIImage imageNamed:@"toolbar_back"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationController.navigationBarHidden = NO;
}
- (void)buttonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in self.dataSource) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource[section][@"indexTitle"];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.dataSource[section][@"data"]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellName = @"UITableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.section][@"data"][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//searchBar代理
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.dataSource = dataSoureResult;
    XYLog(@"%@",searchText);
    dataSoureFilterResult = [[NSMutableArray alloc] initWithCapacity:5];
    if (searchText!=nil && searchText.length>0) {
        for (NSDictionary *tempDic in self.dataSource) {
            //NSDictionary *a = tempDic[@"data"];
            NSString *title = [tempDic objectForKey:@"indexTitle"];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
            //NSArray * a = [tempDic objectForKey:@"data"];
            for(NSString *tempStr_ in [tempDic objectForKey:@"data"])
            {
                if ([[self namToPinYinFisrtNameWith:tempStr_] rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0 || [tempStr_ rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0)
                {
                    [tempArray addObject:tempStr_];
                }
            }
            if ([tempArray count])
            {
                NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      tempArray, @"data", title, @"indexTitle", nil];
                [dataSoureFilterResult addObject:dic];
            }
        }
        self.dataSource = dataSoureFilterResult;
        [self.contactTableView.tableView reloadData];
    }
    else
    {
        [self.contactTableView.tableView reloadData];
    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBar:self.searchBar textDidChange:@""];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self searchBar:self.searchBar textDidChange:@""];
    [self.searchBar resignFirstResponder];
}

-(NSString *)namToPinYinFisrtNameWith:(NSString *)name
{
    NSString * outputString = @"";
    for (int i =0; i<[name length]; i++) {
        outputString = [NSString stringWithFormat:@"%@%c",outputString,pinyinFirstLetter([name characterAtIndex:i])];
        
    }
    return outputString;
}

- (NSMutableArray*)sortByFirstLetter:(NSArray*)arr
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Column *c1 = obj1;
        Column *c2 = obj2;
        return [[self namToPinYinFisrtNameWith:c1.columnName] compare:[self namToPinYinFisrtNameWith:c2.columnName] options:NSNumericSearch];
    }]];
    
    //return resultArray;
    
    NSMutableArray *_dataSoureFilterResult = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *letters = @[@"#", @"A", @"B", @"C",
                         @"D", @"E", @"F", @"G",
                         @"H", @"I", @"J", @"K",
                         @"L", @"M", @"N", @"O",
                         @"P", @"Q", @"R", @"S",
                         @"T", @"U", @"V", @"W",
                         @"X", @"Y", @"Z"];
    
    for (NSString *first in letters)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:5];
        NSMutableArray *tempArrayIDs = [[NSMutableArray alloc] initWithCapacity:5];
        for(Column *column in resultArray)
        {
            NSString *firstLetter = [[self namToPinYinFisrtNameWith:column.columnName] substringToIndex:1];
            if ([first isEqualToString:[firstLetter uppercaseString]])
            {
                [tempArray addObject:column.columnName];
                [tempArrayIDs addObject:[NSString stringWithFormat:@"%d",column.columnId]];
            }
        }
        
        if ([tempArray count]){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  tempArray, @"data", first, @"indexTitle", tempArrayIDs, @"id", nil];
            
            [_dataSoureFilterResult addObject:dic];
        }
    }
    
    return _dataSoureFilterResult;
}

@end

