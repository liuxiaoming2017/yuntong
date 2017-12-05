//
//  DataChannelPageController.m
//  FounderReader-2.5
//
//  Created by chenfei on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataChannelPageController.h"
#import "Column.h"
#import "ColumnRequest.h"
#import "DataLib/DataLib.h"
#import "UIDevice-Reachability.h"
#import "ColumnBarConfig.h"
#import "CacheManager.h"

@implementation DataChannelPageController

@synthesize columns, allcolumns;
@synthesize sideBar,leftController;

#pragma mark - 获取栏目数组
- (void)loadColumns
{
    [self loadColumnsArray];
}

- (void)loadColumnsFromDB
{
    CacheManager *manager = [CacheManager sharedCacheManager];
    allcolumns = [NSMutableArray arrayWithArray:[manager columns:parentColumn.columnId]];
    columns = [NSMutableArray arrayWithArray:[manager columns:parentColumn.columnId]];
    
    if ([columns count])
    {
        [self updateColumns];
        [self loadColumnsFinished];
    }
}

#pragma - mark  加载栏目数组,上面滑动栏目
- (void)loadColumnsArray
{
    ColumnRequest *request = [ColumnRequest columnRequestWithParentColumnId:parentColumn.columnId];
    Column *column = parentColumn;
    [request setCompletionBlock:^(NSArray *array) {
        
        NSMutableArray *muArray = [[NSMutableArray alloc] initWithArray:array];
        NSString *strAllColumns = [NSString stringWithFormat:@""];
        if (array.count != 0) {
            for (int i = 0; i < array.count; i++) {
                Column *column = [array objectAtIndex:i];
                //是否显示该栏目
                if (column.showcolumn) {
                    [muArray removeObject:column];
                }
                else{
                    strAllColumns = [strAllColumns stringByAppendingString:[NSString stringWithFormat:@"%d,", column.columnId]];
                }
            }
        }
        NSArray *arrayLast = [[NSArray alloc] initWithArray:muArray];
        NSString *lastColumns = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lastColumnIDs-%d", parentColumn.columnId]];
        if (lastColumns && [strAllColumns compare:lastColumns] != NSOrderedSame) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
        }
        allcolumns = [[NSMutableArray alloc] initWithArray:arrayLast];
        columns = [[NSMutableArray alloc] initWithArray:arrayLast];
        
        [self updateColumns];
        [self loadColumnsFinished];
        if (strAllColumns) {
            [[NSUserDefaults standardUserDefaults] setObject:strAllColumns forKey:[NSString stringWithFormat:@"lastColumnIDs-%d", parentColumn.columnId]];
        }
    }];
    
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"load Columns failed: %@", error);
        [self loadColumnsFailed];
        
    }];
    [request startAsynchronous];
}

- (void)updateColumns{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefaultes dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
    NSString *dicString = [NSString stringWithFormat:@"%@",[dictionary valueForKey:[NSString stringWithFormat:@"%d", parentColumn.columnId]]];
    NSString *strValue = @"";
    if (dictionary == nil||[dicString isEqualToString:@""]||[dicString isEqualToString:@"(null)"]){
        
        NSMutableArray *selectedColumns = [[NSMutableArray alloc] initWithCapacity:[self.allcolumns count]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
        if ([selectedColumns count] == 0){
            
            for(int i = 0; i < [self.allcolumns count]; i++){
                Column *column = self.allcolumns[i];
                if(column.keyword[@"showInMore"] == nil){
                    [selectedColumns addObject:self.allcolumns[i]];
                    if ([strValue isEqualToString:@""])
                        strValue = [NSString stringWithFormat:@"%d",column.columnId];
                    else
                        strValue = [NSString stringWithFormat:@"%@,%d",strValue, column.columnId];
                }
            }
        }
        else{
            
            for(int i = 0; i < [selectedColumns count]; i++){
                
                Column *column = selectedColumns[i];
                if ([strValue isEqualToString:@""])
                    strValue = [NSString stringWithFormat:@"%d", column.columnId];
                else
                    strValue = [NSString stringWithFormat:@"%@,%d",strValue, column.columnId];
            }
        }
        
        NSDictionary *dictionary = [userDefaults dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
        if ([dictionary count] > 0)
            [mutableDictionary addEntriesFromDictionary:dictionary];
        
        [mutableDictionary setObject:strValue forKey:[NSString stringWithFormat:@"%d",parentColumn.columnId]];
        [userDefaults setObject:mutableDictionary forKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
        [userDefaults synchronize];
        
        if ([selectedColumns count] > 0)
            self.columns = selectedColumns;
        else
            self.columns = self.allcolumns;
    }
    else
    {
        NSArray *selectedArray = [dicString componentsSeparatedByString:@","];
        NSMutableArray *selectedColumns = [[NSMutableArray alloc] init];
        for(int y = 0; y < [selectedArray count]; y++){
            for(int x = 0; x < [self.allcolumns count]; x++) {
                
                Column *column = [self.allcolumns objectAtIndex:x];
                if ([[NSString stringWithFormat:@"%d",column.columnId] isEqualToString: [NSString stringWithFormat:@"%@",selectedArray[y]]]){
                    [selectedColumns addObject:self.allcolumns[x]];
                    break;
                }
            }
        }
        
        /* 取出并记录订阅的栏目ID信息 */
        strValue = @"";
        for(int i = 0;i < [selectedColumns count]; i++)
        {
            Column *column = selectedColumns[i];
            if ([strValue isEqualToString:@""])
                strValue = [NSString stringWithFormat:@"%d", column.columnId];
            else
                strValue = [NSString stringWithFormat:@"%@,%d",strValue, column.columnId];
            
        }
        strValue = [NSString stringWithFormat:@"%@,", strValue];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
        NSDictionary *dictionary = [userDefaults dictionaryForKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
        if ([dictionary count]>0)
            [mutableDictionary addEntriesFromDictionary:dictionary];
        
        [mutableDictionary setObject:strValue forKey:[NSString stringWithFormat:@"%d",parentColumn.columnId]];
        [userDefaults setObject:mutableDictionary forKey:[NSString stringWithFormat:@"columnsOrder-%d", parentColumn.columnId]];
        [userDefaults synchronize];
        self.columns = selectedColumns;
    }
    /* 记录所有的栏目ID信息 */
    strValue = @"";
    for(int i = 0; i < [self.allcolumns count]; i++)
    {
        Column *column = self.allcolumns[i];
        if ([strValue isEqualToString:@""])
            strValue = [NSString stringWithFormat:@"%d",column.columnId];
        else
            strValue = [NSString stringWithFormat:@"%@,%d",strValue, column.columnId];
    }
    
    NSUserDefaults *userDefaultsAll = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * mutableDictionaryAll = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSDictionary *dictionaryAll = [userDefaultsAll dictionaryForKey:[NSString stringWithFormat:@"columnsOrderAll-%d", parentColumn.columnId]];
    if ([dictionaryAll count] > 0)
        [mutableDictionaryAll addEntriesFromDictionary:dictionaryAll];//向字典对象中添加其他整个字典对象
    
    [mutableDictionaryAll setObject:strValue forKey:[NSString stringWithFormat:@"%d",parentColumn.columnId]];
    [userDefaultsAll setObject:mutableDictionaryAll forKey:[NSString stringWithFormat:@"columnsOrderAll-%d", parentColumn.columnId]];
    
    [userDefaultsAll synchronize];
}

#pragma  mark - 获取栏目后回调到子类

- (void)loadColumnsFinished
{

}

- (void)loadColumnsFailed
{
    
}

#pragma mark - 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)left
{
    [self.sideBar show];
    return;
}
@end
