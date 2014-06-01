#import "Volume8.h"

#define sbmc (SBMediaController*)[%c(SBMediaController) sharedInstance]

static Volume8 *vol8 = NULL;
static UIButton *button;
static UIColor *average;
static UIWindow *topWindow;

%hook VolumeControl

- (void)_changeVolumeBy:(float)by
{
 	[sbmc _changeVolumeBy:by];
    %orig;
}

%end

%hook SBHUDView

%new;
- (void)_animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    if ([animationID isEqualToString:@"fadeout"]) {
        CGFloat originalOpacity = [(NSNumber*)context floatValue];
        vol8.HUD.layer.opacity = originalOpacity;
        [vol8.HUD removeFromSuperview];
        [topWindow release];
    }
}

%new;
- (void)next
{
    [sbmc changeTrack:1];
    if(![sbmc isPlaying]) {
        [sbmc togglePlayPause];
        [button setImage:[sbmc isPlaying] ? vol8.playIcon : vol8.pauseIcon forState:UIControlStateNormal];
    }
    [vol8 updateNow];
    [self initWithHUDViewLevel:1];
}

%new
- (void)prev
{
    [sbmc changeTrack:-1];
    if(![sbmc isPlaying]) {
        [sbmc togglePlayPause];
        [button setImage:[sbmc isPlaying] ? vol8.playIcon : vol8.pauseIcon forState:UIControlStateNormal];
    }
    [vol8 updateNow];
    [self initWithHUDViewLevel:1];
}

- (id)initWithHUDViewLevel:(int)hudviewLevel
{
    topWindow.frame = CGRectZero;
    if(vol8.HUD) [vol8.HUD removeFromSuperview];
    BOOL playing = hudviewLevel == 0 ? [sbmc isPlaying] : YES;
    float width, vol = [sbmc volume]*100;
    
    if(playing == YES) width = 250;
    else width = 30;
        
    topWindow = [[UIWindow alloc] init];
    topWindow.windowLevel = UIWindowLevelStatusBar;
    topWindow.backgroundColor = [UIColor clearColor];
    [topWindow makeKeyAndVisible];
    vol8.HUD = [[UIView alloc] initWithFrame:CGRectMake(25, 50, width, 140)];
    vol8.HUD.backgroundColor = UIColorFromRGB(0x101010);
    [topWindow addSubview:vol8.HUD];
    
    [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 10, 10, 100) colour:[UIColor grayColor]];
    if((int)vol != 0 && (int)vol != 6) {
        [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 110-vol, 10, 10) colour:[UIColor whiteColor]];
        [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 10, 10, 100) colour:average];
        [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 10, 10, 100-vol) colour:[UIColor grayColor]];
        [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 110-vol, 10, 10) colour:[UIColor whiteColor]];
    } else {
        [vol8 drawRect:vol8.HUD rect:CGRectMake(10, 100, 10, 10) colour:[UIColor whiteColor]];
    }
    UILabel *volLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 30, 17)];
    volLabel.textColor = [UIColor whiteColor];
    volLabel.text = [NSString stringWithFormat:@"%2.0f", vol];
    volLabel.textAlignment = NSTextAlignmentCenter;
    [vol8.HUD addSubview:volLabel];
    [volLabel release];
    
    if(playing && ![sbmc isMovie]) {
        topWindow.frame = CGRectMake(0, 0, 275, 190);
        button = [vol8 addButtonTo:vol8.HUD x:80 icon:vol8.pauseIcon selector:@selector(togglePlayPause:)];
        [vol8 addButtonTo:vol8.HUD x:30 icon:vol8.previousIcon target:self selector:@selector(prev)];
        [vol8 addButtonTo:vol8.HUD x:130 icon:vol8.nextIcon target:self selector:@selector(next)];
        if(hudviewLevel == 0) [vol8 updateSongInfo];
    }
    
    NSTimer *timer;
    [vol8 updateNow];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(_timerFired:) userInfo:vol8 repeats:YES];
    return 0;
}

%new;
- (void)_timerFired:(NSTimer*)sender
{
    Volume8 *temp = [sender userInfo];
    NSInteger secondsSinceStart = (NSInteger)[[NSDate date] timeIntervalSinceDate:[temp getNow]];
    if((secondsSinceStart % 60) >= 3) {
        topWindow.frame = CGRectZero;
        [UIView beginAnimations:@"fadeout" context:(void*)[NSNumber numberWithFloat:vol8.HUD.layer.opacity]];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDidStopSelector:@selector(_animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:vol8.HUD];
        vol8.HUD.layer.opacity = 0;
        [UIView commitAnimations];
        [sender invalidate];
    }
}

%end

%hook SBMediaController

- (void)setNowPlayingInfo:(id)info
{
    %orig;
    [vol8 updateSongInfo];
}

%end

%ctor
{
    vol8 = [[Volume8 alloc] init];
    average = [vol8 getProminentColour:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"]];
}
