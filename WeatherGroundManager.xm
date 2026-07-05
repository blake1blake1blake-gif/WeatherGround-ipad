#import "WeatherGroundManager.h"

@implementation WeatherGroundManager

- (BOOL)boolForKey:(NSString *)key {
    id object = [self.preferencesDictionary objectForKey:key];
    return object ? [object boolValue] : NO;
}

- (int)intForKey:(NSString *)key {
    id object = [self.preferencesDictionary objectForKey:key];
    return object ? [object intValue] : 0;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken = 0;
    __strong static WeatherGroundManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _preferencesDictionary =  [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tr1fecta.wgprefs.plist"];

        // Convert to minutes from seconds
        double interval = (double)[self intForKey:@"kAutoUpdateInterval"] * 60;
        if (interval > 0) {
            _autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateModel) userInfo:nil repeats:YES];
        }
        
    }
    return self;
}

// In Apps
- (void)setStatusBarTextToWeatherInfo:(NSDictionary *)infoDict {
    if (self.statusStringView != nil) {
        NSMutableAttributedString *temperatureAttrString = [[self temperatureInfo:infoDict[@"unit"]] objectForKey:@"weatherString"];
        self.statusStringView.attributedText = temperatureAttrString;
        [self changeLabelTextWithAttributedString:temperatureAttrString];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone localTimeZone];
            formatter.dateFormat = @"HH:mm";
            NSString *currentStatusTime = [formatter stringFromDate:[NSDate date]];

            self.statusStringView.attributedText = nil;
            [self changeLabelText:currentStatusTime];
        });
    }
}

- (void)changeLabelTextWithAttributedString:(NSMutableAttributedString *)text {
	CATransition *animation = [CATransition animation];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
	animation.duration = 0.3;
	[self.statusStringView.layer addAnimation:animation forKey:@"kCATransitionPush"];

	self.statusStringView.attributedText = text;
}

- (void)changeLabelText:(NSString *)text {
	CATransition *animation = [CATransition animation];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
	animation.duration = 0.3;
	[self.statusStringView.layer addAnimation:animation forKey:@"kCATransitionPush"];

	self.statusStringView.text = text;
}

- (void)setupDynamicWeatherBackgrounds {
    SBWallpaperController *wallpaperController = [%c(SBWallpaperController) sharedInstance];
    SBFWallpaperView *sharedWallpaperView;
    SBFWallpaperView *lockscreenWallpaperView;
    SBFWallpaperView *homescreenWallpaperView;

    if (%c(SBWallpaperViewController)) {
        SBWallpaperViewController *wallpaperViewController = [wallpaperController valueForKey:@"_wallpaperViewController"];
        
        sharedWallpaperView = wallpaperViewController.sharedWallpaperView;

        lockscreenWallpaperView = wallpaperViewController.lockscreenWallpaperView;
        homescreenWallpaperView = wallpaperViewController.homescreenWallpaperView;
    }
    else {
        sharedWallpaperView = wallpaperController.sharedWallpaperView;
    
        lockscreenWallpaperView = wallpaperController.lockscreenWallpaperView;
        homescreenWallpaperView = wallpaperController.homescreenWallpaperView;
    }

    // Always create this instance for the weather effects layer, but only add if enabled
    self.sharedBgView = [[%c(WUIDynamicWeatherBackground) alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.sharedBgView.city = [self myCity];
    self.sharedBgView.condition.city = [self myCity];
    if (sharedWallpaperView != nil && [self boolForKey:@"kUseEntireWeatherView"] && [self boolForKey:@"kUseWeatherEffectsOnly"] == NO) {
        [sharedWallpaperView addSubview:self.sharedBgView];

        [self setSharedImageWithView:self.sharedBgView];
    }
   
    // Check if the user is using 2 different wallpapers
    if (lockscreenWallpaperView != nil && homescreenWallpaperView != nil && sharedWallpaperView == nil) {
        if ([self boolForKey:@"kLockscreenEnabled"]) {
            self.lockScreenBgView = [[%c(WUIDynamicWeatherBackground) alloc] initWithFrame:UIScreen.mainScreen.bounds];
            self.lockScreenBgView.city = [self myCity];
            self.lockScreenBgView.condition.city = [self myCity];

            if ([self boolForKey:@"kUseEntireWeatherView"]) {
                [lockscreenWallpaperView addSubview:self.lockScreenBgView];

                [self setSharedImageWithView:self.lockScreenBgView];
            }

           
        }
        if ([self boolForKey:@"kHomescreenEnabled"]) {
            self.homeScreenBgView = [[%c(WUIDynamicWeatherBackground) alloc] initWithFrame:UIScreen.mainScreen.bounds];
            self.homeScreenBgView.city = [self myCity];
            self.homeScreenBgView.condition.city = [self myCity];
            
            if ([self boolForKey:@"kUseEntireWeatherView"]) {
                [homescreenWallpaperView addSubview:self.homeScreenBgView];

{