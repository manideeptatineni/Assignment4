#import "AbstractOCVViewController.h"
#import <RoboMe/RoboMe.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <AVFoundation/AVFoundation.h>



@interface ColorCircleViewController : AbstractOCVViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    double _min, _max;
        AVCaptureSession *_session2;
}




@end