//
//  FDPickerView.m
//  FounderReader-2.5
//
//  Created by Julian on 2017/3/9.
//
//

#import "FDPickerView.h"
#import "ColorStyleConfig.h"

@interface FDPickerView() <UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *_title;
    NSArray *_items;
    UIPickerView *_pickerView;
    NSInteger _selectRow;
}
@end

@implementation FDPickerView

+ (instancetype)pickerViewWithFrame:(CGRect)frame Title:(NSString *)title Items:(NSArray *)items
{
    return [[self alloc] initWithFrame:frame Title:title Items:items];
}

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title Items:(NSArray *)items
{
    if (self = [super initWithFrame:frame]){
        _items = items;
        _title = title;
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    CGFloat completeLabelW = 45;
    
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.frame = CGRectMake(0, 0, self.frame.size.width, completeLabelW);
    titleLable.text = _title;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.font = [UIFont systemFontOfSize:18];
    titleLable.userInteractionEnabled = YES;
    [self addSubview:titleLable];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.frame = CGRectMake(titleLable.frame.size.width-completeLabelW-10, 5, completeLabelW, 35);
    [completeBtn setTitle:NSLocalizedString(@"确认",nil) forState:UIControlStateNormal];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    completeBtn.layer.cornerRadius = 3;
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    completeBtn.backgroundColor = [ColorStyleConfig sharedColorStyleConfig].nav_bar_color;
    [completeBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    [titleLable addSubview:completeBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cancelImage = [UIImage imageNamed:@"closeIcon"];
    cancelBtn.frame = CGRectMake(10, (titleLable.frame.size.height-cancelImage.size.height-5)/2.0f, cancelImage.size.width+5, cancelImage.size.height+5);
    [cancelBtn setBackgroundImage:cancelImage forState:UIControlStateNormal];
//    [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
//    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    cancelBtn.layer.cornerRadius = 3;
//    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [titleLable addSubview:cancelBtn];
    
    // 选择框
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, completeLabelW, self.frame.size.width, self.frame.size.height-completeLabelW)];
    // 显示选中框
    _pickerView.showsSelectionIndicator=YES;
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [self addSubview:_pickerView];
}

- (void)complete
{
    if (self.pickerViewBlock)
        self.pickerViewBlock(_selectRow);
}

- (void)cancel
{
    [self removeFromSuperview];
}

#pragma Mark -- UIPickerViewDataSource
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_items count];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_items objectAtIndex:row];
}

#pragma Mark -- UIPickerViewDelegate
// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectRow = row;
}

@end
