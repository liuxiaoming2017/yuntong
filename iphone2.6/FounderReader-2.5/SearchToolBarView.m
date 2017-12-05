//
//  SearchToolBarView.m
//  FounderReader-2.5
//  首页新闻搜索框，点击弹出搜索页面
//  Created by ld on 2016-07-26.
//
//

#import "SearchToolBarView.h"
#import "SearchPageController.h"

@implementation SearchToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, kSWidth-8, frame.size.height - 8)];
        label.layer.cornerRadius = (frame.size.height-8)/2;
        label.layer.borderWidth = 1;
        label.clipsToBounds = YES;
        
        label.layer.borderColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0].CGColor;
        label.backgroundColor = [UIColor whiteColor];
        UILabel *labelSearch = [[UILabel alloc] initWithFrame:CGRectMake(30, 2, 100, frame.size.height - 10)];
        labelSearch.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        labelSearch.text = NSLocalizedString(@"搜索",nil);
        [label addSubview:labelSearch];
        
        
        UIImageView *searchView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 16, 16)];
        searchView.contentMode = UIViewContentModeScaleAspectFit;
        searchView.image = [UIImage imageNamed:@"icon-search"];
        [label addSubview:searchView];
        [self addSubview:label];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:recognizer];
        self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    }
    return self;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    
    SearchPageController *controller = [[SearchPageController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [appDelegate().window.rootViewController presentViewController:[Global controllerToNav:controller] animated:YES completion:nil];
}
@end
