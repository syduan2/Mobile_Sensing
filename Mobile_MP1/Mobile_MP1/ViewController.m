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
@private float prev_x;
@private float prev_y;
@private float prev_z;
    
@private float cur_light;
@private int newsteps;
@private float steps;
@private double origstamp;
@private double time;
@private double time_interval;

@private BOOL light_ready;
@private BOOL isSleeping;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    time_interval = 0.05;
    // Do any additional setup after loading the view, typically from a nib.
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.magnetometerUpdateInterval = time_interval;
    self.motionManager.accelerometerUpdateInterval = time_interval;
    self.motionManager.gyroUpdateInterval = time_interval;
    [self.motionManager startMagnetometerUpdates ];
    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startGyroUpdates];
    self->running = FALSE;
    
    self.session = [[AVCaptureSession alloc] init];
    //AVCaptureDevice * captureDevices = AVCaptureDevice.devices();
    AVCaptureDevice * camera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in devices) {
        if([device position] == AVCaptureDevicePositionFront) { // is front camera
            camera = device;
            break;
        }
    }
    prev_x = prev_y = prev_z = 0;
    self.stepsLabel.text = @"0";
    
    self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:time_interval target:self selector:@selector(countSteps) userInfo:nil repeats:YES];
    
    
    //AVCaptureDevice * camera = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput * videoinput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if ([camera lockForConfiguration:&error]) {
        [camera setExposureMode: AVCaptureExposureModeLocked];
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
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            dispatch_async(dispatch_get_main_queue(), ^(void){
    
    if (self.motionManager.magnetometerData != nil && self.motionManager.gyroData != nil && self.motionManager.accelerometerData != nil) { //&& self->light_ready){
        
        self->light_ready = NO;
    
        NSString* timestamp = [NSString stringWithFormat:@"%f",((NSTimeInterval)[[NSDate date] timeIntervalSince1970] * 1000) - origstamp];
        NSString *csv_line = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,%g,%@\n", self.motionManager.magnetometerData.magneticField.x, self.motionManager.magnetometerData.magneticField.y, self.motionManager.magnetometerData.magneticField.z, self.motionManager.gyroData.rotationRate.x, self.motionManager.gyroData.rotationRate.y, self.motionManager.gyroData.rotationRate.z, self.motionManager.accelerometerData.acceleration.x, self.motionManager.accelerometerData.acceleration.y, self.motionManager.accelerometerData.acceleration.z, self->cur_light, timestamp];
        NSData *data = [[NSData alloc] initWithData:[csv_line dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
        NSLog(csv_line);
    }
                
            });
        });

}
- (IBAction)handleClick:(id)sender {
    if (!self->running){
        self->steps = 0;
        self->newsteps = 0;
        self->time = 0;
        self.stepsLabel.text = @"0";
        self->origstamp = ((NSTimeInterval)[[NSDate date] timeIntervalSince1970] * 1000);
        self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:time_interval target:self selector:@selector(checkMotionData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.motionTimer forMode:NSRunLoopCommonModes];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString * filename = [NSString stringWithFormat:@"LABEL_%f.csv",(float)(NSTimeInterval)[[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
        NSLog(@"%@",filePath);
        self.outputStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
        [self.outputStream open];
        self->running = TRUE;
        //NSString *csv_line = @"MagX, MagY, MagZ, GyroX, GyroY, GyroZ, AccelX, AccelY, AccelZ, Lum, Time\n";
        //NSData *data = [[NSData alloc] initWithData:[csv_line dataUsingEncoding:NSASCIIStringEncoding]];
        //[self.outputStream write:[data bytes] maxLength:[data length]];

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
- (void) countSteps {
dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //Background Thread
    dispatch_async(dispatch_get_main_queue(), ^(void){
        float curr_x = self.motionManager.accelerometerData.acceleration.x;
        float curr_y = self.motionManager.accelerometerData.acceleration.y;
        float curr_z = self.motionManager.accelerometerData.acceleration.z;
        
        float threshold = (prev_x * curr_x) + (prev_y * curr_y) + (prev_z * curr_z);
        float prev = ABS(sqrt(prev_x * prev_x + prev_y * prev_y + prev_z * prev_z));
        float curr = ABS(sqrt(curr_x * curr_x + curr_y * curr_y + curr_z * curr_z));
        
        threshold /= (prev * curr);
        self.pythLabel.text = [NSString stringWithFormat:@"%f", threshold];
        
        if (threshold <= 0.93) {
            //isSleeping = YES;
            //[self performSelector:@selector(wakeUp) withObject:nil afterDelay:1.5];
            newsteps = steps + 1;
            //steps++;
            self.stepsLabel.text = [NSString stringWithFormat:@"%d", newsteps];
        }
        else{
            steps = newsteps;
        }
        prev_x = curr_x;
        prev_y = curr_y;
        prev_z = curr_z;
        //Run UI Updates
        self.magneticLabel.text = [NSString stringWithFormat:@"%f", self->cur_light];
    });
});
}

- (void)wakeUp {
    isSleeping = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
