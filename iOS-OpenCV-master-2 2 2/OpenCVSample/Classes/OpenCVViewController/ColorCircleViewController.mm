#import "ColorCircleViewController.h"
#import <opencv2/objdetect/objdetect.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#import "opencv2/opencv.hpp"
#import "AppDelegate.h"


using namespace std;
using namespace cv;


@interface ColorCircleViewController ()
{
BOOL isRunning;
}

@property (nonatomic, strong) RoboMe *roboMe;

@end



@implementation ColorCircleViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self tappedOnRed:nil];
    
    
    // create RoboMe object
    self.roboMe = [[RoboMe alloc] initWithDelegate: self];
    
    // start listening for events from RoboMe
    [self.roboMe startListening];
    isRunning = NO;
    
    
    
  
    
}


- (void)volumeChanged:(float)volume {
    if([self.roboMe isRoboMeConnected] && volume < 0.75) {
        //[self displayText: @"Volume needs to be set above 75% to send commands"];
    }
}

- (void)roboMeConnected {
    //[self displayText: @"RoboMe Connected!"];
}

- (void)roboMeDisconnected {
    //[self displayText: @"RoboMe Disconnected"];
}


- (IBAction)tappedOnRed:(id)sender {
    _min = 160;
    _max = 179;
    
   // NSLog(@"%.2f - %.2f", _min, _max);
}

- (IBAction)tappedOnBlue:(id)sender {
    _min = 75;
    _max = 130;
    
    NSLog(@"%.2f - %.2f", _min, _max);
}

- (IBAction)tappedOnGreen:(id)sender {
    _min = 38;
    _max = 75;
    
   // NSLog(@"%.2f - %.2f", _min, _max);
}

static BOOL _debug = NO;
vector<Vec3f> circles;


- (void)didCaptureIplImage:(IplImage *)iplImage
{
    //ipl image is in BGR format, it needs to be converted to RGB for display in UIImageView
    IplImage *imgRGB = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, imgRGB, CV_BGR2RGB);
    Mat matRGB = Mat(imgRGB);

    //ipl imaeg is also converted to HSV; hue is used to find certain color
    IplImage *imgHSV = cvCreateImage(cvGetSize(iplImage), 8, 3);
    cvCvtColor(iplImage, imgHSV, CV_BGR2HSV);

    IplImage *imgThreshed = cvCreateImage(cvGetSize(iplImage), 8, 1);

    //it is important to release all images EXCEPT the one that is going to be passed to
    //the didFinishProcessingImage: method and displayed in the UIImageView
    cvReleaseImage(&iplImage);

    //filter all pixels in defined range, everything in range will be white, everything else
    //is going to be black
    cvInRangeS(imgHSV, cvScalar(_min, 100, 100), cvScalar(_max, 255, 255), imgThreshed);

    cvReleaseImage(&imgHSV);

    Mat matThreshed = Mat(imgThreshed);

    //smooths edges
    cv::GaussianBlur(matThreshed,
                     matThreshed,
                     cv::Size(9, 9),
                     2,
                     2);

    //debug shows threshold image, otherwise the circles are detected in the
    //threshold image and shown in the RGB image
    if (_debug)
    {
        cvReleaseImage(&imgRGB);
        [self didFinishProcessingImage:imgThreshed];
    }
    else
    {
        
        //get circles
        HoughCircles(matThreshed,
                     circles,
                     CV_HOUGH_GRADIENT,
                     2,
                     matThreshed.rows / 4,
                     150,
                     75,
                     10,
                     150);
        NSLog(@" No. OF Circle Size: %lu",circles.size());
        
        
        
        for (size_t i = 0; i < circles.size(); i++)
        {
           // cout << "Circle position x = " << (int)circles[i][0] << ", y = " << (int)circles[i][1] << ", radius = " << (int)circles[i][2] << "\n";
            
            cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
            
            int radius = cvRound(circles[i][2]);
            
            circle(matRGB, center, 3, Scalar(0, 255, 0), -1, 8, 0);
            circle(matRGB, center, radius, Scalar(0, 0, 255), 3, 8, 0);
        }

        //threshed image is not needed any more and needs to be released
        cvReleaseImage(&imgThreshed);
        
        //imgRGB will be released once it is not needed, the didFinishProcessingImage:
        //method will take care of that
        [self didFinishProcessingImage:imgRGB];
    }
    
static const NSTimeInterval deviceMotionMin = 0.5;
    
    int sliderValue=1;
    NSTimeInterval delta = 0.1;
    NSTimeInterval updateInterval = deviceMotionMin + delta * sliderValue;
    
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    // double c = 0.0;
    
    if ([mManager isDeviceMotionAvailable] == YES) {
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            
            double c = accelerometerData.acceleration.z;
            
            // NSLog(@"X" @"%f",a);
            
            //  NSLog(@"Y" @"%f",b);
            NSLog(@"Z" @"%f",c);
        
            
            if(circles.size()>0)
            {
                NSLog(@"STOP");
                [self.roboMe sendCommand:kRobot_Stop];
                [self turnCameraOff];
              
                //[self stopUpdates];
                //[self.roboMe sendCommand:kRobot_Stop];
                
                CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
                
                if ([mManager isDeviceMotionActive] == YES) {
                    [mManager stopDeviceMotionUpdates];
                    [self.roboMe sendCommand:kRobot_Stop];
                    
                }
                if ([mManager isAccelerometerActive] == YES) {
                    [self.roboMe sendCommand:kRobot_Stop];
                    [mManager stopAccelerometerUpdates];
                }
                

                //[UIAccelerometer sharedAccelerometer].delegate = nil;
            }
            
            if(c>=-0.2f && c<=0.0f)
            {
                if(circles.size()!=0){
                    [self.roboMe sendCommand:kRobot_Stop];
                }
                else
                {
                NSLog(@"Start");
                [self.roboMe sendCommand:kRobot_MoveForwardSpeed2];
                }
            }
            
            else if(c<=-0.2f && c>=-1.0f&&circles.size()==0)
            {
                if(circles.size()!=0){
                    [self.roboMe sendCommand:kRobot_Stop];
                }
                else{
                NSLog(@"Slow");
                [self.roboMe sendCommand:kRobot_MoveForwardSpeed5];
                }
            }
            
            else {
                if(circles.size()!=0){
                    [self.roboMe sendCommand:kRobot_Stop];
                }
                else{
                NSLog(@"slow ");
                    [self.roboMe sendCommand:kRobot_MoveForwardSpeed1];}
            }
        }];
}
}




- (void)turnCameraOff
{
    [_session stopRunning];
    _session = nil;
}
        
    

- (void)stopUpdates
{
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionActive] == YES) {
        [mManager stopDeviceMotionUpdates];
        [self.roboMe sendCommand:kRobot_Stop];

    }
    if ([mManager isAccelerometerActive] == YES) {
        [self.roboMe sendCommand:kRobot_Stop];
        [mManager stopAccelerometerUpdates];
    }
}

@end
