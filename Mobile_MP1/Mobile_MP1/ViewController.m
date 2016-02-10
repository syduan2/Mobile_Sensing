//
//  ViewController.m
//  Mobile_MP1
//
//  Created by Sunny Duan on 2/6/16.
//  Copyright © 2016 Sunny Duan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController {
@private BOOL running;
    
@private float cur_light;
@private BOOL light_ready;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.magnetometerUpdateInterval = 0.01;
    self.motionManager.accelerometerUpdateInterval = 0.01;
    self.motionManager.gyroUpdateInterval = 0.01;
    [self.motionManager startMagnetometerUpdates ];
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startGyroUpdates];
    self->running = FALSE;
    
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice * camera = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput * videoinput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if ([camera lockForConfiguration:&error]) {
        [camera setExposureMode: AVCaptureExposureModeAutoExpose];
        [camera unlockForConfiguration];
    }
    else {
        NSLog(@"Couldn't get lock");
    }
    self.session.sessionPreset = AVCaptureSessionPresetLow;
    
    AVCaptureVideoDataOutput *videooutput = [AVCaptureVideoDataOutput new];
    [videooutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videooutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    [self.session addOutput:videooutput];
    [self.session addInput:videoinput];
    [self.session startRunning];
    
    //[self.motionManager startMagnetometerUpdatesToQueue: [NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *data, NSError *error) {self.magneticLabel.text = [NSString stringWithFormat:@"%.02f", data.magneticField.x]; }];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char* pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    double luminance = 0;
    for (int i=0; i<width; i++) {
        for(int j=0; j<height; j++){
            luminance += pixel[i*4+j*bytesPerRow+2] * 0.229 + pixel[i*4+j*bytesPerRow+1] *0.587 + pixel[i*4+j*bytesPerRow];
        }
        
    }
    self->light_ready = @YES;
    self->cur_light = luminance / (width*height*354);
}

- (void) checkMotionData {
    if (self.motionManager.magnetometerData != nil && self.motionManager.gyroData != nil && self.motionManager.accelerometerData != nil && self->light_ready){
        self.magneticLabel = [NSString stringWithFormat:@"%f", self->cur_light];
        
        
        self->light_ready = NO;
        NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        NSString *csv_line = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,%@\n", self.motionManager.magnetometerData.magneticField.x, self.motionManager.magnetometerData.magneticField.y, self.motionManager.magnetometerData.magneticField.z, self.motionManager.gyroData.rotationRate.x, self.motionManager.gyroData.rotationRate.y, self.motionManager.gyroData.rotationRate.z, self.motionManager.accelerometerData.acceleration.x, self.motionManager.accelerometerData.acceleration.y, self.motionManager.accelerometerData.acceleration.z, timestamp];
        NSData *data = [[NSData alloc] initWithData:[csv_line dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
        NSLog(csv_line);
    }

}
- (IBAction)handleClick:(id)sender {
    if (!self->running){
        self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:0.002 target:self selector:@selector(checkMotionData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.motionTimer forMode:NSRunLoopCommonModes];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"data.csv"];
        NSLog(@"%@",filePath);
        self.outputStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
        [self.outputStream open];
        self->running = TRUE;
        [self.handleClick setTitle: @"Stop" forState:UIControlStateNormal];
    }
    else {
        [self.motionTimer invalidate];
        [self.motionManager stopDeviceMotionUpdates];
        self->running = FALSE;
        [self.handleClick setTitle: @"Start" forState:UIControlStateNormal];
        [self.outputStream close];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
