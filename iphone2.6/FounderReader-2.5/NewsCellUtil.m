//
//  NewsCellUtil.m
//  FounderReader-2.5
//
//  Created by mac on 16/8/2.
//
//

#import "NewsCellUtil.h"
#import "NSString+Helper.h"
#import "NewsListConfig.h"
#import "MiddleCell.h"
#import "GroupImage_MiddleCell.h"
#import "ADadvnadageViewCell.h"
#import "AppConfig.h"
#import "TemplateDetailPageController.h"
#import "ImageDetailPageController.h"
#import "FounderEventRequest.h"
#import "SpecialNewsPageController.h"
#import "TemplateNewDetailViewController.h"
#import "SeeRootViewController.h"
#import "FounderIntegralRequest.h"
#import "CreditSecondViewController.h"
#import "FDQuestionsAndAnwsersPlusDetailViewController.h"
#import "FDAskCommentViewController.h"
#import "VideoCell.h"
#import "VideoTableCell.h"

@implementation NewsCellUtil
//点击cell处理
+(void)clickNewsCell:(Article *)currentAricle column:(Column *)column in:(UIViewController *)viewController{
    
    if(currentAricle == nil)
        return;
    BOOL isNeedScoreAction = YES;//是否需要积分行为
    //普通稿件、视频稿件、活动稿件
    if ((currentAricle.articleType == ArticleType_PLAIN && currentAricle.type == 0) || currentAricle.articleType == ArticleType_VIDEO || currentAricle.articleType ==  ArticleType_ACTIVITY || currentAricle.articleType == ArticleType_QAAPLUS)
    {
        if ([currentAricle.extproperty hasPrefix:@"questionsAndAnswers"] || currentAricle.articleType == ArticleType_QAAPLUS) {
            //互动+
//            TemplateNewDetailViewController *controller = [[TemplateNewDetailViewController alloc] init];
//            currentAricle.shareUrl = [NSString stringWithFormat:@"%@/askPlusColumn?aid=%lld&sid=%@&sc=%@&app=1",[AppConfig sharedAppConfig].serverIf,currentAricle.lastID.longLongValue, [AppConfig sharedAppConfig].sid, [AppConfig sharedAppConfig].sid];
//            currentAricle.contentUrl = [NSString stringWithFormat:@"%@/askPlusColumn?sc=%@&aid=%lld&uid=%@", [AppConfig sharedAppConfig].serverIf, [AppConfig sharedAppConfig].sid,currentAricle.lastID.longLongValue, [Global userId]];
//            controller.articles = [NSArray arrayWithObject:currentAricle];
//            controller.adArticle = currentAricle;
//            controller.column = column;
            
            FDQuestionsAndAnwsersPlusDetailViewController *controller = [[FDQuestionsAndAnwsersPlusDetailViewController alloc] init];
            controller.article = currentAricle;
            controller.column = column;
            
            if(viewController.navigationController)
                [viewController.navigationController pushViewController:controller animated:YES];
            else
                [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];

        } else{
            //打开图文新闻
            TemplateDetailPageController *controller = [[TemplateDetailPageController alloc] init];
            controller.column = column;
            controller.columnName = column.columnName;
            currentAricle.shareUrl = [NSString stringWithFormat:@"%@/news_detail?newsid=%d_%@&app=1",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
            controller.articles = [NSArray arrayWithObject:currentAricle];
            controller.adArticle = currentAricle;
            controller.currentIndex = 0;
            if(viewController.navigationController)
                [viewController.navigationController pushViewController:controller animated:YES];
            else
                [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        }
        
    }
    else if (currentAricle.articleType == ArticleType_IMAGE)
    {//组图稿件
        ImageDetailPageController *controller = [[ImageDetailPageController alloc] init];
        currentAricle.shareUrl = [NSString stringWithFormat:@"%@/news_detail?newsid=%d_%@&app=1",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
        currentAricle.contentUrl = [NSString stringWithFormat:@"%@/api/getArticle?sid=%@&aid=%d&cid=%d",[AppConfig sharedAppConfig].serverIf,[AppConfig sharedAppConfig].sid,currentAricle.fileId,column.columnId];
        controller.articles = [NSArray arrayWithObject:currentAricle];
        controller.currentIndex = 0;
        controller.column = column;
        controller.isFirst = 1;
        if(viewController.navigationController)
            [viewController.navigationController pushViewController:controller animated:YES];
        else
            [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        //上传点击数
        //[FounderEventRequest founderEventClickAppinit:currentAricle];
    }
    else if (currentAricle.articleType == ArticleType_SPECIAL)
    {//专题稿件
        
        Column *oneColumn = [[Column alloc] init];
        oneColumn.columnId =currentAricle.linkID;
        oneColumn.columnName = NSLocalizedString(@"专题", nil);
        SpecialNewsPageController *controller = [[SpecialNewsPageController alloc] init];
        controller.parentColumn = oneColumn;
        controller.column = column;
        currentAricle.contentUrl = [NSString stringWithFormat:@"%@/special_detail?newsid=%d_%@&app=1",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
        controller.speArticle = currentAricle;
        
        if(viewController.navigationController)
            [viewController.navigationController pushViewController:controller animated:YES];
        else
            [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        //上传点击数
       // [FounderEventRequest founderEventClickAppinit:currentAricle];
    }
    // 推广
    else if (currentAricle.articleType == ArticleType_ADV || (currentAricle.type == ArticleType_ADV_List && currentAricle.articleType == 0)){
        
        if([currentAricle.contentUrl rangeOfString:@"duibaLogin?"].location == NSNotFound){
            TemplateNewDetailViewController *controller = [[TemplateNewDetailViewController alloc] init];
            currentAricle.shareUrl = [NSString stringWithFormat:@"%@/adv_detail?newsid=%d_%@",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
            currentAricle.contentUrl = [NSString stringWithFormat:@"%@/adv_detail?newsid=%d_%@",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
            controller.articles = [NSArray arrayWithObject:currentAricle];
            controller.adArticle = currentAricle;
            controller.column = column;
            if(viewController.navigationController)
                [viewController.navigationController pushViewController:controller animated:YES];
            else
                [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            isNeedScoreAction = NO;
        }
        else{
            NSString *contentUrl = [NSString stringWithFormat:@"%@&uid=%@", currentAricle.contentUrl, [Global userId]];
            CreditSecondViewController *controller = [[CreditSecondViewController alloc]initWithUrlByPresent:contentUrl];
            
            [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
            isNeedScoreAction = NO;
        }
    }
    else if (currentAricle.articleType == ArticleType_LIVESHOW){
        //直播稿件
        SeeRootViewController *controller = [[SeeRootViewController alloc] init];
        controller.seeArticle = currentAricle;
        controller.column = column;
        if(viewController.navigationController)
            [viewController.navigationController pushViewController:controller animated:YES];
        else
            [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
        //上传点击数
        //[FounderEventRequest founderEventClickAppinit:currentAricle];
        
    }else if (currentAricle.articleType == ArticleType_LINK){
        //链接稿件、投票稿件
        TemplateNewDetailViewController *controller = [[TemplateNewDetailViewController alloc] init];
        currentAricle.shareUrl = [NSString stringWithFormat:@"%@/link_detail?newsid=%d_%@&app=1",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid];
        currentAricle.contentUrl = [NSString stringWithFormat:@"%@/link_detail?newsid=%d_%@&uid=%@&xky_deviceid=%@",[AppConfig sharedAppConfig].serverIf,currentAricle.fileId,[AppConfig sharedAppConfig].sid, [Global userId], [AppConfig sharedAppConfig].kGtAppId];
        controller.articles = [NSArray arrayWithObject:currentAricle];
        controller.adArticle = currentAricle;
        controller.column = column;
        if(viewController.navigationController)
            [viewController.navigationController pushViewController:controller animated:YES];
        else
            [viewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
    }
    
    //积分入库
    if (!currentAricle.isRead && isNeedScoreAction && [Global userId].length > 0) {
        FounderIntegralRequest *IntegralRequest = [[FounderIntegralRequest alloc] init];
        NSString *dateSign = [NSString stringWithFormat:@"ReadDate-%@",[Global userId]];
        NSDate *readDate = [[NSUserDefaults standardUserDefaults] objectForKey:dateSign];
        if (![IntegralRequest isSameDay:readDate date2:[NSDate date]]) {
            [IntegralRequest addIntegralWithUType:UTYPE_READ integralBlock:^(NSDictionary *integralDict) {
                
                if (![[integralDict objectForKey:@"success"] boolValue]) {
                    XYLog(@"阅读积分错误:%@", [integralDict objectForKey:@"msg"]);
                }else{
                    NSInteger score = [[integralDict objectForKey:@"score"] integerValue];
                    if (score) {//score分数不为0提醒
                        [Global showTip:[NSString stringWithFormat:@"%@，%@+%ld",NSLocalizedString(@"阅读一条新闻", nil), [AppConfig sharedAppConfig].integralName, (long)(long)score]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"duiba-load-WebView" object:self userInfo:nil];
                    }else{//score分数为0今日不调积分入库接口
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateSign];
                    }
                }
            }];
        }
    }
    
   // [FounderEventRequest articleclickDateAnaly:currentAricle.fileId column:column.fullColumn bid:@""];
}

//创建新闻cell样式
+(TableViewCell *)getNewsCell:(Article *)article in:(UITableView *)tableView{
    
    TableViewCell *cell = nil;
    if (article.articleType == ArticleType_VIDEO){//视频稿件
       cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
        if(!cell){
            cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
            
            //cell.backgroundColor=[UIColor orangeColor];
        }
        cell.article = article;
        [cell configBigimageWithArticle:article];
        return cell;
    }
    if ((article.articleType == ArticleType_PLAIN && article.type == 0)
        || article.articleType == ArticleType_LIVESHOW
        || article.articleType == ArticleType_LINK
        )
    {   //普通 直播 链接 视频 活动 投票
        
        //活动、投票、有答
        if ((![NSString isNilOrEmpty:article.activityStartTime] && ![NSString isNilOrEmpty:article.activityEndTime])
            || (![NSString isNilOrEmpty:article.voteStartTime] && ![NSString isNilOrEmpty:article.voteEndTime])
            || (![NSString isNilOrEmpty:article.askStartTime] && ![NSString isNilOrEmpty:article.askEndTime])) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell"];
            
            if (!cell)
            {
                cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoteCell"];
            }
            cell.article = article;
            [cell configActivityAndVoteWithArticle:article];
        }else{
            // 其他
            if ((1 == article.isBigPic) || (article.isBigPic == 2)){
                //大图
                cell = [tableView dequeueReusableCellWithIdentifier:@"BigPicMiddleCell"];
                
                if (!cell){
                    cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BigPicMiddleCell"];
                }
                cell.article = article;
                [cell configBigimageWithArticle:article];
                
            } else if ([article.extproperty hasPrefix:@"questionsAndAnswers"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionsAndAnswersCell"];
                
                if (!cell){
                    cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuestionsAndAnswersCell"];
                }
                cell.article = article;
                [cell configQuestionsAndAnswersWithArticle:article];
            }
            else{
                NSArray *groupArry = [article.groupImageUrl componentsSeparatedByString:@","];
                if (article.articleType == ArticleType_PLAIN && [groupArry count] > 1) {
                    // 图文标题图多个
                    cell = [tableView dequeueReusableCellWithIdentifier:@"groupImageMiddleCell"];
                    if (!cell)
                        cell = [[GroupImage_MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupImageMiddleCell"];
                    cell.article = article;
                    [cell configGroupImageCellWithArticle:article];
                }else {
                    // 标题图单个
                    cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];
                    if (!cell){
                        cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MiddleCell"];
                    }
                    cell.article = article;
                    [cell configMiddleCellWithArticle:article];
                }
            }
        }
    }
    else if (article.articleType == ArticleType_IMAGE){
        //组图
        
        if ((1 == article.isBigPic) || (article.isBigPic == 2)) {
            //大图
            cell = [tableView dequeueReusableCellWithIdentifier:@"BigPicMiddleCell"];
            if (!cell)
                cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BigPicMiddleCell"];
            cell.article = article;
            [cell configBigimageWithArticle:article];
            
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"groupImageMiddleCell"];
            
            if (!cell)
                cell = [[GroupImage_MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupImageMiddleCell"];
            cell.article = article;
            [cell configGroupImageCellWithArticle:article];
        }
    }
    else if (article.articleType == ArticleType_SPECIAL){
        //专题
        if ((1 == article.isBigPic) || (article.isBigPic == 2))
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"specialNewsCell"];
            
            if (!cell)
            {
                cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"specialNewsCell"];
            }
            cell.article = article;
            [cell configSpecialCellWithIsArticle:article];
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];
            
            if (!cell){
                cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MiddleCell"];
            }
            cell.article = article;
            [cell configMiddleCellWithArticle:article];
        }
    }
    else if (article.type == ArticleType_ADV_List){
        // 推广
        NSString *identifier = [NSString stringWithFormat:@"ADadvnadageViewCell%d", article.fileId];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
            cell = [[ADadvnadageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.article = article;
        [cell configImageCellWithArticle:article];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"MiddleCell"];
        if (!cell){
            cell = [[MiddleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MiddleCell"];
        }
        cell.article = article;
        [cell configMiddleCellWithArticle:article];
    }
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    selectedImageView.backgroundColor = [UIColor colorWithRed:0xe8/255.0 green:0xe8/255.0 blue:0xe8/255.0 alpha:1];
    cell.selectedBackgroundView = selectedImageView;
    cell.backgroundColor = [UIColor whiteColor];
    CGRect bgFrame = CGRectMake(0, 0, kSWidth, [NewsListConfig sharedListConfig].middleCellHeight-1);
    if ([cell isKindOfClass:[MiddleCell class]]){
        ((MiddleCell*)cell).cellBgView.frame = bgFrame;
    }
    
    return cell;
}

//获取新闻cell高度
+(CGFloat)getNewsCellHeight:(Article *)article{

    if(article == nil)
        return 0.0;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    if ((article.articleType == ArticleType_PLAIN && article.type == 0) || article.articleType == ArticleType_LIVESHOW || article.articleType == ArticleType_LINK || article.articleType == ArticleType_VIDEO)
    {//普通 直播 链接 互动+
        
        if(article.articleType == ArticleType_VIDEO){
            return (kSWidth-20)*9/16.0+30+30+13+8;
        }
        //活动、投票、有答
        if ((![NSString isNilOrEmpty:article.activityStartTime] && ![NSString isNilOrEmpty:article.activityEndTime])
            || (![NSString isNilOrEmpty:article.voteStartTime] && ![NSString isNilOrEmpty:article.voteEndTime])
            || (![NSString isNilOrEmpty:article.askStartTime] && ![NSString isNilOrEmpty:article.askEndTime])) {
           
            if ([NSString isNilOrEmpty:article.imageUrlBig] && ![AppConfig sharedAppConfig].isArticleShowDefaultImage) {
                return (IS_IPHONE_4 || IS_IPHONE_5) ? 180*proportion-(kSWidth-20)/3.0f-10 : 170*proportion-(kSWidth-20)/3.0f-10;
            }else {
                if (article.isBigPic == 1 ) {
                   return (IS_IPHONE_4 || IS_IPHONE_5) ? 248.75*proportion : 238.75*proportion;
                }else{
                    return (IS_IPHONE_4 || IS_IPHONE_5) ? 180*proportion : 170*proportion;
                }
                
            }
            
        }else{
            
            if ((1 == article.isBigPic) || (article.isBigPic == 2) ){
                if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage){
                    
                    return [NewsListConfig sharedListConfig].middleCellHeight;
                }else {
                    if (article.isBigPic == 1) {
                        return 238*proportion;
                    }else if (article.isBigPic ==2){
                        return 169*proportion;
                    }
                }
            } else if ([article.extproperty hasPrefix:@"questionsAndAnswers"]) {
                //互动+
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                if (kSWidth == 375 ||kSWidth == 414) {
                    paragraphStyle.lineSpacing = 7;
                }else
                    paragraphStyle.lineSpacing = 4;
                //paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                NSDictionary *attributes = @{
                                             NSFontAttributeName:[UIFont systemFontOfSize:[NewsListConfig sharedListConfig].middleCellTitleFontSize],
                                             NSParagraphStyleAttributeName:paragraphStyle,
                                             };
                
                NSAttributedString *string = [[NSAttributedString alloc] initWithString:article.title attributes:attributes];
                NSStringDrawingOptions options  = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
                
                CGRect rect = [string boundingRectWithSize:CGSizeMake(kSWidth - 20, 0) options:options context:nil];
                if (rect.size.height > 40) {
                    rect.size.height = 55;
                }
                return 90 + MIN(55, rect.size.height) + kSWidth/3.f;
            }
            else {
                NSArray *groupArry = [article.groupImageUrl componentsSeparatedByString:@","];
                if (article.articleType == ArticleType_PLAIN && [groupArry count] > 1) {
                    return 10+(82+45)*proportion;
                }else {
                    return [NewsListConfig sharedListConfig].middleCellHeight;
                }
            }
        }
    }
    else if (article.articleType == ArticleType_ACTIVITY)
    {
        return  [NewsListConfig sharedListConfig].middleActiveCellHeight;
    }
    else if (article.articleType == ArticleType_IMAGE)
    {//组图
        if ((1 == article.isBigPic) || (article.isBigPic == 2))
        {
            if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage){
                return 248*proportion-(kSWidth-20)*9/16.0-10;
            }else {
                if (article.isBigPic == 1) {
                    return 238*proportion;
                }else if (article.isBigPic ==2){
                    return 169*proportion;
                }
            }
        }else
        {
            return 10+(82+45)*proportion;
        }
    }
    else if (article.type == ArticleType_ADV_List)
    {//推广
        if ((1 == article.isBigPic) || (article.isBigPic == 2))
        {
            if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage){
                return 238*proportion-(kSWidth-20)*9/16.0-10;
            }else {
                if (article.isBigPic == 1) {
                    return 238*proportion;
                }else if (article.isBigPic ==2){
                    return 169*proportion;
                }
            }
        }
        else
        {
            if (article.sizeScale == ArticleSizeScale_1_2)
            {
                return (kSWidth-20)/2 + 40+10;
            }
            else if (article.sizeScale == ArticleSizeScale_1_1)
            {
                return (kSWidth-20)/3 + 40+10;
            }
            else if (article.sizeScale == ArticleSizeScale_1_3)
            {
                return (kSWidth-20)/3 + 40+10;
            }
            else if (article.sizeScale == ArticleSizeScale_1_4)
            {
                return (kSWidth-20)/4 + 40+10;
            }
            else if (article.sizeScale == ArticleSizeScale_3_4)
            {
                return (kSWidth-20)/4*3 + 40+10;
            }
            else if (article.sizeScale == ArticleSizeScale_9_16)
            {
                return (kSWidth-20)/16*9 + 40+10;
            }
            else
            {
                return [NewsListConfig sharedListConfig].middleCellHeight + 10 + 40*proportion + 20;
            }
        }
    }
    else if (article.articleType == ArticleType_SPECIAL)
    {//专题
        if ((1 == article.isBigPic) || (article.isBigPic == 2))
        {
            if ([NSString isNilOrEmpty:article.imageUrlBig] && ([NSString isNilOrEmpty:article.imageUrl] || [article.imageUrl isEqualToString:@"@!md169"]) && ![AppConfig sharedAppConfig].isArticleShowDefaultImage){
                return 235*proportion-(kSWidth-20)*9/16.0-10;
            }else {
                if (article.isBigPic == 1) {
                    return 235*proportion;
                }else if (article.isBigPic ==2){
                    return 166.25*proportion;
                }
            }
        }
        else
        {
            return [NewsListConfig sharedListConfig].middleCellHeight;
        }
    }
    else{
        
        return [NewsListConfig sharedListConfig].middleCellHeight;
        
    }
    return 0.0f;
}
@end
