#ifndef WALockscreenWidgetViewController_h
#define WALockscreenWidgetViewController_h

#import <UIKit/UIKit.h>
@class WATodayModel;

@interface WALockscreenWidgetViewController : UIViewController

@property (nonatomic, strong) WATodayModel *todayModel;

+ (WALockscreenWidgetViewController *)sharedInstanceIfExists;
- (id)_temperature;
- (id)_locationName;
- (void)updateWeather;
- (void)_updateTodayView;
- (void)_setupWeatherModel;
- (void)todayModelWantsUpdate:(WATodayModel *)todayModel;

@end

#endif /* WALockscreenWidgetViewController_h */
