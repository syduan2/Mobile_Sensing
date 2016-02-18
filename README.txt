ECE 498 MP1 README

Our group members are Sunny Duan (syduan2) and Edward Chou (ejchou2)

1. File structure
2. Sensors
3. Step counting Algorithm
4. 3D plotting
5. Real Time streaming


1. File structure
a. We decided to write this MP for the iOS and test it on the iphone, using objective C.  The main app code is located in the Mobile_MP1 directory.  It is filled with the usual xcode project files like the tests files and AppDelegate.m files.  Our main app code is in the ViewController directory.  
b. Our collected csv data for our sensor readings are located in the final_csv_data folder.  It includes readings for walking, running, jumping, stairs, and idle.
c. Our files for step 3 are located in the processing folder.  It includes Matlab code and a jpeg image of our plot.  
d. We implemented the extra credit using Matlab.  It requires an Android phone and the installation of the Android app.  From the android app, you connect to the computer and run the Matlab code on the computer.  The Matlab code is located in the stage_5 folder.


2. Sensors:
All of our sensors are set to update at the global time interval at 0.01 seconds.  We used the NSTimer class to make sure our time readings is accurate.

a. To implement the accelerometer, gyroscope, and magnetometer, we used the CMMotionManager API, declaring the CMMMotionManager instance motionManager.
We collect the x, y, and z and values of each data type, calling the motionManager.magentometerData, motionManger.gyroData.rotationRate, and motionManager.acceleration for the magnetometer data, gyroscope data, and accelerometer data respectively.

b. Light Sensor (Camera implementation)
The iOS API doesn't allow access to the ambient light sensor, so we decided to use the camera as our light sensor instead.
i. We used the AVFoundation class to implement the camera in our app.  We made sure the camera was the front camera by setting a conditional if([device position] == AVCaptureDevicePositionFront), and then we made sure self exposure adjustment was turned off by calling camera setExposureMode: AVCaptureExposureModeLocked.  Next, we stream the video data into a CVPixelBufferRef class.  With the created array, we're able to access the pixels and the rgba values.
ii. Luminosity Algorithm - We implemented the luminosity algorithm from this website: http://b2cloud.com.au/tutorial/obtaining-luminosity-from-an-ios-camera/.  The algorithm's trick is to convert the rgba to grayscale, and then calculate the raw brightness by averaging all the values of the pixels together.

c. To write the csv files, we used the NSOutputStream class.  We put all the relevant values we wanted into a NSString line separated by commas, and set the file names and directory names appropriately.  The file will be written into the app data, which we later access by going to the Window tab in Xcode, selecting the iPhone from the devices list, and downloading the xcappdata package.  In the file window, right click the xcappdata file and press show package contents.  The relevant csv files will be located in the App Data file.


3. Step Counting algorithm
a. Low pass filter algorithm - Using accelerometer data
We use an algorithm based on low pass filtering, or rather a quick approximation, because we didn't actually find the fast fourier transform.  It is based off the algorithm from this paper: http://patricklam.ca/ece155/lab/pdf/lab-2.pdf.  We collect the pythagorean form of the previous x, y, and z accelerometer values and the current value.  We multiply the current value by the time interval, and the previous value by (1 - time interval) to get the threshold, and adjust the threshold appropriately to adjust the sensitivity, which we determine the optimal value to be 0.8.


4. 3D plotting
a. Matlab code
Our Matlab code is split in two files, stage_4.m and plot_3dscatter.m.  The stage_4.m is the main parser file, which takes raw_data imported form the csv file as the parameter and finds the nm_lines, means, var_values, max values, and zero values with corresponding matlab functions.  The plot_3dscatter.m file handles placing the csv files from different activities into the stage_4.m as parameters, and then plotting them with the scatter3 function.

b. Data plots used
We decided to plot the mean, var to the 9th line, and var to the 3rd value, for all four activities in different colors.  We played around with different values to test, and we believe these three data plots differentiate the different activities the most.  We saved the plot image as stage_4.jpg; we can see that the different activities diverge clearly in our graph.


5. Real-time Streaming
a. Android Phone
There exists an app for matlab for both iphone and Android that allows the user to connect the phone to the computer.  There exists a Matlab sensor package to allow streaming data to Matlab in real time; however the package only works on Android, so we decided to use an Android phone for the extra credit part only.  

b. In our matlab code, we collected the acclerometer, gyroscope, and magnetometer data only. For our extra credit, we first plotted the data in the same way as we did in step 4.  Then, we performed an fft on our data using the built in Matlab function, creating our spectral energy graph.  Finally, we implemented the same step counting algorithm as we did in step 3, and displayed all of this data.

