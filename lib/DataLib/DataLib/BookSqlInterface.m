//
//  BookSqlInterface.m
//  DataLib
//
//  Created by chenfei on 4/10/13.
//  Copyright (c) 2013 chenfei. All rights reserved.
//

#import "BookSqlInterface.h"

static BookSqlInterface *_book_sql_interface_ = nil;

@implementation BookSqlInterface
@synthesize db;

- (void)dealloc
{
    [db close];
    [db release];
    
    [super dealloc];
}

+ (id)sharedBookSqlInterface
{
    if (_book_sql_interface_ == nil)
        _book_sql_interface_ = [[self alloc] init];
    return _book_sql_interface_;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:kBOOKDBName ofType:kBOOKDBExtension];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [paths objectAtIndex:0];
        NSString *dstDBPath = [cacheDirPath stringByAppendingPathComponent:@"publishingInfo.db"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dstDBPath])
            [[NSFileManager defaultManager] copyItemAtPath:dbPath toPath:dstDBPath error:0];
        self.db = [FMDatabase databaseWithPath:dstDBPath];
        [self.db open];
    }
    return self;
}

- (void)deleteJournals
{
    [db executeUpdate:@"delete from Journal"];
}

- (void)updateJournal:(Journal0 *)journal
{
    FMResultSet *set = [db executeQuery:@"select JournalID from Journal where JournalID = ?", [NSNumber numberWithInt:journal.journalID]];
    if ([set next])
        [db executeUpdate:@"update Journal set JournalName = ? where JournalID = ?", journal.journalName, [NSNumber numberWithInt:journal.journalID]];
    else
        [db executeUpdate:@"insert into Journal (JournalID, JournalName) values (?, ?)", [NSNumber numberWithInt:journal.journalID], journal.journalName];
    [set close];
}

- (int)journalCount
{
    FMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM Journal"];
    if ([set next])
        return [set intForColumnIndex:0];
    return 0;
}

- (void)updateIssue:(Book *)book
{
    FMResultSet *set = [db executeQuery:@"select IssueProductID from Issue where IssueProductID = ?", [NSNumber numberWithInt:book.issueID]];
    if ([set next])
        [db executeUpdate:@"update Issue set IssueProductID = ?, IssueNumber = ?, IssueCoverPath_Medium = ?, IssueDataSize = ?, IssuePreviewpagesPath = ?, IssuePublishDate = ?, IssueStatus = 1,IssueIsOnSale = 1 where IssueProductID = ?",
         [NSNumber numberWithInt:book.journalID], book.issueName, book.coverPath_Medium, [NSNumber numberWithLong:book.dataPackageSize], book.dataPackageURL, [NSNumber numberWithLongLong:book.publishedDate], [NSNumber numberWithInt:book.issueID]];
    else
        [db executeUpdate:@"insert into Issue (IssueProductID, JournalID, IssueNumber, IssueCoverPath_Medium, IssueDataSize, IssuePreviewpagesPath, IssuePublishDate, IssueStatus, IssueIsOnSale) values (?, ?, ?, ?, ?, ?, ?, ?, 1)",
         [NSNumber numberWithInt:book.issueID], [NSNumber numberWithInt:book.journalID], book.issueName, book.coverPath_Medium, [NSNumber numberWithLong:book.dataPackageSize], book.dataPackageURL, [NSNumber numberWithLongLong:book.publishedDate], [NSNumber numberWithInt:book.status]];
    [set close];
}

- (void)updateIssueStatus:(BookStatusType)status withIssueId:(int)issueId
{
    [db executeUpdate:@"update Issue set IssueStatus = ? where IssueProductID = ?", [NSNumber numberWithInt:status], [NSNumber numberWithInt:issueId]];
}

//- (void)updateJournalIssueWithJID:(NSString *)jid andIssueID:(NSString *)issueID
//{
//    FMResultSet *set = [db executeQuery:@"select j_id from journal_issue where j_id = ?", jid];
//    if ([set next])
//        [db executeUpdate:@"update journal_issue set i_id = ? where j_id = ?", issueID, jid];
//    else
//        [db executeUpdate:@"insert into journal_issue (j_id, i_id) values (?, ?)", jid, issueID];
//    [set close];
//}

- (void)deleteIssue:(Book *)book
{
    [db executeUpdate:@"delete from Issue where IssueProductID = ?", [NSNumber numberWithInt:book.issueID]];
}

- (void)deleteNoDownloadedIssues
{
    [db executeUpdate:@"delete from Issue where IssueStatus = ?", [NSNumber numberWithInt:kBookStatusTypePurchace]];
}

- (void)deleteJournal:(Journal0 *)journal
{
    [db executeUpdate:@"delete from Journal where JournalID = ?", [NSNumber numberWithInt:journal.journalID]];
}

- (NSArray *)journals
{
    NSMutableArray *journals = [[NSMutableArray alloc] init];
    FMResultSet *set = [db executeQuery:@"select JournalID, JournalName from Journal"];
    while ([set next]) {
        Journal0 *journal = [[Journal0 alloc] init];
        journal.journalID = [set intForColumn:@"JournalID"];
        journal.journalName = [set stringForColumn:@"JournalName"];
        [journals addObject:journal];
        [journal release];
    }
    [set close];
    return [journals autorelease];
}

- (NSArray *)issues:(int)jid
{
    NSMutableArray *issues = [[NSMutableArray alloc] init];
    FMResultSet *set = [db executeQuery:@"select IssueProductID, IssueNumber, IssueCoverPath_Medium, IssueDataSize, IssuePreviewpagesPath, IssuePublishDate, IssueStatus, IssueIsOnSale from Issue where JournalID = ?", [NSNumber numberWithInt:jid]];
    while ([set next]) {
        int isOnSale = [set intForColumn:@"IssueIsOnSale"];
        if (isOnSale) {
            Book *book = [[Book alloc] init];
            book.issueID = [set intForColumn:@"IssueProductID"];
            book.issueName = [set stringForColumn:@"IssueNumber"];
            book.coverPath_Medium = [set stringForColumn:@"IssueCoverPath_Medium"];
            book.dataPackageSize = [set intForColumn:@"IssueDataSize"];
            book.dataPackageURL = [set stringForColumn:@"IssuePreviewpagesPath"];
            book.publishedDate = [set longForColumn:@"IssuePublishDate"];
            book.status = [set intForColumn:@"IssueStatus"];
            
            [issues addObject:book];
            [book release];
        }
    }
    [set close];
    return [issues autorelease];
}

- (Book *)bookWithIssueId:(int)issueId
{
    Book *book = nil;
    FMResultSet *set = [db executeQuery:@"select IssueProductID, IssueNumber, IssueCoverPath_Medium, IssueDataSize, IssuePreviewpagesPath, IssuePublishDate, IssueStatus from Issue where IssueProductID = ?", [NSNumber numberWithInt:issueId]];
    while ([set next]) {
        book = [[Book alloc] init];
        book.issueID = [set intForColumn:@"IssueProductID"];
        book.issueName = [set stringForColumn:@"IssueNumber"];
        book.coverPath_Medium = [set stringForColumn:@"IssueCoverPath_Medium"];
        book.dataPackageSize = [set intForColumn:@"IssueDataSize"];
        book.dataPackageURL = [set stringForColumn:@"IssuePreviewpagesPath"];
        book.publishedDate = [set longForColumn:@"IssuePublishDate"];
        book.status = [set intForColumn:@"IssueStatus"];
    }
    [set close];
    return [book autorelease];
}

- (int)issueCountInJournal:(int)jid issueStatus:(int)status
{
    FMResultSet *set = [db executeQuery:@"select count(*) from Issue where JournalID = ? and IssueStatus = ?", [NSNumber numberWithInt:jid], [NSNumber numberWithInt:status]];
    if ([set next])
        return [set intForColumnIndex:0];
    return 0;
}

@end
