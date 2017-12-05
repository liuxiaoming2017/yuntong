//
//  FDPresentSelectionView.m
//  FounderReader-2.5
//
//  Created by snitsky on 2017/1/13.
//
//

#import "FDPresentSelectionView.h"
#import "UIView+Extention.h"

@interface FDPresentSelectionView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FDPresentSelectionView

- (instancetype)initWithPresentTableViewFrame:(CGRect)frame {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.tableView.tableFooterView = [[UIView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.clipsToBounds = YES;
        self.tableView.layer.cornerRadius = 5;
        self.tableView.layer.borderWidth = 1;
        self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.hidden = YES;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)show {
    [super setHidden:NO];
}

- (void)hide {
    [super setHidden:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectionView:heightForRowAtIndexPath:)]) {
        return [self.delegate selectionView:self heightForRowAtIndexPath:indexPath];
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource selectionView:self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource selectionView:self cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectionView:didSelectRowAtIndexPath:)]) {
        [self.delegate selectionView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

- (void)setHidden:(BOOL)hidden {
    hidden ? [self hide] : [self show];
}

@end
