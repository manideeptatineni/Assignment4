#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic,readonly) CMMotionManager *sharedManager;


@end