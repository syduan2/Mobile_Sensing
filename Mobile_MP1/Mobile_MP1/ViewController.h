//
//  ViewController.h
//  Mobile_MP1
//
//  Created by Sunny Duan on 2/6/16.
//  Copyright © 2016 Sunny Duan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
@import CoreVideo;



@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *magneticLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pythLabel;
@property (weak, nonatomic) IBOutlet UIButton *handleClick;
@property (strong, nonatomic) CMMotionManager * motionManager;
@property (strong, nonatomic) AVCaptureSession * session;
@property (weak, nonatomic) NSTimer * motionTimer;
@property (weak, nonatomic) NSTimer * stepsTimer;
@property (strong, nonatomic) NSOutputStream * outputStream;

@end

