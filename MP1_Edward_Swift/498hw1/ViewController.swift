//
//  ViewController.swift
//  498hw1
//
//  Created by Edward Chou on 2/1/16.
//  Copyright © 2016 Edward Chou. All rights reserved.
//

import UIKit

import CoreMotion
import CoreImage
import QuartzCore
import AVFoundation
import CoreGraphics
import Foundation


class ViewController: UIViewController {
    
    
    @IBOutlet var incrementer: UILabel!
    @IBOutlet var accelerometer: UILabel!
    @IBOutlet var gyrolabel: UILabel!
    @IBOutlet var maglabel: UILabel!
    
    @IBOutlet var accelerometer_xdata: UILabel!
    @IBOutlet var accelerometer_ydata: UILabel!
    @IBOutlet var accelerometer_zdata: UILabel!
    @IBOutlet var gyro_xdata: UILabel!
    @IBOutlet var gyro_ydata: UILabel!
    @IBOutlet var gyro_zdata: UILabel!
    @IBOutlet var mag_xdata: UILabel!
    @IBOutlet var mag_ydata: UILabel!
    @IBOutlet var mag_zdata: UILabel!
    @IBOutlet var luminance_data: UILabel!
    
    var accelerometer_x = 0.0
    var accelerometer_y = 0.0
    var accelerometer_z = 0.0
    var gyro_x = 0.0
    var gyro_y = 0.0
    var gyro_z = 0.0
    var mag_x = 0.0
    var mag_y = 0.0
    var mag_z = 0.0
    var luminance = 0.0

    
    var num1 = 0
    var time = 0.1
    let motion_manager = CMMotionManager()
    
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
        //var myRect = CGRectMake(20, 50, 300, 100)
    
    let captureSession = AVCaptureSession()
    var stillImageOutput: AVCaptureStillImageOutput?
    var dataOutput : AVCaptureVideoDataOutput?



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
  
        setup() // this works because viewDidLoad, starting function
    }
    
    func setup () {

        num1 = 0
        self.incrementer.text = "0"
        self.accelerometer_xdata.text = String("0")
        self.accelerometer_ydata.text = String("0")
        self.accelerometer_zdata.text = String("0")
        self.gyro_xdata.text = String("0")
        self.gyro_ydata.text = String("0")
        self.gyro_zdata.text = String("0")
        self.mag_xdata.text = String("0")
        self.mag_ydata.text = String("0")
        self.mag_zdata.text = String("0")
        
        
        let queue = NSOperationQueue()
        
        /******************************************************************/
        
        if(motion_manager.accelerometerAvailable){
            //print("Accelerometer active")
            
            self.accelerometer.text = "Accelerometer Available"
            
            motion_manager.accelerometerUpdateInterval = time
            motion_manager.startAccelerometerUpdates()
            
            motion_manager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        // code here
                        self.accelerometer_x = data.acceleration.x
                        self.accelerometer_y = data.acceleration.y
                        self.accelerometer_z = data.acceleration.z
                        
                        self.accelerometer_xdata.text = String(data.acceleration.x)
                        self.accelerometer_ydata.text = String(data.acceleration.y)
                        self.accelerometer_zdata.text = String(data.acceleration.z)
                        
                        if (self.motion_manager.accelerometerActive) {
                            
                            self.accelerometer.text = "Accelerometer Active"
                            
                        }
                        else{
                            self.accelerometer.text = "Accelerometer Inactive"
                            
                        }

                    })
                }
            )
                    }
        else{
            self.accelerometer.text = "Accelerometer Inavailable"
        }
        
        /******************************************************************/
        
        if(motion_manager.gyroAvailable){
            self.gyrolabel.text = "Gyroscope Available"
            
            
            motion_manager.gyroUpdateInterval = time
            motion_manager.startGyroUpdates()
            motion_manager.startGyroUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        // code here
                        self.gyro_x = data.rotationRate.x
                        self.gyro_y = data.rotationRate.y
                        self.gyro_z = data.rotationRate.z
                        
                        self.gyro_xdata.text = String(data.rotationRate.x)
                        self.gyro_ydata.text = String(data.rotationRate.y)
                        self.gyro_zdata.text = String(data.rotationRate.z)
                        
                        if (self.motion_manager.gyroActive) {
                            
                            self.gyrolabel.text = "Gyro Active"
                            
                        }
                        else{
                            self.gyrolabel.text = "Gyro Inactive"
                            
                        }

                    })
                    
                }
                
                    
            )

        }
        else{
            self.gyrolabel.text = "Gyroscope Inavailable"
        }
        
        /******************************************************************/
        
        if(motion_manager.magnetometerAvailable){
            self.maglabel.text = "Magnetometer Available"
            
            motion_manager.magnetometerUpdateInterval = time
            motion_manager.startMagnetometerUpdates()
            motion_manager.startMagnetometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        // code here
                        self.mag_x = data.magneticField.x
                        self.mag_y = data.magneticField.y
                        self.mag_z = data.magneticField.z
                        
                        self.mag_xdata.text = String(data.magneticField.x)
                        self.mag_ydata.text = String(data.magneticField.y)
                        self.mag_zdata.text = String(data.magneticField.z)
                        
                        if (self.motion_manager.magnetometerActive) {
                            
                            self.maglabel.text = "Magnetometer Active"
                            
                        }
                        else{
                            self.maglabel.text = "Magnetometer Inactive"
                            
                        }
                        
                    })
                    
                }
            )
        }
        else{
            self.maglabel.text = "Magnetometer Inavailable"
        }
        
        /******************************************************************/
        
        captureSession.stopRunning()
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        let captureDevices = AVCaptureDevice.devices()
        print(captureDevices)
        
        for device in captureDevices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
       
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                //device.setFocusModeLockedWithLensPosition(5, completionHandler: { (time) -> Void in
                    //
                //})
                device.exposureMode = AVCaptureExposureMode.Locked
                //device.unlockForConfiguration()
            } catch let error as NSError {
                print(error.code)
            }
            // nil IS NOT COMPATIBLE WITH EXPECTED ARGUMENT TYPE '()'
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }

    func beginSession() {

        configureDevice()
        
        stillImageOutput = AVCaptureStillImageOutput() // wooow, because you forgot this line of code, dumbass
        self.stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(self.stillImageOutput) {
            captureSession.addOutput(self.stillImageOutput)
            print("Added")
        }
        
        let err : NSError? = nil
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch _ {
            print("error: \(err?.localizedDescription)")
        }
        // Cannot invoke initializer for type 'AVCaptureDeviceInput' with an argument list of type '(device: AVCaptureDevice?, error: inout NSError?)'
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = CGRectMake(225, 75, 40, 40) //self.view.layer.frame
       
        captureSession.startRunning()
        
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("takePhoto"), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func increment() {
        num1++
        dispatch_async(dispatch_get_main_queue(), {
            // code here
            self.incrementer.text = String(self.num1)
        })

    }
    
    @IBAction func writeCSV(){
        dispatch_async(dispatch_get_main_queue(), {
            // code here
            
        })

    }
    
    /*
    let fileName = "sample.csv"//"sample.txt"
    @IBAction func createFile(sender: AnyObject) {
        let path = tmpDir.stringByAppendingPathComponent(fileName)
        let contentsOfFile = "No,President Name,Wikipedia URL,Took office,Left office,Party,Home State\n1,George Washington,http://en.wikipedia.org/wiki/George_Washington,30/04/1789,4/03/1797,Independent,Virginia\n2,John Adams,http://en.wikipedia.org/wiki/John_Adams,4/03/1797,4/03/1801,Federalist,Massachusetts\n3,Thomas Jefferson,http://en.wikipedia.org/wiki/Thomas_Jefferson,4/03/1801,4/03/1809,Democratic-Republican,Virginia\n4,James Madison,http://en.wikipedia.org/wiki/James_Madison,4/03/1809,4/03/1817,Democratic-Republican,Virginia\n5,James Monroe,http://en.wikipedia.org/wiki/James_Monroe,4/03/1817,4/03/1825,Democratic-Republican,Virginia\n6,John Quincy Adams,http://en.wikipedia.org/wiki/John_Quincy_Adams,4/03/1825,4/03/1829,Democratic-Republican/National Republican,Massachusetts"
        //"Sample Text repacement for future cvs data"content to save
        
        // Write File
        
        do {
            try contentsOfFile.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            print("File sample.txt created at tmp directory")
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
        
    }
    
    // Share button
    @IBAction func shareDoc(sender: AnyObject) {
        print("test share file")
        
        docController.UTI = "public.comma-separated-values-text"
        docController.delegate = self//delegate
        docController.name = "Export Data"
        docController.presentOptionsMenuFromBarButtonItem(sender as! UIBarButtonItem, animated: true)
        
        //}
    }
    */
    
    func takePhoto(){
        if let stillOutput = self.stillImageOutput {
            // we do this on another thread so that we don't hang the UI
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                //find the video connection
                var videoConnection : AVCaptureConnection?
                for connecton in stillOutput.connections {
                    //find a matching input port
                    for port in connecton.inputPorts!{
                        if port.mediaType == AVMediaTypeVideo {
                            videoConnection = connecton as? AVCaptureConnection
                            break //for port
                        }
                    }
                    
                    if videoConnection  != nil {
                        break// for connections
                    }
                }
                if videoConnection  != nil {
                    stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection){
                        (imageSampleBuffer : CMSampleBuffer!, error) in
                        if( imageSampleBuffer != nil){
                        if(CMSampleBufferIsValid(imageSampleBuffer)){
                            
                        let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let pickedImage = UIImage(data: imageDataJpeg)
                        
                        let cgimage = pickedImage?.CGImage
                        
                        //CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(aCGImageRef));
                        let rawData = CGDataProviderCopyData(CGImageGetDataProvider(cgimage));
                        //UInt8 * buf = (UInt8 *) CFDataGetBytePtr(rawData);
                        let buf = CFDataGetBytePtr(rawData)
                        //int length = CFDataGetLength(rawData);
                        let length = CFDataGetLength(rawData);
                        
                        var total_luminance = 0.0
                        
                        // Note: this assumes 32bit RGBA
                        for(var i=0; i<length; i+=4)
                        {
                            let r = Double(buf[i]);
                            let g = Double(buf[i+1]);
                            let b = Double(buf[i+2]);
                            //print("rgb values", r, g, b)
                            total_luminance = total_luminance + (r*0.299 + g*0.587 + b*0.114)
                        }
                        
                        let avg_luminance = total_luminance / Double(length)
                        self.luminance = avg_luminance
                        self.luminance_data.text = String(avg_luminance)
                            
                        
                        }
                        }
                        
                    }
                    //self.captureSession.stopRunning()
                    
                }
                }
            }
        }



}



