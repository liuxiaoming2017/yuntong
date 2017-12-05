//
//  LocationPageController.h
//  FounderReader-2.5
//
//  Created by lx on 15/8/26.
//
//

#import "DataChannelPageController.h"
@protocol LocationPageDelegate;
@interface CityPageController : DataChannelPageController{
    
    id<LocationPageDelegate>   delegate;
}
@property(nonatomic,retain)NSString *titleName;
@property(nonatomic, retain) id<LocationPageDelegate> delegate;
@property(nonatomic, retain) Column *currentColumn;
//@property(nonatomic, retain) NSMutableArray *columns;
@end

@protocol LocationPageDelegate <NSObject>
- (void)LocationPageController:(int)index;
@end
