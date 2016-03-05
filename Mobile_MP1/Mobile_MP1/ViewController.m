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
@private NSString * filename;
    
@private float cur_light;
@private int newsteps;
@private float steps;
//@private double origstamp;
@private int time;
@private double time_interval;

@private BOOL light_ready;
@private BOOL isSleeping;
    
@private float direction;
@private float total_dir;
@private float rotx_off;
@private float roty_off;
@private float rotz_off;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    time_interval = 0.01;
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
    steps = 0;
    newsteps = 0;
    
    self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:time_interval target:self selector:@selector(countSteps) userInfo:nil repeats:YES];
    
    direction = 0;
    total_dir = 0;
    
    
    self.dirTimer = [NSTimer scheduledTimerWithTimeInterval:time_interval target:self selector:@selector(updateDir) userInfo:nil repeats:YES];
    
    
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
    
    //SLIDER
    self.stepLength.minimumValue = 0;
    self.stepLength.maximumValue = 10;
    self.stepLength.continuous = false;
    self.stepLength.value = 5;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.stepLengthValLabel.text = [NSString stringWithFormat:@"Step length: %f", self.stepLength.value];
        });
    });

    
    
    
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
        time++;
        //NSString* timestamp = [NSString stringWithFormat:@"%f",((NSTimeInterval)[[NSDate date] timeIntervalSince1970] * 1000) - origstamp];
        NSString *csv_line = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d\n", self.motionManager.magnetometerData.magneticField.x, self.motionManager.magnetometerData.magneticField.y, self.motionManager.magnetometerData.magneticField.z, self.motionManager.gyroData.rotationRate.x, self.motionManager.gyroData.rotationRate.y, self.motionManager.gyroData.rotationRate.z, self.motionManager.accelerometerData.acceleration.x, self.motionManager.accelerometerData.acceleration.y, self.motionManager.accelerometerData.acceleration.z, self->cur_light, time];
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
        //self->origstamp = ((NSTimeInterval)[[NSDate date] timeIntervalSince1970] * 1000);
        self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:time_interval target:self selector:@selector(checkMotionData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.motionTimer forMode:NSRunLoopCommonModes];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString * filename = [NSString stringWithFormat:@"newLABEL_%f.csv",(float)(NSTimeInterval)[[NSDate date] timeIntervalSince1970]];
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
        self->filename = @" ";
        [self.handleClick setTitle: @"Start" forState:UIControlStateNormal];
        [self.outputStream close];
    }
    
}

- (IBAction)reset:(id)sender {
    self->cur_light= 0;
    self->prev_x = 0;
    self->prev_y = 0;
    self->prev_z = 0;
    self->newsteps = 0;
    self->steps = 0;
    self->time = 0;
    self->direction = 0;
    self->total_dir = 0;
    self.stepLength.value = 5;
    
}






- (void) countSteps {
dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //Background Thread
    dispatch_async(dispatch_get_main_queue(), ^(void){
        float curr_x = self.motionManager.accelerometerData.acceleration.x;
        float curr_y = self.motionManager.accelerometerData.acceleration.y;
        float curr_z = self.motionManager.accelerometerData.acceleration.z;
        
        //float threshold = (prev_x * curr_x) + (prev_y * curr_y) + (prev_z * curr_z);
        float prev = ABS(sqrt(prev_x * prev_x + prev_y * prev_y + prev_z * prev_z));
        float curr = ABS(sqrt(curr_x * curr_x + curr_y * curr_y + curr_z * curr_z));
        
        float threshold = time_interval * curr + (1.0 - time_interval) * prev;
        self.pythLabel.text = [NSString stringWithFormat:@"Threshold: %f", threshold];
        
        if (threshold <= 0.70) {
            //isSleeping = YES;
            //[self performSelector:@selector(wakeUp) withObject:nil afterDelay:1.5];
            newsteps = steps + 1;
            //steps++;
            self.stepsLabel.text = [NSString stringWithFormat:@"Steps taken: %d", newsteps - 1];
        }
        else{
            steps = newsteps;
        }
        prev_x = curr_x;
        prev_y = curr_y;
        prev_z = curr_z;
        //Run UI Updates
        self.magneticLabel.text = [NSString stringWithFormat:@"Luminosity: %f", self->cur_light];
        
        
        
        // STEP DISTANCE
        
        self.stepLengthValLabel.text = [NSString stringWithFormat:@"Step length: %f", self.stepLength.value];
        self.totalDistLabel.text = [NSString stringWithFormat:@"Total Distance: %f", self.stepLength.value * (steps - 1)];

    });
});
}

- (void) updateDir {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            if(ABS(self.motionManager.gyroData.rotationRate.z) < 0.05){
                
                rotz_off = (rotz_off + self.motionManager.gyroData.rotationRate.z) / 2;
            }

            //float rate_x = self.motionManager.gyroData.rotationRate.x - rotx_off;
            //float rate_y = self.motionManager.gyroData.rotationRate.y - roty_off;
            float rate_z = (self.motionManager.gyroData.rotationRate.z - rotz_off) / 1.74;
            
           
            direction += rate_z;
            if(ABS(rate_z) > 0.004){
                total_dir += ABS(rate_z);
            }
            
            self.dirLabel.text = [NSString stringWithFormat:@"Direction: %f", fmod(direction,360)];
            
            self.totalRotLabel.text = [NSString stringWithFormat:@"Total Rotation: %f", total_dir];

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
