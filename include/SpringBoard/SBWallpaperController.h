#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SBFWallpaperView, SBWallpaperViewController;

@interface SBWallpaperController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) SBFWallpaperView *sharedWallpaperView;
@property (nonatomic, strong) SBFWallpaperView *lockscreenWallpaperView;
@property (nonatomic, strong) SBFWallpaperView *homescreenWallpaperView;

@end
