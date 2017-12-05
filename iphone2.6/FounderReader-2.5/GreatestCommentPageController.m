//
//  GreatestCommentPageController.m
//  FounderReader-2.5
//
//  Created by ld on 14-8-1.
//
//
#import "CommentViewControllerGuo.h"
#import "GreatestCommentPageController.h"
#import "CommentCell.h"
#import "CommentConfig.h"
#import "Comment.h"
#import "GreatestCommentCell.h"
#import "AppStartInfo.h"
#import "UIDevice-Reachability.h"
#import "HttpRequest.h"
#import "UserAccountDefine.h"
#import "YXLoginViewController.h"
#import "ChangeUserInfoController.h"
#import "UserAccountDefine.h"
#import "FCReader_OpenUDID.h"
#import "CommentConfig.h"
#import "UIImageView+WebCache.h"
#import "MoreCell.h"
#import "UIView+Extention.h"
#import "ColumnBarConfig.h"
#import "NewsListConfig.h"
#define SUMNumber 0
#define freeW 10

#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]
@interface GreatestCommentPageController ()
@property(nonatomic,assign)NSInteger parentID;
@property (nonatomic, strong) UIImageView *hudImageView;
@property (nonatomic, strong) UILabel *hudLable;
@end

@implementation GreatestCommentPageController

- (void)viewWillAppear:(BOOL)animate{
    
    [super viewWillAppear:animate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"ReloadCommentTableViewDate" object:nil];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)reloadTableView
{
    
    [self loadComments:YES];
    [self getCommentHot:YES];
    if (self.isHaveNewComment) {
        _hudView.hidden = YES;
    }
}


#pragma mark - UITableViewDataSource
// 分组个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!comments.count && !self.commentsHot.count)
    {
        return 1;
    }

    else if(comments.count && self.commentsHot.count)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    }
    else
    {
        if (cell.tag == 9995) {
            if ([cell respondsToSelector:@selector(showIndicator)]) {
                [(MoreCell *)cell showIndicator];
            }
            [self loadMoreComments];
        }
        
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    listMoreCount = 10;
    [self reloadTableView];
}
// 评论列表的滑动
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseUpAndDownView" object:nil];
    return self.reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    
    return [NSDate date]; // should return date data source was last changed
}


// 自定义头视图标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
    return @"自定义Section需要调用此方法";
}
// cell个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!comments.count && !self.commentsHot.count)
    {
        return 1;
    }

    else
    {
        if (comments.count && self.commentsHot.count) {
            if (section)
            {
                return [comments count] + hasMore;
            }
            else
            {
                return MIN(5, self.commentsHot.count);
            }
        }
        else if (comments.count && !self.commentsHot.count) {
            return [comments count] + hasMore;
        }
        else if (!comments.count && self.commentsHot.count) {
            return MIN(5, self.commentsHot.count);
        }
    }
    return 1;
}
- (void)showHudView
{
    _hudView.hidden = NO;
}
// 自定义cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark 评论table
    // 最新评论和最热评论都不存在
    if (!comments.count && !self.commentsHot.count) {
        
        UITableViewCell *promptCell = [tableView dequeueReusableCellWithIdentifier:@"promptCell"];
        if (!promptCell)
            promptCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"promptCell"];
        
        promptCell.textLabel.textAlignment = NSTextAlignmentCenter;
        if (tableView == self.tableView) {
            CGFloat hudViewW = self.tableView.centerY-(self.hudView.height/2);
            if (IS_IPHONE_6P) {
                self.hudView.frame = CGRectMake(0,hudViewW, kSWidth, 120);
            }
            else if (IS_IPHONE_6)
            {
                self.hudView.frame = CGRectMake(0,hudViewW, kSWidth, 120);
            }
            else
            {
                self.hudView.frame = CGRectMake(0,hudViewW, kSWidth, 120);
            }
            self.hudView.hidden = NO;
            [self.hudView addSubview:self.hudImageView];
            [self.hudView addSubview:self.hudLable];
            [promptCell addSubview:self.hudView];
            
            promptCell.selectedBackgroundView = nil;
            promptCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.tableView.showsVerticalScrollIndicator = NO;
            //            [self performSelector:@selector(showHudView) withObject:nil afterDelay:1];
        }
        return promptCell;
    }
    self.tableView.showsVerticalScrollIndicator = YES;
    CommentCell *cell = nil;
    Comment *comment = nil;
    // 同时存在最新评论和最热评论
    if (comments.count && self.commentsHot.count) {
        //最新评论
        if (indexPath.section == 1)
        {
            if (indexPath.row == [comments count]) {
                if (indexPath.row == [comments count]) {
                    MoreCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
                    if (cell == nil)
                        cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
                    
                    cell.tag = 9995;
                    [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
                    return cell;
                }
            }
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"GreatCommentCell"];
            if (cell == nil)
            {
                cell = [[GreatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GreatCommentCell"];
            }
            
            comment = [comments objectAtIndex:indexPath.row];
            if (comment.content == nil) {
                comment.content = @" ";
                
            }
            if(comment.userIcon != nil)
            {
                [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:comment.userIcon] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
            }

            if (comment.ueserID == 0 && (self.article.articleType != ArticleType_TOPICPLUS ||self.article.articleType != ArticleType_QAAPLUS)) {
                [cell.userPhoto setUrlString:[AppStartInfo sharedAppStartInfo].officialIcon placeholderImage:@"me_icon_head-app"];
            }
            cell.timeLabel.text = intervalSinceNow(comment.commentTime);
            cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount];
            cell.greatButton.tag = indexPath.row + 10;
            
            
            
            // 点赞
            BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
            if (bestId == 0)
            {
                cell.greatButton.enabled = YES;
                [cell.greatButton addTarget:self action:@selector(greatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
            }
            if (bestId != 0)
            {
                cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount + 1];

                cell.greatButton.enabled = YES;
                cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
            }
            
        }
        else
        {
            //热门评论
            cell = [tableView dequeueReusableCellWithIdentifier:@"GreatHotCommentCell"];
            if (cell == nil)
                cell = [[GreatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GreatHotCommentCell"];
            
            
            if (self.commentsHot.count > indexPath.row) {
                comment = [self.commentsHot objectAtIndex:indexPath.row];
            }
            
            if(comment.userIcon != nil)
            {
                [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:comment.userIcon] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
            }
            if (comment.ueserID == 0 && (self.article.articleType != ArticleType_TOPICPLUS ||self.article.articleType != ArticleType_QAAPLUS)) {
                [cell.userPhoto setUrlString:[AppStartInfo sharedAppStartInfo].officialIcon placeholderImage:@"me_icon_head-app"];
            }
            cell.timeLabel.text = intervalSinceNow(comment.commentTime);
            // 点赞
            cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount];
            cell.greatButton.tag = indexPath.row;
            
            BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
            if (bestId == 0)
            {
                cell.greatButton.enabled = YES;
                [cell.greatButton addTarget:self action:@selector(greatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
            }else{
                cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount + 1];

                cell.greatButton.enabled = YES;
                cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
            }
            
        }
        
    }
    //只有最新评论
    else if(comments.count && !self.commentsHot.count)
    {
        //最新评论
        if (indexPath.row == [comments count]) {
            if (indexPath.row == [comments count]) {
                MoreCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
                if (cell == nil)
                    cell = [[MoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
                
                cell.tag = 9995;
                [cell configWithTitle:@"" summary:@"" date:@"" thumbnailUrl:@"" columnId:0];
                return cell;
            }
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"GreatCommentCell"];
        if (cell == nil)
        {
            cell = [[GreatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GreatCommentCell"];
        }
        
        comment = [comments objectAtIndex:indexPath.row];
        if (comment.content == nil) {
            comment.content = @" ";
            
        }
        
        
        if(comment.userIcon != nil)
        {
            [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:comment.userIcon] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
        }
        if (comment.ueserID == 0 && (self.article.articleType != ArticleType_TOPICPLUS ||self.article.articleType != ArticleType_QAAPLUS)) {
            [cell.userPhoto setUrlString:[AppStartInfo sharedAppStartInfo].officialIcon placeholderImage:@"me_icon_head-app"];
        }
        cell.timeLabel.text = intervalSinceNow(comment.commentTime);
        cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount];
        cell.greatButton.tag = indexPath.row + 10;
        
        
        
        // 点赞
        BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
        if (bestId == 0)
        {
            cell.greatButton.enabled = YES;
            [cell.greatButton addTarget:self action:@selector(greatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
        }
        if (bestId != 0)
        {
            cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount + 1];
            cell.greatButton.enabled = YES;
            cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
        }
    }
    //只有最热评论
    else if(!comments.count && self.commentsHot.count)
    {
        //热门评论
        cell = [tableView dequeueReusableCellWithIdentifier:@"GreatHotCommentCell"];
        if (cell == nil)
            cell = [[GreatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GreatHotCommentCell"];
        
        
        if (self.commentsHot.count > indexPath.row) {
            comment = [self.commentsHot objectAtIndex:indexPath.row];
        }
        
        if(comment.userIcon != nil)
        {
            [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:comment.userIcon] placeholderImage:[UIImage imageNamed:@"me_icon_head-app"]];
        }
        if (comment.ueserID == 0 && (self.article.articleType != ArticleType_TOPICPLUS ||self.article.articleType != ArticleType_QAAPLUS)) {
            [cell.userPhoto setUrlString:[AppStartInfo sharedAppStartInfo].officialIcon placeholderImage:@"me_icon_head-app"];
        }
        cell.timeLabel.text = intervalSinceNow(comment.commentTime);
        // 点赞
        cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount];
        cell.greatButton.tag = indexPath.row;
        
        BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
        if (bestId == 0)
        {
            cell.greatButton.enabled = YES;
            [cell.greatButton addTarget:self action:@selector(greatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_normal"];
        }else{
            cell.greatCountLabel.text = [NSString stringWithFormat:@"%ld",(long)comment.greatCount + 1];
            cell.greatButton.enabled = YES;
            cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];
        }
    }
    
    CGFloat contentY = CGRectGetMaxY(cell.timeLabel.frame) + 10;
    CGFloat contentW = kSWidth - cell.userNameLabel.x - freeW;
    // 子评论内容
    cell.contentLabel.numberOfLines = 0;
    CGFloat height = [self getAttributeTextHight:comment.content andWidth:contentW];
    cell.contentLabel.attributedText = [self getAttributeText:comment.content andWidth:contentW];
    cell.contentLabel.frame = CGRectMake(CGRectGetMaxX(cell.userPhoto.frame)+9, contentY, contentW, height);
    
    if (comment.parentID != -1 && comment.parentID != 0) {
        // 父评论的用户名
        CGFloat userNameParentY = contentY + height + 10;
        cell.userNameParentLabel.frame = CGRectMake(CGRectGetMaxX(cell.userPhoto.frame)+9+freeW, userNameParentY+freeW, contentW-freeW, 20);
        cell.userNameParentLabel.text = comment.parentUserName;
        
        // 父评论的内容
        cell.contentParentLabel.numberOfLines = 0;
        CGFloat contentParentY = userNameParentY + 20 + 10;
        CGFloat contentParentHeight = [self getAttributeTextHight:comment.parentContent andWidth:contentW-freeW];
        cell.contentParentLabel.attributedText = [self getAttributeText:comment.parentContent andWidth:contentW-freeW];
        cell.contentParentLabel.frame = CGRectMake(CGRectGetMaxX(cell.userPhoto.frame)+9+freeW, contentParentY+freeW, contentW-freeW, contentParentHeight);
        
        cell.blackView.frame = CGRectMake(CGRectGetMaxX(cell.userPhoto.frame)+9, userNameParentY, contentW, contentParentHeight+30+2*freeW);
        cell.userNameParentLabel.hidden = NO;
        cell.contentParentLabel.hidden = NO;
        cell.blackView.hidden = NO;
    }
    else
    {
        cell.userNameParentLabel.hidden = YES;
        cell.contentParentLabel.hidden = YES;
        cell.blackView.hidden = YES;
    }
    cell.timeLabel.text = intervalSinceNow(comment.commentTime);
    NSString *regex = @"(^1[3-9][0-9]{9})";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:comment.userName];
    if (isMatch) {
        NSMutableString *userName = [[NSMutableString  alloc] initWithString:comment.userName];
        [userName replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        cell.userNameLabel.text = userName;
    }else
    {
        cell.userNameLabel.text = comment.userName.length == 0 ? [CommentConfig sharedCommentConfig].defaultNickName : comment.userName;
    }
    
    if (indexPath.row==0) {
        cell.sep.hidden = YES;
    }else
        cell.sep.hidden = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = nil;
    if (indexPath.section == 0 && self.commentsHot.count) {
        comment = self.commentsHot[indexPath.row];
        self.parentID = comment.ID;
    }
    else if((indexPath.section == 1 || indexPath.section == 0)&& comments.count)
    {
        if (indexPath.row == [comments count]) {
            return;
        }
        comment = comments[indexPath.row];
        self.parentID = comment.ID;
    }
    else if(!comments.count && !self.commentsHot.count)
    {
        return;
    }
    //回复评论
    [self ForumWriteCommentandComment:comment];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hight = 0;
    Comment *comment = nil;
    if (comments.count && self.commentsHot.count) {
        // 最热评论
        if (indexPath.section == 0) {
            if (!self.commentsHot.count)
            {
                return 60;
            }
            if (indexPath.row == [self.commentsHot count])
            {
                return [CommentConfig sharedCommentConfig].moreCellHeight;
            }
            
            comment = [self.commentsHot objectAtIndex:indexPath.row];
        }
        else //最新评论
        {
            if (!comments.count)
            {
                return 60;
            }
            if (indexPath.row == [comments count])
            {
                return [CommentConfig sharedCommentConfig].moreCellHeight;
            }
            comment = [comments objectAtIndex:indexPath.row];
        }
    }
    if (comments.count && !self.commentsHot.count) {
        //最新评论
        {
            if (!comments.count)
            {
                return 60;
            }
            if (indexPath.row == [comments count])
            {
                return [CommentConfig sharedCommentConfig].moreCellHeight;
            }
            comment = [comments objectAtIndex:indexPath.row];
        }
    }
    if (!comments.count && self.commentsHot.count) {
        // 最热评论
        {
            if (!self.commentsHot.count)
            {
                return 60;
            }
            if (indexPath.row == [self.commentsHot count])
            {
                return [CommentConfig sharedCommentConfig].moreCellHeight;
            }
            
            comment = [self.commentsHot objectAtIndex:indexPath.row];
        }
    }
    if (!comments.count && !self.commentsHot.count) {
        return tableView.height;
    }
    
    CGFloat comHeight=[self getAttributeTextHight:comment.content andWidth:kSWidth-25-3*freeW];
    CGFloat comParent=[self getAttributeTextHight:comment.parentContent andWidth:kSWidth-25-3*freeW];
    float height = comHeight + 18+35+15+5;
    if (comment.parentID != -1 && comment.parentID != 0)
        return height+hight+20 +comParent + 10 + 3*freeW;
    else
        return height + hight;
    
    return 100;
}

/**
 *  获取评论的高度
 *
 *  @param textStr 字符串内容
 *  @param width   最大宽度
 *
 *  @return 字符串高度
 */
- (CGFloat)getAttributeTextHight:(NSString *)textStr andWidth:(CGFloat)width
{
    if (textStr == nil || [textStr isEqual:[NSNull null]]) {
        textStr = @" ";
        
    }
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4.0f];
    CGFloat fontSize = kSWidth > 375 ? 17 : 13;
    
    NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:fontSize]};
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
    CGSize size = CGSizeMake(kSWidth-25-3*freeW, 900);
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attStr.length)];
    label.attributedText = attStr;
    CGSize labelSize = [label sizeThatFits:size];
    
    return labelSize.height;
}

/**
 *  获取评论的回复高度
 *
 *  @param name    回复用户名
 *  @param commnet 回复内容
 *  @param time    回复时间
 *
 *  @return 字符串高度
 */
- (CGFloat )setUsername:(NSString *)name WithComment:(NSString *)commnet WithTime:(NSString *)time{
    time = [time substringWithRange:NSMakeRange(5, 11)];
    //拼接的一个字符串
    NSString *tempStr = @"";
    tempStr = [NSString stringWithFormat:@"%@:  ",name];
    tempStr = [tempStr stringByAppendingString:commnet];
    tempStr = [tempStr stringByAppendingString:@"      "];
    tempStr = [tempStr stringByAppendingString:time];
    NSInteger FontSize ;
    if (IS_IPHONE_6P) {
        FontSize = 16;
    }else if (IS_IPHONE_6){
        FontSize = 16;
    }else
        FontSize = 12;
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    NSRange nameRange = NSMakeRange(0, [[noteStr string] rangeOfString:@":"].location + 1);
    NSRange commentRange = NSMakeRange(nameRange.location + nameRange.length , [[noteStr string] rangeOfString:commnet].length + 2 );
    NSRange timeRange =NSMakeRange(commentRange.location + commentRange.length +6, [[noteStr string] rangeOfString:time].length );
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize] range:nameRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value: [UIColor colorWithRed:20/255.0 green:123/255.0 blue:227/255.0 alpha:1.0] range:nameRange];
    
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize] range:commentRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] range:commentRange];
    
    [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize-3] range:timeRange];
    [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] range:timeRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 字体的行间距
    paragraphStyle.lineSpacing = 4*proportion;
    [noteStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, noteStr.length)];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize], NSFontAttributeName,nil];
    CGSize commentUserSize = [tempStr boundingRectWithSize:CGSizeMake(240*proportion, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    if (IS_IPHONE_6P) {
        return commentUserSize.height = 1.25 *commentUserSize.height - 4*proportion ;
    }else if (IS_IPHONE_6){
        return commentUserSize.height = 1.25 *commentUserSize.height - 4*proportion ;
    }else
        return commentUserSize.height = 1.333 *commentUserSize.height - 4*proportion ;
}

/**
 *  将评论内容变为属性字符串
 *
 *  @param textStr 评论内容
 *  @param width   最大宽度
 *
 *  @return 属性字符串
 */
- (NSMutableAttributedString *)getAttributeText:(NSString *)textStr andWidth:(CGFloat)width
{
    if (textStr == nil) {
        textStr = @" ";
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:4.0f];
    CGFloat fontSize = kSWidth > 375 ? 17 : 13;
    NSDictionary *attrsDictionary = @{NSFontAttributeName: [UIFont fontWithName:[Global fontName] size:fontSize]};
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attrsDictionary];
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textStr.length)];
    
    return attStr;
}


#pragma mark - UITableViewDelegate
//@optional 自定义头视图
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.tableView)
    {
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSWidth, 40)];
        headView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 80*kScale, 24)];
        bgView.backgroundColor = [ColumnBarConfig sharedColumnBarConfig].column_all_color;
        bgView.layer.cornerRadius = 12;
        bgView.layer.masksToBounds = YES;
        [headView addSubview:bgView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12*kScale, 2, 60*kScale, 20)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:14*kScale];
        titleLabel.backgroundColor = [UIColor clearColor];
        [bgView addSubview:titleLabel];
        
        UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newsList_separator"]];
        lineView.frame = CGRectMake(CGRectGetMaxX(bgView.frame), bgView.centerY-0.4, kSWidth-CGRectGetMaxX(bgView.frame)+3, 0.5);
        [headView addSubview:lineView];
        
        headView.hidden = NO;
        tableView.bounces = YES;
        if (comments.count && self.commentsHot.count)
        {
            if (section)
            {
                titleLabel.text = NSLocalizedString(@"最新评论",nil);
            }
            else
            {
                titleLabel.text = NSLocalizedString(@"热门评论",nil);
            }
        }
        else if(comments.count && !self.commentsHot.count)
        {
            titleLabel.text = NSLocalizedString(@"最新评论",nil);
        }
        else if(!comments.count && self.commentsHot.count)
        {
            
            titleLabel.text = NSLocalizedString(@"热门评论",nil);
            
        }
        else if (!comments.count && !self.commentsHot.count)
        {
            headView.hidden = YES;
            tableView.bounces = NO;
        }
        return headView;

    }
    else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!comments.count && !self.commentsHot.count) {
        return 0;
    }
    return 43;
}

/**
 *  点赞动画
 */
-(void)greatAnimate:(UIButton *)sender
{
    
    CGRect rect = CGRectMake(kSWidth-50, 10, 23, 23);
    
    UITableViewCell *cell = nil;
    if(iOSVersion >= 7.0 && iOSVersion < 8.0)
    {
        cell = (UITableViewCell *)sender.superview.superview;
    }
    else if(iOSVersion >= 8.0)
    {
        cell = (UITableViewCell *)sender.superview;
    }

    UILabel *label_great = [[UILabel alloc]initWithFrame:rect];
    label_great.font = [UIFont boldSystemFontOfSize:16];
    label_great.textColor = [UIColor colorWithRed:0x13/255.0 green:0xAF/255.0 blue:0xFD/255.0 alpha:1];
    label_great.text = @"+1";
    label_great.alpha = 1;
    [cell addSubview:label_great];

    [UIView beginAnimations:@"great" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    
    label_great.frame = CGRectMake(rect.origin.x
                                   , rect.origin.y-30,
                                   rect.size.width,
                                   rect.size.height);
    label_great.alpha = 0;
    [UIView commitAnimations];
}

#pragma mark - cell中button点击事件
/**
 *  点赞
 */
-(void)greatButtonClicked:(UIButton *)sender
{
    [self commentPraise:sender];
}
-(void)commentPraise:(UIButton *)sender
{
    Comment *comment = nil;
    NSIndexPath *index = nil;
    
    
    UITableViewCell *cell = nil;
    if(iOSVersion >= 7.0 && iOSVersion < 8.0)
    {
        cell = (UITableViewCell *)sender.superview.superview;
    }
    else if(iOSVersion >= 8.0)
    {
        cell = (UITableViewCell *)sender.superview;
    }
    index = [self.tableView indexPathForCell:cell];

    if (comments.count && self.commentsHot.count) {
        if (index.section == 0 && self.commentsHot.count)
        {
            comment = [self.commentsHot objectAtIndex:index.row];
        }
        else if(index.section == 1 && comments.count)
        {
            comment = [comments objectAtIndex:index.row];
        }
    }
    else if (comments.count && !self.commentsHot.count)
    {
        comment = [comments objectAtIndex:index.row];
    }
    else if (!comments.count && self.commentsHot.count)
    {
        comment = [self.commentsHot objectAtIndex:index.row];
    }
    
    BOOL bestId = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
    if (bestId == 0)
    {
        [self greatAnimate:sender];
        [self updateGreatCount:comment indexPath:index];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%ld",(long)comment.ID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)showLoginPage
{
    YXLoginViewController *controller = [[YXLoginViewController alloc]init];
    controller.isNavBack = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 *  更新点赞数
 *
 *  @param comment   被点赞的评论
 *  @param indexPath 该评论的索引
 */
- (void)updateGreatCount:(Comment *)comment indexPath:(NSIndexPath *)indexPath
{
    if (![UIDevice networkAvailable]) {
        
        [Global showTipNoNetWork];
        return;
    }
    CommentCell *cell = (CommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *str = cell.greatCountLabel.text;
    cell.greatCountLabel.text = [NSString stringWithFormat:@"%d",(int)[str integerValue]+1];
    cell.handIconImageView.image = [UIImage imageNamed:@"btn_comment_press"];

    NSString *urlString = [NSString stringWithFormat:@"%@/api/event", [AppConfig sharedAppConfig].serverIf];
    NSString *bodyString = [NSString stringWithFormat:@"sid=%@&id=%ld&type=1&eventType=2",[AppConfig sharedAppConfig].sid,(long)comment.ID];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpRequest *request = [HttpRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setCompletionBlock:^(NSData *data)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:nil];
        NSString *str = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"countPraise"] intValue]];
        if (str != nil && ![str isEqualToString:@""])
        {
            [self updateGreatCountLabel:indexPath];
        }
        
    }];
    [request setFailedBlock:^(NSError *error) {
        XYLog(@"点赞失败: %@", error);
    }];
    [request startAsynchronous];
}
-(void)updateGreatCountLabel:(NSIndexPath *)indexPath
{
    //cell复用更新
    Comment *comment = nil; 
    if (indexPath.section) {
        comment = [comments objectAtIndex:indexPath.row];
        ++comment.greatCount;
        [comments replaceObjectAtIndex:indexPath.row withObject:comment];
    }
    else{

        comment = [comments objectAtIndex:indexPath.row];
        ++comment.greatCount;
        [comments replaceObjectAtIndex:indexPath.row withObject:comment];

    }
}




/**
 *  对评论进行回复
 *
 *  @param comment 该评论的模型
 */
- (void)ForumWriteCommentandComment:(Comment *)comment
{
    
    CommentViewControllerGuo *commentVC = [[CommentViewControllerGuo alloc] init];
    commentVC.current = 0;
    commentVC.fullColumn = self.fullColumn;
    if(article.articleType == ArticleType_LIVESHOW)
        commentVC.rootID = article.linkID;
    else
        commentVC.rootID = article.fileId;
    commentVC.article = article;
    if (self.parentID == 0) {
        self.parentID = article.fileId;
        if(article.articleType == ArticleType_LIVESHOW)
            self.parentID = article.fileId;
        else
            self.parentID = article.linkID;
    }
    commentVC.commentID = self.parentID;
    commentVC.urlStr = [NSString stringWithFormat:@"%@/api/submitComment",[AppConfig sharedAppConfig].serverIf];
    commentVC.isPDF = self.isPdfComment;
    [appDelegate().window addSubview:commentVC.view];
    [self addChildViewController:commentVC];
    [self addChildViewController:commentVC];
}

#pragma mark - 懒加载控件
- (UIView *)hudView {
    if (!_hudView) {
        _hudView = [[UIView alloc] init];
        _hudView.hidden = NO;
    }
    return _hudView;
}
- (UIImageView *)hudImageView {
    if (!_hudImageView) {
        _hudImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"holdIMG"]];
        _hudImageView.frame = CGRectMake((kSWidth-50)/2, 0, 50, 50);
        [self.hudView addSubview:_hudImageView];
    }
    return _hudImageView;
}
- (UILabel *)hudLable {
    if (!_hudLable) {
        _hudLable = [[UILabel alloc] init];
        
        _hudLable.frame = CGRectMake(0, 60, kSWidth, 50);
        _hudLable.text = NSLocalizedString(@"暂时还没有任何评论哦！",nil);
        _hudLable.textColor = [UIColor grayColor];
        _hudLable.textAlignment = NSTextAlignmentCenter;
        _hudLable.font = [UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize];
        
    }
    return _hudLable;
}
@end
