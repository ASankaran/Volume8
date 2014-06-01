#import <UIKit/UIKit.h>
//#import <SpringBoard/SBMediaController.h>
//#import <SpringBoard/SBApplicationIcon.h>
//#import <SpringBoard/SBWallpaperView.h>

#define iconPath(name) @"/Library/MobileSubstrate/DynamicLibraries/com.mootjeuh.volume8.bundle/"#name".png"
#define UIColorFromRGB(rgbValue) \
            [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
            green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SBApplication

@end

@interface Volume8 : NSObject

@property(assign, nonatomic) UIImage *nextIcon;
@property(assign, nonatomic) UIImage *pauseIcon;
@property(assign, nonatomic) UIImage *playIcon;
@property(assign, nonatomic) UIImage *previousIcon;
@property(assign, nonatomic) UIView *HUD;

- (id)init;
- (void)updateNow;
- (NSDate*)getNow;
- (void)updateSongInfo;
- (void)drawRect:(id)superview rect:(CGRect)rect colour:(UIColor*)colour;
- (void)addButtonTo:(id)superview x:(int)x icon:(UIImage*)icon target:(id)target selector:(SEL)selector;
- (UIButton*)addButtonTo:(id)superview x:(int)x icon:(UIImage*)icon selector:(SEL)selector;
- (void)printTo:(id)superview y:(int)y text:(NSString*)text size:(float)size alignment:(NSTextAlignment)alignment;
- (void)blitImage:(id)superview x:(int)x y:(int)y image:(UIImage*)image;
- (UIImage*)resizeImage:(UIImage*)source newSize:(CGSize)newSize;
- (UIImage*)getAppIcon:(SBApplication*)app;
- (UIColor*)getProminentColour:(UIImage*)image;

@end

@interface SBHUDView : UIView

- (id)initWithHUDViewLevel:(int)hudviewLevel;

@end

@interface SBMediaController

+ (id)sharedInstance;
- (id)artwork;
- (id)nowPlayingApplication;
- (id)nowPlayingArtist;
- (id)nowPlayingTitle;
- (void)_changeVolumeBy:(float)by;
- (BOOL)changeTrack:(int)track;
- (float)volume;
- (BOOL)togglePlayPause;
- (BOOL)isPlaying;
- (BOOL)isMovie;

@end

@interface SBApplicationIcon

- (id)initWithApplication:(id)application;
 -(id)getIconImage:(int)image;

@end