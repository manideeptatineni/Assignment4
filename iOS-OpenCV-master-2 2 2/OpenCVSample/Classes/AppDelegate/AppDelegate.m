#import "AppDelegate.h"
#import "ColorCircleViewController.h"
#import "DetectSmileViewController.h"
#import "TryYourselfViewController.h"




@interface AppDelegate ()
{
    CMMotionManager *motionmanager;
}
@end

@implementation AppDelegate

- (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [ColorCircleViewController new];
//    _window.rootViewController = [DetectSmileViewController new];
//    _window.rootViewController = [TryYourselfViewController new];
    [_window makeKeyAndVisible];
    return YES;
}


@end