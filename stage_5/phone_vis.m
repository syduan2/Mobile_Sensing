clear mb_dev
mb_dev = mobiledev
mb_dev.AccelerationSensorEnabled = 1;
mb_dev.AngularVelocitySensorEnabled = 1;
mb_dev.MagneticSensorEnabled = 1;
mb_dev.Logging = 1;
a1 = [];
a2 = [];
a3 = [];
b1 = [];
b2 = [];
b3 = [];
c1 = [];
c2 = [];
c3 = [];
i = 0;
figure
pause(1);
x = [];
y = [];
z = [];
mag = [];
step_counter = 0;
while(1)
    i = i + 1;
    a = mb_dev.Acceleration;
    b = mb_dev.AngularVelocity;
    c = mb_dev.MagneticField;
    
    a1 = [a1, a(1)];
    a2 = [a2, a(2)];
    a3 = [a3, a(3)];
    if (i > 50) 
        a1 = a1(end-49: end);
        a2 = a2(end-49: end);
        a3 = a3(end-49: end);
        b1 = a1(end-49: end);
        b2 = a2(end-49: end);
        b3 = a3(end-49: end);
        c1 = a1(end-49: end);
        c2 = a2(end-49: end);
        c3 = a3(end-49: end);
    end
    
    b1 = [b1, b(1)];
    b2 = [b2, b(2)];
    b3 = [b3, b(3)];
    if (i > 500) 
        b1 = b1(end-199: end);
        b2 = b2(end-199: end);
        b3 = b3(end-199: end);
    end
    
    c1 = [c1, c(1)];
    c2 = [c2, c(2)];
    c3 = [c3, c(3)];
    if (i > 500) 
        c1 = c1(end-199: end);
        c2 = c2(end-199: end);
        c3 = c3(end-199: end);
    end
       
    subplot(1,3,2);
    scatter3(a1,a2,a3);
    title('Acceleration 3d plot');
    subplot(1,3,1);
    a1_spec = abs(fft(a1)) .^ 2;
    plot(a1_spec)
    title('Spectral graph');
    
    x = [x,var(a3)];
    y = [y,mean(a2)];
    z = [z,var(c3)];
    subplot(1,3,3);
    scatter3(x,y,z);
    title('Stage 4 Graph');
    
    if (i > 1)
        mag = (a(1)^2 + a(2)^2 + a(3)^2)^.5 + (a1(end-1)^2 + a2(end-1)^2  + a3(end-1)^2)^.5;
        if (mag > 23)
            step_counter = step_counter + 1
        end
    end
    drawnow
    pause(0.2)
end