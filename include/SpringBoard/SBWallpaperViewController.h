#import <Foundation/Foundation.h>
@class SBFWallpaperView;

@interface SBWallpaperViewController : NSObject

@property (nonatomic, strong) SBFWallpaperView *sharedWallpaperView;
@property (nonatomic, strong) SBFWallpaperView *lockscreenWallpaperView;
@property (nonatomic, strong) SBFWallpaperView *homescreenWallpaperView;

@end
