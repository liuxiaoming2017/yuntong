//
//  FDAreaPickerViewController.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/5/10.
//
//

#import "FDAreaPickerViewController.h"
#import "ColorStyleConfig.h"
#import "HttpRequest.h"
#import "ColorStyleConfig.h"

@interface FDAreaPickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *areaInitialDict;
@property (strong, nonatomic) NSMutableArray *areaInitialArray;

@property (strong, nonatomic) FDAreaPickerBlock pickerBlock;
@property (strong, nonatomic) FDAreaPickerModel *defaultModel;

@end

@implementation FDAreaPickerViewController

- (instancetype)initWithDefaultModel:(FDAreaPickerModel *)model FDAreaPickerBlock:(FDAreaPickerBlock)block {
    if (self = [super init]) {
        self.defaultModel = model;
        self.pickerBlock = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self leftAndRightButton];
    self.title = @"选择国家和地区";
    NSMutableDictionary *textTitleAttrs = [NSMutableDictionary dictionary];
    textTitleAttrs[NSForegroundColorAttributeName] = [ColorStyleConfig sharedColorStyleConfig].navbar_titlecolor_selected;
    textTitleAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    self.navigationController.navigationBar.titleTextAttributes = textTitleAttrs;
    [self loadData];
}

-(void)leftAndRightButton
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData {
    NSString *requestString = @"http://oss.newaircloud.com/global/config/country-code.json";
    HttpRequest *request = [[HttpRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    __weak __typeof (self)weakSelf = self;
    [request setCompletionBlock:^(id data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        for (FDAreaPickerModel *model in [FDAreaPickerModel mj_objectArrayWithKeyValuesArray:array]) {
            NSString *initial = [weakSelf initialForString:model.country];
            NSMutableArray *array = [weakSelf.areaInitialDict valueForKey:initial];
            if (!array) {
                array = [NSMutableArray array];
                [weakSelf.areaInitialArray addObject:initial];
            }
            [array addObject:model];
            [weakSelf.areaInitialDict setValue:array forKey:initial];
        }
        weakSelf.areaInitialArray = [weakSelf.areaInitialArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }].mutableCopy;
        [weakSelf.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load articles failed: %@", error);
        [Global showTipNoNetWork];
    }];
    [request startAsynchronous];
}

- (NSString *)initialForString:(NSString *)aString {
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSString *pinYin = [str capitalizedString];
    return [pinYin substringToIndex:1];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.areaInitialArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = [self.areaInitialDict valueForKey:self.areaInitialArray[section]];
    for (NSInteger i = 0; i < array.count; i++) {
        FDAreaPickerModel *model = array[i];
        if ([model.code isEqualToString:self.defaultModel.code]) {
            [self performSelectorOnMainThread:@selector(scrollToRow:) withObject:[NSIndexPath indexPathForRow:i inSection:section] waitUntilDone:NO];
            break;
        }
    }
    return array.count;
}

- (void)scrollToRow:(NSIndexPath *)indexPath {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.areaInitialArray[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.areaInitialArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSMutableArray *array = [self.areaInitialDict valueForKey:self.areaInitialArray[indexPath.section]];
    FDAreaPickerModel *model = array[indexPath.row];
    cell.textLabel.text = model.country;
    cell.detailTextLabel.text = model.code;
    if ([model.code isEqualToString:self.defaultModel.code]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [[ColorStyleConfig sharedColorStyleConfig] nav_bar_color];
        cell.detailTextLabel.textColor = [[ColorStyleConfig sharedColorStyleConfig] nav_bar_color];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = [self.areaInitialDict valueForKey:self.areaInitialArray[indexPath.section]];
    FDAreaPickerModel *model = array[indexPath.row];
    if (self.pickerBlock) {
        self.pickerBlock(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSWidth, kSHeight-kNavBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tintColor = [[ColorStyleConfig sharedColorStyleConfig] nav_bar_color];
    }
    return _tableView;
}

- (NSMutableDictionary *)areaInitialDict {
    if (!_areaInitialDict) {
        _areaInitialDict = [NSMutableDictionary dictionary];
    }
    return _areaInitialDict;
}

- (NSMutableArray *)areaInitialArray {
    if (!_areaInitialArray) {
        _areaInitialArray = [NSMutableArray array];
    }
    return _areaInitialArray;
}

@end
