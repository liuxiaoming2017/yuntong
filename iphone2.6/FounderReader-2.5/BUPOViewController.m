//
//  BUPOViewController.m
//  ZakerLike
//
//  Created by bupo Jung on 12-5-15.
//  Copyright (c) 2012年 Wuxi Smart Sencing Star. All rights reserved.
//

#import "BUPOViewController.h"
#import "Column.h"
#import "MFSideMenu.h"
#import "NewsListConfig.h"
#import "ColumnBarConfig.h"
#import "ColorStyleConfig.h"
#define columns 3
#define rows 3
#define itemsPerPage 30
#define unValidIndex  -1
#define threshold 30
#define labelHeight 40

@interface BUPOViewController(private)
-(NSInteger)indexOfLocation:(CGPoint)location;
-(CGPoint)orginPointOfIndex:(NSInteger)index;
-(void) exchangeItem:(NSInteger)oldIndex withposition:(NSInteger) newIndex;
@end

@implementation BUPOViewController
@synthesize delegate;
@synthesize headerLabel;
//@synthesize currentID = _currentID;
@synthesize currentName;


#pragma mark - View lifecycle
- (void)initWithColumns:(NSArray*) allColumns parentcolumnid:(int) parentcolumnid
{
    itemframe = CGRectMake(0.05*kSWidth, (26/1136.0)*kSHeight, (172/640.0)*kSWidth, (52/1136.0)*kSHeight);
    rowHeight = (26/1136.0)*kSHeight;
    space = (30/640.0)*kSWidth;
    j = -1;
    _parentID = parentcolumnid;
    selectItems = [[NSMutableArray alloc] init];
    selectedItems = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefaultes dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", _parentID]];
    NSString *dicKeyvalue = [dictionary valueForKey:[NSString stringWithFormat:@"%d",_parentID]];
    NSString *dicString = [NSString stringWithFormat:@"%@",dicKeyvalue];
    _selectedArray = [dicString componentsSeparatedByString:@","];
    if (dicKeyvalue == nil || dicKeyvalue.length == 0) {
        _selectedArray = nil;
    }
    
    int selectIndex = 0,selectedIndex = 0;
    if (_selectedArray == nil || [_selectedArray count] == 0) {
        
        for (int index = 0; index < [allColumns count]; index++) {
            
            Column *column = [allColumns objectAtIndex:index];
            if(column.keyword[@"showInMore"]){
                //默认显示到更多的栏目中
                BJGridItem *item = [[BJGridItem alloc] initWithTitle:column.columnName withImageName:@"" atIndex:selectIndex editable:NO groupid:0 ID:column.columnId currentName:self.currentName];
                item.descStr = column.description;
                [selectItems addObject:item];
                selectIndex++;
            }
            else{
                //默认显示到导航栏中
                BJGridItem *item = [[BJGridItem alloc] initWithTitle:column.columnName withImageName:@"" atIndex:selectedIndex editable:YES groupid:1 ID:column.columnId currentName:self.currentName];
                item.descStr = column.description;
                [selectedItems addObject:item];
                selectedIndex++;
            }
        }
    }
    else{
        for (int i = 0; i < [_selectedArray count]; i++){
            
            for (int index = 0; index < [allColumns count]; index++) {
                
                Column *column = [allColumns objectAtIndex:index];
                if ([_selectedArray[i] isEqualToString:[NSString stringWithFormat:@"%d",column.columnId]])
                {
                    BJGridItem *item = [[BJGridItem alloc] initWithTitle:column.columnName withImageName:@"" atIndex:selectedIndex editable:YES groupid:1 ID:column.columnId currentName:self.currentName];
                    item.descStr = column.description;
                    item.descriptionLabel.backgroundColor = [UIColor clearColor];
                    [selectedItems addObject:item];
                    selectedIndex++;
                }
            }
        }
        
        selectIndex = selectedIndex;
        for (int index = 0; index < [allColumns count]; index++) {
            
            Column *column = [allColumns objectAtIndex:index];
            if (![_selectedArray containsObject:[NSString stringWithFormat:@"%d",column.columnId]]){
                
                BJGridItem *item = [[BJGridItem alloc] initWithTitle:column.columnName withImageName:@"" atIndex:selectIndex editable:NO groupid:0 ID:column.columnId currentName:self.currentName];
                item.descStr = column.description;
                [selectItems addObject:item];
                selectIndex++;
            }
        }
    }
}

- (void)loadView
{
    [super loadView];
    scrollview = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = scrollview;
    scrollview.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentID = 2000;
    isChang = NO;
    backItem = NO;
    page = 0;
    isEditing = NO;
    self.view.frame = CGRectMake(0, -20, kSWidth, kSHeight);
    myColumnsView = [[UIView alloc]init];
    myColumnsView.frame = CGRectMake(0, 0, kSWidth, 50+((40+30+11)/1136.0)*kSHeight+XaddHeight);
    myColumnsView.backgroundColor = UIColorFromString(@"245,245,245");
    //myColumnsView.backgroundColor = UIColor.orangeColor;
    myColumnsView.alpha = 0.98;
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, kNavBarHeight)];
    navView.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color;
    //navView.backgroundColor = UIColor.blueColor;
    [myColumnsView addSubview:navView];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"nav_bar_back"] forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(15, kStatusBarHeight, 44, 44);
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:leftButton];
    
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(0.05*kSWidth, 50+0.035*kSHeight+XaddHeight, 0.009*kSWidth, 0.0264*kSHeight)];
    redView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    [myColumnsView addSubview:redView];
    
    UILabel *myColumsLabel = [[UILabel alloc]initWithFrame:CGRectMake((48/640.0)*kSWidth, 50+0.035*kSHeight+XaddHeight, (114/640.0)*kSWidth, 0.0264*kSHeight)];
    myColumsLabel.text = NSLocalizedString(@"切换栏目",nil);
    myColumsLabel.textColor = UIColorFromString(@"111,111,111");
    myColumsLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize-1];
    myColumsLabel.backgroundColor = [UIColor clearColor];
    [myColumnsView addSubview:myColumsLabel];
    
    UILabel *operationLabel = [[UILabel alloc]initWithFrame:CGRectMake(myColumsLabel.frame.origin.x+myColumsLabel.frame.size.width+(36/640.0)*kSWidth, myColumsLabel.frame.origin.y, kSWidth-redView.frame.size.width-myColumsLabel.frame.size.width-((36+10+32)/640)*kSWidth, myColumsLabel.frame.size.height)];
    operationLabel.text = NSLocalizedString(@"长按拖动调整栏目顺序,单击切换栏目",nil);
    operationLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    operationLabel.textColor = UIColorFromString(@"153,153,153");
    operationLabel.backgroundColor = [UIColor clearColor];
    [myColumnsView addSubview:operationLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0.05*kSWidth, myColumnsView.frame.size.height-1, 0.9*kSWidth, 1)];
    lineView.backgroundColor = UIColorFromString(@"221,221,221");
    [myColumnsView addSubview:lineView];
    [self.view addSubview:myColumnsView];
    
    UIView *LineV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 1)];
    LineV.backgroundColor = UIColorFromString(@"221,221,221");
    [myColumnsView addSubview:LineV];
    
    UITapGestureRecognizer *tapmyGuesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapmyGuesture.numberOfTapsRequired=1;
    tapmyGuesture.numberOfTouchesRequired=1;
    //    [myColumnsView addGestureRecognizer:tapmyGuesture];
    
    
    moreColumnsView = [[UIView alloc]init];
    moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+kSHeight*(412/1136.0), kSWidth, ((40+30+11)/1136.0)*kSHeight);
    moreColumnsView.backgroundColor = UIColorFromString(@"245,245,245");
    moreColumnsView.alpha = 0.98;
    
    
    
    UIView *cyanView = [[UIView alloc]initWithFrame:CGRectMake(0.05*kSWidth, 0.035*kSHeight, 0.009*kSWidth, 0.0264*kSHeight)];
    cyanView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
    [moreColumnsView addSubview:cyanView];
    
    
    UILabel *moreColumsLabel = [[UILabel alloc]initWithFrame:CGRectMake(cyanView.frame.origin.x+cyanView.frame.size.width+(10/640.0)*kSWidth, cyanView.frame.origin.y, 200, cyanView.frame.size.height)];
    moreColumsLabel.text = NSLocalizedString(@"点击添加更多栏目",nil);
    moreColumsLabel.textColor = UIColorFromString(@"111,111,111");
    moreColumsLabel.backgroundColor = [UIColor clearColor];
    moreColumsLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    [moreColumnsView addSubview:moreColumsLabel];
    
    
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0.05*kSWidth, moreColumnsView.frame.size.height-1, 0.9*kSWidth, 1)];
    topLineView.backgroundColor = UIColorFromString(@"221,221,221");
    [moreColumnsView addSubview:topLineView];
    
    
    [self.view addSubview:moreColumnsView];
    UITapGestureRecognizer *tapmoGuesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapmoGuesture.numberOfTapsRequired=1;
    tapmoGuesture.numberOfTouchesRequired=1;
    [self.view addGestureRecognizer:tapmoGuesture];
    
    // 已经选择的栏目
    selectedView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, myColumnsView.frame.size.height, kSWidth, kSHeight*(412/1136.0))];
    
    // 未选择的栏目
    selectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, myColumnsView.frame.size.height+selectedView.frame.size.height+moreColumnsView.frame.size.height, kSWidth, kSHeight-(myColumnsView.frame.size.height+selectedView.frame.size.height + moreColumnsView.frame.size.height))];
    
    selectView.backgroundColor = UIColorFromString(@"245,245,245");
    selectedView.backgroundColor =  UIColorFromString(@"245,245,245");
    
    selectView.alpha = 0.98;
    selectedView.alpha = 0.98;
    
    selectedView.contentSize = CGSizeMake(kSWidth,kSHeight*(412/1136.0)*5 + rowHeight*5 +100);
    selectView.contentSize = CGSizeMake(kSWidth, (70/1136.0)*kSHeight * 5 + rowHeight * 5 +100);
    
    selectView.showsVerticalScrollIndicator = TRUE;
    selectedView.showsVerticalScrollIndicator = TRUE;
    [scrollview addSubview: selectedView];
    [scrollview addSubview: selectView];
    
    CGRect frame;
    for (int index=0; index < [selectedItems count]; index++)
    {
        frame = itemframe;
        addbutton = [selectedItems objectAtIndex:index];
        
        int row = index / columns;
        int col = index % rows;
        frame.origin.x = frame.origin.x + frame.size.width * col + space * col;
        frame.origin.y = frame.origin.y + frame.size.height * row + rowHeight * row;
        [addbutton setFrame:CGRectMake(frame.origin.x, frame.origin.y , (172/640.0)*kSWidth, (52/1136.0)*kSHeight)];
        addbutton.delegate = self;
        
        [selectedView addSubview:addbutton];
    }
    
    for (int index=0; index < [selectItems count]; index++)
    {
        frame = itemframe;
        addbutton = [selectItems objectAtIndex:index];
        [addbutton setFrame:CGRectMake(frame.origin.x, index*(70/1136.0)*kSHeight + (index+1)*rowHeight, (576/640.0)*kSWidth, (70/1136.0)*kSHeight)];
        [selectView addSubview:addbutton];
        addbutton.button.frame = addbutton.bounds;
        addbutton.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        addbutton.button.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        addbutton.button.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        addbutton.delegate = self;
        CGSize titleSize = [self contentWidthWithText:addbutton->titleText Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize]];
        
        
        UILabel *desc = [[UILabel alloc]initWithFrame:CGRectMake(titleSize.width+0.06*kSWidth, 0, (576/640.0)*kSWidth-titleSize.width-0.06*kSWidth-0.1*kSWidth, addbutton.frame.size.height)];
        if(addbutton.descStr != nil && ![addbutton.descStr isEqualToString:@""])
        {
            desc.text = [NSString stringWithFormat:@"( %@ )",addbutton.descStr];
        }
        desc.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
        desc.lineBreakMode = NSLineBreakByTruncatingMiddle;
        desc.backgroundColor = [UIColor clearColor];
        desc.textColor = [UIColor lightGrayColor];
        [addbutton addSubview:desc];
        
        
        UIImageView *pluView = [[UIImageView alloc]initWithFrame:CGRectMake((600/750.0)*kSWidth, (20/1334.0)*kSHeight, (36/640.0)*kSWidth, (36/640.0)*kSWidth)];
        pluView.image = [UIImage imageNamed:@"icon_s"];
        [addbutton addSubview:pluView];
        
        
    }
    
    
    [self setScrollViewContentSize];
    selectedView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGuesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGuesture.numberOfTapsRequired=1;
    tapGuesture.numberOfTouchesRequired=1;
    [selectedView addGestureRecognizer:tapGuesture];
    
    if (selectedItems.count<=21) {
        if (selectedItems.count%columns) {
            moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+(selectedItems.count/columns+1)*(52/1136.0*kSHeight+rowHeight), kSWidth, ((40+30+11)/1136.0)*kSHeight);
            selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, (selectedItems.count/columns+1)*(52/1136.0*kSHeight+rowHeight));
            selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
        }else
        {
            moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+(selectedItems.count/columns)*(52/1136.0*kSHeight+rowHeight), kSWidth, ((40+30+11)/1136.0)*kSHeight);
            selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, (selectedItems.count/columns)*(52/1136.0*kSHeight+rowHeight));
            selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
        }
    }else {
        moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+7*(52/1136.0*kSHeight+rowHeight)+rowHeight, kSWidth, ((40+30+11)/1136.0)*kSHeight);
        selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, 7*(52/1136.0*kSHeight+rowHeight)+rowHeight);
        selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
    }
}

-(void)setScrollViewContentSize
{
    if (selectedItems.count%columns) {
        selectedView.contentSize = CGSizeMake(kSWidth, ceil(selectedItems.count/columns + 1 )*((52/1136.0)*kSHeight+rowHeight));
    }else{
        selectedView.contentSize = CGSizeMake(kSWidth, ceil(selectedItems.count/columns)*((52/1136.0)*kSHeight+rowHeight));
    }
    
    if (selectItems.count) {
        selectView.contentSize = CGSizeMake(kSWidth,ceil(((selectItems.count+1)*((70/1136.0)*kSHeight+rowHeight))+rowHeight));
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)updateForBUPOColumns
{
    self.hidesBottomBarWhenPushed = NO;
    
    if (isChang) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *strValue = @"";
        
        NSDictionary *dictionary = [userDefaults dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", _parentID]];
        
        if ([dictionary count]>0)
            [mutableDictionary addEntriesFromDictionary:dictionary];
        
        for(int i = 0; i < [selectedItems count]; i++)
        {
            BJGridItem *item = selectedItems[i];
            if ([strValue isEqualToString:@""])
                strValue = [NSString stringWithFormat:@"%d",item.ID];
            else
                strValue = [strValue stringByAppendingString:[NSString stringWithFormat:@",%d",item.ID]];
        }
        [mutableDictionary setObject:strValue forKey:[NSString stringWithFormat:@"%d",_parentID]];
        [userDefaults setObject:mutableDictionary forKey:[NSString stringWithFormat:@"columnsOrder-%d", _parentID]];
        [userDefaults setBool:isChang forKey:@"NJCustomColumnsChang"];
        
        [userDefaults synchronize];
        
        if (_currentID == 2000) {
            //没有选择任何栏目
            _currentID = 0;
            if (backItem == YES) {
                if ([self.delegate respondsToSelector:@selector(refreshcolumnbar:)])
                {
                    [self.delegate refreshcolumnbar:_currentID];
                }
                backItem = NO;
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(refreshcolumnbar:)])
                [self.delegate refreshcolumnbar:_currentID];
        }
    }else{
        
        if (_currentID == 2000) {
            //没有选择任何栏目
        }else{
            if ([self.delegate respondsToSelector:@selector(refreshcolumnbar:)])
                [self.delegate refreshcolumnbar:_currentID];
        }
    }
}

- (void)updateForBUPOColumnsNoMoreColumn
{
    self.hidesBottomBarWhenPushed = NO;
    
    if (isChang) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *strValue = @"";
        
        NSDictionary *dictionary = [userDefaults dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", _parentID]];
        
        if ([dictionary count]>0)
            [mutableDictionary addEntriesFromDictionary:dictionary];
        
        for(int i = 0; i < [selectedItems count]; i++)
        {
            BJGridItem *item = selectedItems[i];
            if ([strValue isEqualToString:@""])
                strValue = [NSString stringWithFormat:@"%d",item.ID];
            else
                strValue = [strValue stringByAppendingString:[NSString stringWithFormat:@",%d",item.ID]];
        }
        [mutableDictionary setObject:strValue forKey:[NSString stringWithFormat:@"%d",_parentID]];
        [userDefaults setObject:mutableDictionary forKey:[NSString stringWithFormat:@"columnsOrder-%d", _parentID]];
        [userDefaults setBool:isChang forKey:@"NJCustomColumnsChang"];
        
        [userDefaults synchronize];
        
        if (_currentID == 2000) {
            //没有选择任何栏目
            _currentID = 0;
            if (backItem == YES) {
                if ([self.delegate respondsToSelector:@selector(refreshcolumnbarNoMoreColumn:)])
                {
                    [self.delegate refreshcolumnbarNoMoreColumn:_currentID];
                }
                backItem = NO;
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(refreshcolumnbarNoMoreColumn:)])
                [self.delegate refreshcolumnbarNoMoreColumn:_currentID];
        }
    }else{
        
        if (_currentID == 2000) {
            //没有选择任何栏目
        }else{
            if ([self.delegate respondsToSelector:@selector(refreshcolumnbarNoMoreColumn:)])
                [self.delegate refreshcolumnbarNoMoreColumn:_currentID];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [self updateForBUPOColumns];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateForBUPOColumns" object:nil];
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#pragma mark-- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    preX = scrollView.contentOffset.x;
    preFrame = backgoundImage.frame;
    XYLog(@"prex:%f",preX);
}
- (void)Editbutton:(int) index {

    _currentID = [self GetArrIdByIndex:selectedItems atIndex:index];
    [self goBack];
}

- (int) GetArrIdByIndex:(NSMutableArray*)items atIndex:(int)index
{
    BJGridItem *bt;
    int Id = 0;
    for (int i=0; i < [items count]; i++) {
        bt = [items objectAtIndex:i];
        if (bt.index == index)
            Id = i;
    }
    bt = nil;
    return Id;
}

- (void)Addbutton:(int) index {
    CGRect frame = itemframe;
    NSUInteger n = [selectedItems count];
    NSUInteger row = (n) / columns;
    int col = (n) % rows;
    //    row = row % columns;
    if (n <= itemsPerPage) {
        frame.origin.x = frame.origin.x + frame.size.width * col + space * col;
        frame.origin.y = frame.origin.y + frame.size.height * row + rowHeight * row;
        
        BJGridItem *button = [self GetItematIndex:selectItems atIndex:index];
        BJGridItem *gridItem = [[BJGridItem alloc] initWithTitle:button->titleText withImageName:@"" atIndex:index editable:YES groupid:1 ID:button.ID currentName:self.currentName];
        gridItem.descStr = button.descStr;
        [gridItem setFrame:frame];
        gridItem.delegate = self;
        XYLog(@"the addbutton:%@,%d",button->titleText,index);
        [selectedItems insertObject:gridItem atIndex:n];
        [self RemoveObject:selectItems atIndex:index];
        
        [selectedView addSubview:gridItem];
        
        XYLog(@"--------Sort SelectItems--------");
        
        [self SortItems:selectItems];
        
        XYLog(@"--------Sort SelectedItems--------");
        [self SortItems:selectedItems];
        
        
    }
    NSString* strHeader = [NSString stringWithFormat:@"  %lu个未读栏目点击进入", (unsigned long)[selectItems count]];
    self.headerLabel.text= strHeader; //label名称
    
}
#pragma mark-- BJGridItemDelegate
// 点击栏目进行处理
- (void)gridItemDidClicked:(BJGridItem *)gridItem{
    
    XYLog(@"grid at index %ld did clicked",(long)gridItem.index);
    // 点击添加更多栏目
    if ([selectItems containsObject:gridItem])
    {
        isChang = YES;
        if (isEditing) {
            for (BJGridItem *item in selectedItems) {
                XYLog(@"button:x=%f,y=%f",item.frame.origin.x, item.frame.origin.y);
                [item disableEditing];
            }
            [addbutton disableEditing];
        }
        isEditing = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [self Addbutton:(int) gridItem.index];
        }];
        [self updateForBUPOColumnsNoMoreColumn];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateForBUPOColumns" object:nil];
    }
    // 点击跳转到指定栏目
    else {
        [self Editbutton:(int) gridItem.index];
    }
    
}

// 点击删除栏目
- (void)gridItemDidDeleted:(BJGridItem *)gridItem atIndex:(NSInteger)index{
    
    isChang = YES;
    [UIView animateWithDuration:0.5 animations:^{
        XYLog(@"grid at index %ld did deleted",(long)gridItem.index);
        BJGridItem *item = [[BJGridItem alloc] initWithTitle:gridItem->titleText withImageName:@"" atIndex:index editable:YES groupid:0 ID:gridItem.ID currentName:self.currentName];
        item.descStr = gridItem.descStr;
        
        if (gridItem->titleText == self.currentName) {
            backItem = YES;
        }
        item.delegate = self;
        [item disableEditing];
        
        [selectItems insertObject:item atIndex:[selectItems count]];
        [self RemoveObject:selectedItems atIndex:(int)index];
        XYLog(@"F1:%ld",(long)index);
        
        selectView.contentSize = CGSizeMake(kSWidth,ceil(((selectItems.count+1)*((70/1136.0)*kSHeight+rowHeight))+rowHeight));
        
        selectedView.contentSize = CGSizeMake(kSWidth, ceil(selectedItems.count/columns + 1 )*((52/1136.0)*kSHeight+rowHeight));
        
        
        //    XYLog(@"%f",selectView.contentSize.height);
        [selectView addSubview:item];
        
        [self SortItems:selectedItems];
        isDelete = YES;
        [self SortItems:selectItems];
        
        
        
        
        
        //    NSString* strHeader = [NSString stringWithFormat:@"  %d个未读栏目点击进入", [selectItems count]];
        //    self.headerLabel.text= strHeader; //label名称
    }];
    [self updateForBUPOColumnsNoMoreColumn];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateForBUPOColumns" object:nil];
}
// 长按进入编辑状态
- (void)gridItemDidEnterEditingMode:(BJGridItem *)gridItem{
    XYLog(@"selectedtems count:%lu",(unsigned long)[selectedItems count]);
    for (BJGridItem *item in selectedItems) {
        XYLog(@"%ld",(long)item.index);
        [item enableEditing];
    }
    
    isEditing = YES;
}

- (void)gridItemDidMoved:(BJGridItem *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer{
    CGRect frame = gridItem.frame;
    CGPoint _point = [recognizer locationInView:selectedView];
    
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    gridItem.frame = frame;
    
    NSInteger toIndex = [self indexOfLocation:_point];
    NSInteger fromIndex = [self GetItematIndex:selectedItems atIndex:(int)gridItem.index].index;
    
    if (toIndex != unValidIndex && toIndex != fromIndex) {
        [UIView animateWithDuration:0.5 animations:^{
            //第一个栏目不允许移动
            if(toIndex != 0){
                [selectedItems removeObject:gridItem];
                [selectedItems insertObject:gridItem atIndex:toIndex];
            }
            [self SortItems:selectedItems];
            if (gridItem->titleText == self.currentName)
            {
                _currentID = (int)toIndex;
            }
        }];
    }
}

- (void)gridItemDidMoving:(BJGridItem *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer{
    isChang = YES;
    
    CGRect frame = gridItem.frame;
    CGPoint _point = [recognizer locationInView:selectedView];
    
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    gridItem.frame = frame;
    
    gridItem.layer.zPosition = 1;
}
- (void) gridItemDidEndMoved:(BJGridItem *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer{
    
    gridItem.layer.zPosition = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self SortItems:selectedItems];
    }];
    XYLog(@"gridItem index:%ld",(long)gridItem.index);
}


// 点击空白处理
- (void) handleSingleTap:(UITapGestureRecognizer *) gestureRecognizer{
    if (isEditing)
    {
        for (BJGridItem *item in selectedItems) {
            XYLog(@"button:x=%f,y=%f",item.frame.origin.x, item.frame.origin.y);
            [item disableEditing];
        }
        [addbutton disableEditing];
    }
    isEditing = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(touch.view != selectedView){
        return NO;
    }else
        return YES;
}

#pragma mark-- private
- (NSInteger)indexOfLocation:(CGPoint)location{
    NSInteger index;
    NSInteger row =  (location.y) / ((52/1136.0)*kSHeight + 15);
    NSInteger col = (location.x) / ((172/640.0)*kSWidth + 5);
    //    if (row >= rows || col >= columns) {
    //        return  unValidIndex;
    //    }
    index = row * columns + col;
    if (index >= [selectedItems count]) {
        return  unValidIndex;
    }
    
    return index;
}

- (CGPoint)orginPointOfIndex:(NSInteger)index{
    CGPoint point = CGPointZero;
    if (index > [selectedItems count] || index < 0) {
        return point;
    }else{
        NSInteger row = (index) / columns;
        NSInteger col = (index) % columns;
        
        //point.x = col * gridWith + (col + 1) * space;
        //point.y = row * gridHight + (row + 1) * space + 5;
        point.x = itemframe.origin.x + itemframe.size.width * col + space * col;
        point.y = itemframe.origin.y + itemframe.size.height * row + (52/1136.0)*kSHeight * row;
        return  point;
    }
}

- (void)exchangeItem:(NSInteger)oldIndex withposition:(NSInteger)newIndex{
    /*((BJGridItem *)[selectedItems objectAtIndex:oldIndex]).index = newIndex;
     ((BJGridItem *)[selectedItems objectAtIndex:newIndex]).index = oldIndex;
     [selectedItems exchangeObjectAtIndex:oldIndex withObjectAtIndex:newIndex];*/
    newIndex = ((BJGridItem *)[selectedItems objectAtIndex:newIndex]).index;
    
    ((BJGridItem *)[self GetItematIndex:selectedItems atIndex:oldIndex]).index = newIndex;
    ((BJGridItem *)[self GetItematIndex:selectedItems atIndex:newIndex]).index = oldIndex;
    [self exchangeObjectAtIndex:selectedItems oldIndex:(int)oldIndex newIndex:(int)newIndex];
}

- (void)RemoveObject:(NSMutableArray*)items atIndex:(int)index
{
    BJGridItem *bt;
    for (int i=0; i < [items count]; i++) {
        bt = [items objectAtIndex:i];
        if (bt.index == index)
        {
            [[items objectAtIndex:i] removeFromSuperview];
            [items removeObjectAtIndex:i];
        }
    }
    bt = nil;
    
    [self SortItems:items];
}

- (void)SortItems:(NSMutableArray*) items
{
    //move the add button
    CGRect frame;
    BJGridItem *item;
    XYLog(@"sort items count:%lu",(unsigned long)[items count]);
    
    
    if (items == selectedItems) {
        if (selectedItems.count%columns) {
            selectedView.contentSize = CGSizeMake(kSWidth, ceil(selectedItems.count/columns + 1 )*((52/1136.0)*kSHeight+rowHeight));
        }else
        {
            selectedView.contentSize = CGSizeMake(kSWidth, ceil(selectedItems.count/columns)*((52/1136.0)*kSHeight+rowHeight));
        }
        
        for (int i=0; i < [items count]; i++)
        {
            frame = itemframe;
            item = [items objectAtIndex:i];
            int row = i / columns;
            int col = i % rows;
            frame.origin.x = frame.origin.x + frame.size.width * col + space * col;
            frame.origin.y = frame.origin.y + frame.size.height * row + rowHeight * row;
            XYLog(@"%ld,",(long)item.index);
            [item setFrame:frame];
        }
        
    }else if (items == selectItems)
    {
        if (selectItems.count) {
            selectView.contentSize = CGSizeMake(kSWidth,ceil(((selectItems.count+1)*((70/1136.0)*kSHeight+rowHeight))+rowHeight));
        }
        
        for (int i = 0; i < [items count]; i++)
        {
            j = (int)[items count] - 2;
            frame = itemframe;
            item = [items objectAtIndex:i];
            //顺序添加或者倒序添加selectItem
            [item setFrame:CGRectMake(frame.origin.x, i*(70/1136.0)*kSHeight + (i+1)*rowHeight, (576/640.0)*kSWidth, (70/1136.0)*kSHeight)];
            item.button.frame = item.bounds;
            item.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            item.button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            
            if (i>j) {
                if (isDelete) {
                    [self performSelector:@selector(delayalittle:) withObject:item afterDelay:0.3];
                    isDelete = !isDelete;
                }
                
            }
        }
    }
    
    if (selectedItems.count<=21) {
        if (selectedItems.count%columns) {
            moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+((selectedItems.count/columns)+1)*(52/1136.0*kSHeight+rowHeight), kSWidth, ((40+30+11)/1136.0)*kSHeight);
            selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, ((selectedItems.count/columns)+1)*(52/1136.0*kSHeight+rowHeight));
            selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
        }else
        {
            moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+(selectedItems.count/columns)*(52/1136.0*kSHeight+rowHeight), kSWidth, ((40+30+11)/1136.0)*kSHeight);
            selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, (selectedItems.count/columns)*(52/1136.0*kSHeight+rowHeight));
            selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
        }
        
    }else {
        moreColumnsView.frame = CGRectMake(0, myColumnsView.frame.size.height+7*(52/1136.0*kSHeight+rowHeight), kSWidth, ((40+30+11)/1136.0)*kSHeight);
        selectedView.frame = CGRectMake(0, myColumnsView.frame.size.height, kSWidth, 7*(52/1136.0*kSHeight+rowHeight));
        selectView.frame = CGRectMake(0, moreColumnsView.frame.size.height+moreColumnsView.frame.origin.y, kSWidth, kSHeight-myColumnsView.frame.size.height-selectedView.frame.size.height-moreColumnsView.frame.size.height);
    }
    
}

- (void)delayalittle:(BJGridItem *)item
{
    item.button.titleLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
    CGSize titleSize = [self contentWidthWithText:item->titleText Font:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize]];
    
    UILabel *desLabel =  [[UILabel alloc]initWithFrame:CGRectMake(titleSize.width+0.06*kSWidth, 0, (576/640.0)*kSWidth-titleSize.width-0.06*kSWidth-0.1*kSWidth, item.frame.size.height)];
    item.descriptionLabel = desLabel;
    
    if (item.descStr != nil && ![item.descStr isEqualToString:@""]) {
        item.descriptionLabel.text = [NSString stringWithFormat:@"( %@ )",item.descStr];
    }
    item.descriptionLabel.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellDateFontSize+1];
    item.descriptionLabel.textColor = UIColorFromString(@"153,153,153");
    item.descriptionLabel.backgroundColor = [UIColor clearColor];
    item.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [item addSubview:item.descriptionLabel];
    
    UIImageView *plView = [[UIImageView alloc]initWithFrame:CGRectMake((600/750.0)*kSWidth, (20/1334.0)*kSHeight, (36/640.0)*kSWidth, (36/640.0)*kSWidth)];
    item.pluView = plView;
    
    item.pluView.image = [UIImage imageNamed:@"icon_s"];
    [item addSubview:item.pluView];
}

- (BJGridItem*) GetItematIndex:(NSMutableArray*)items atIndex:(NSInteger)index
{
    BJGridItem *button,*bt;
    for (int i=0; i < [items count]; i++) {
        bt = [items objectAtIndex:i];
        if (bt.index == index)
            button = [items objectAtIndex:i];
    }
    bt = nil;
    return button;
}

- (void)exchangeObjectAtIndex:(NSMutableArray*)items oldIndex:(int)oldindex newIndex:(int)newindex{
    BJGridItem *bt;
    int a = 0, b = 0;
    for (int i=0; i < [items count]; i++) {
        bt = [items objectAtIndex:i];
        if (bt.index == oldindex)
            a = i;
        if (bt.index == newindex)
            b = i;
    }
    [items exchangeObjectAtIndex:a withObjectAtIndex:b];
}

- (int)GetItemPosAtIndex:(NSMutableArray*)items atIndex:(int)index{
    BJGridItem *bt;
    for (int i=0; i < [items count]; i++) {
        bt = [items objectAtIndex:i];
        if (bt.index == index)
            return i;
        
    }
    return -1;
}

-(void)goBack
{
    [self.view removeFromSuperview];
}


- (CGSize)contentWidthWithText:(NSString*)text Font:(UIFont*)font
{
    //设置字体
    CGSize size = CGSizeMake(150, 100);//注：这个宽：300 是你要显示的宽度既固定的宽度，高度可以依照自己的需求而定
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    return size;
}

@end


