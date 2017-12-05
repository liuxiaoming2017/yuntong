//
//  BookSqlInterface.h
//  DataLib
//
//  Created by chenfei on 4/10/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "Journal0.h"
#import "Book.h"

#define kBOOKDBName @"book"
#define kBOOKDBExtension @"db"

@interface BookSqlInterface : NSObject
@property(nonatomic, retain) FMDatabase *db;

+ (id)sharedBookSqlInterface;

// 更新刊物表
- (void)updateJournal:(Journal0 *)journal;
// 刊物数
- (int)journalCount;
// 删除所有刊物
- (void)deleteJournals;
// 更新期刊表
- (void)updateIssue:(Book *)book;
// 更新期刊状态
- (void)updateIssueStatus:(BookStatusType)status withIssueId:(int)issueId;
// 删除期刊
- (void)deleteIssue:(Book *)book;
// 删除未下载的期刊
- (void)deleteNoDownloadedIssues;
// 删除刊物
- (void)deleteJournal:(Journal0 *)journal;
// 所有刊物
- (NSArray *)journals;
// 某刊物下所有期刊
- (NSArray *)issues:(int)jid;
// 返回指定期刊
- (Book *)bookWithIssueId:(int)issueId;
// 某刊物下某状态的期刊数
- (int)issueCountInJournal:(int)jid issueStatus:(int)status;

@end
