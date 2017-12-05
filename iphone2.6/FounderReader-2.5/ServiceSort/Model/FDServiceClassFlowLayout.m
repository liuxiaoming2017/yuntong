//
//  FDServiceClassFlowLayout.m
//  FounderReader-2.5
//
//  Created by mac on 2017/7/11.
//
//

#import "FDServiceClassFlowLayout.h"

@interface FDServiceClassFlowLayout ()
@property (nonatomic,strong)NSMutableArray * attrsArray;
@property (nonatomic,strong)NSMutableArray * headLayoutInfo;
@property (nonatomic,strong)NSMutableArray * footLayoutInfo;
@property (nonatomic,assign)CGFloat maxSizeH;
@end

@implementation FDServiceClassFlowLayout
-(NSMutableArray *)attrsArray{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}
-(NSMutableArray *)headLayoutInfo{
    if (!_headLayoutInfo) {
        _headLayoutInfo = [NSMutableArray array];
    }
    return _headLayoutInfo;
}
-(NSMutableArray *)footLayoutInfo{
    if (!_footLayoutInfo) {
        _footLayoutInfo = [NSMutableArray array];
    }
    return _footLayoutInfo;
}
-(CGSize)collectionViewContentSize{
    UICollectionViewLayoutAttributes * lastAttr = [self.footLayoutInfo lastObject];
    return CGSizeMake(kSWidth, self.maxSizeH);
}
-(void)prepareLayout{
    [super prepareLayout];
    [self.attrsArray removeAllObjects];
    NSInteger sections = [self.collectionView numberOfSections];
    
    for (int section= 0; section <sections; section++) {
        //存储headerView属性
        UICollectionViewLayoutAttributes * lastAttr = [self.attrsArray lastObject];
        CGFloat maxY = CGRectGetMaxY(lastAttr.frame)+section;
         NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        CGFloat DefaultSectionH = 32.5*kHScale;
        //头视图的高度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
                if (DefaultSectionH>0 && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
                   UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
                        //设置frame
                        attribute.frame = CGRectMake(0, maxY, kSWidth, DefaultSectionH);
                        //保存布局对象
                        [self.headLayoutInfo insertObject:attribute atIndex:supplementaryViewIndexPath.row];
                        
                    }
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        for (int row = 0; row < items; row ++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UICollectionViewLayoutAttributes * attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.attrsArray addObject:attr];
        }
        
        //头视图的高度不为0并且根据代理方法能取到对应的头视图的时候，添加对应头视图的布局对象
        if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
            UICollectionViewLayoutAttributes * lastAttribute= [self.attrsArray lastObject];
            CGFloat maxY = CGRectGetMaxY(lastAttribute.frame)+5*section*kHScale;
            NSLog(@"maxY--------:%lf",maxY);
            self.maxSizeH = maxY;
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:supplementaryViewIndexPath];
            //设置frame
            if (sections >0 && section == sections-1) {
                   attribute.frame = CGRectMake(0, maxY, kSWidth, 0);
            }else{
                   attribute.frame = CGRectMake(0, maxY, kSWidth, 5*kHScale);
            }
            //保存布局对象
            [self.footLayoutInfo insertObject:attribute atIndex:supplementaryViewIndexPath.row];
        }
    }
}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    [self.attrsArray addObjectsFromArray:self.headLayoutInfo];
    [self.attrsArray addObjectsFromArray:self.footLayoutInfo];
    return self.attrsArray;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes * attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    /** 默认的分组头高度 */
    CGFloat itemW = self.itemSize.width;
    CGFloat itemH = self.itemSize.height;
    CGFloat DefaultSectionH = 32.5*kHScale;
    CGFloat begainY = self.topMargin+DefaultSectionH;
    if (indexPath.section >0) {
        NSInteger items = 0;
        for (int section= 0; section < indexPath.section; section++) {
            items += [self.collectionView numberOfItemsInSection:section];
        }
        UICollectionViewLayoutAttributes * lastAttr = self.attrsArray[items-1];
        CGFloat maxY = CGRectGetMaxY(lastAttr.frame);
        begainY = begainY + maxY;
    }
    if (!self.columsCount) {
        self.columsCount = 1;
    }
    CGFloat itemY = begainY +indexPath.row/self.columsCount*(self.rowMargin+itemH);
    CGFloat itemX =self.leftRightMargin+indexPath.row%self.columsCount*(self.columnMargin +itemW);
    attr.frame = CGRectMake(itemX, itemY, itemW, itemH);
    return attr;
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attribute = self.headLayoutInfo[indexPath.row];
    }else{
        attribute = self.footLayoutInfo[indexPath.row];
    }
    return attribute;
}

@end
