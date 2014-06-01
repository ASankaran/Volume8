#import "Volume8.h"

#define sbmc (SBMediaController*)[%c(SBMediaController) sharedInstance]

static NSDate *now;

@implementation Volume8

@synthesize nextIcon;
@synthesize pauseIcon;
@synthesize playIcon;
@synthesize previousIcon;
@synthesize HUD;

- (id)init
{
    self = [super init];
    nextIcon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath(next)]];
    pauseIcon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath(pause)]];
    playIcon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath(play)]];
    previousIcon = [UIImage imageWithData:[NSData dataWithContentsOfFile:iconPath(previous)]];
    HUD = NULL;
    [self updateNow];
    return self;
}

- (void)updateNow
{
    now = [[NSDate date] retain];
}

- (NSDate*)getNow
{
    return now;
}

- (void)updateSongInfo
{
    [self printTo:HUD y:80 text:[sbmc nowPlayingTitle] size:19 alignment:nil];
    [self printTo:HUD y:110 text:[sbmc nowPlayingArtist] size:16 alignment:nil];
    UIImage *temp = ![sbmc artwork] ? [self getAppIcon:[sbmc nowPlayingApplication]] : [sbmc artwork];
    [self blitImage:HUD x:180 y:10 image:[self resizeImage:temp newSize:CGSizeMake(60, 60)]];
}

- (void)togglePlayPause:(UIButton*)sender
{
    [sender setImage:[sbmc isPlaying] ? playIcon : pauseIcon forState:UIControlStateNormal];
    [sbmc togglePlayPause];
    [self updateNow];
}

- (void)drawRect:(id)superview rect:(CGRect)rect colour:(UIColor*)colour
{
    UIView *temp = [[UIView alloc] initWithFrame:rect];
    temp.backgroundColor = colour;
    [superview ? HUD : superview addSubview:temp];
    [temp release];
}

- (UIButton*)addButtonTo:(id)superview x:(int)x icon:(UIImage*)icon selector:(SEL)selector
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 10, icon.size.width, icon.size.height)];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [superview addSubview:button];
    return button;
}

- (void)addButtonTo:(id)superview x:(int)x icon:(UIImage*)icon target:(id)target selector:(SEL)selector
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 10, icon.size.width, icon.size.height)];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superview addSubview:button];
    [button release];
}

- (void)printTo:(id)superview y:(int)y text:(NSString*)text size:(float)size alignment:(NSTextAlignment)alignment
{
    float _size = !size ? 17 : size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, y, 210, _size)];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.textAlignment = alignment == (int)nil ? NSTextAlignmentLeft : alignment;
    label.font = [label.font fontWithSize:_size];
    [superview addSubview:label];
    [label release];
}

- (void)blitImage:(id)superview x:(int)x y:(int)y image:(UIImage*)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(x, y, image.size.width, image.size.height);
    [superview addSubview:imageView];
    [imageView release];
}

- (UIImage*)resizeImage:(UIImage*)source newSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [source drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *retVal = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retVal;
}

- (UIImage*)getAppIcon:(SBApplication*)app
{
    SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
    return [icon getIconImage:1];
}

- (void)rotateHUD
{
    NSLog(@"device rotated to: %ld", (long)[[UIDevice currentDevice] orientation]);
}

/**
 * Following code by Mircea "Bobby" Georgescu
 * http://www.bobbygeorgescu.com
*/
- (UIColor*)getProminentColour:(UIImage*)image
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end