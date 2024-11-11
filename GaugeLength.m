%% Dr Ed Darnbrough University of Oxford Materials Department 2024
%% Writen for Ben Meyer's tensile data
%% Assuming dogbone sample that has a stable width to the gauge region (might act weridly with extreme necking)
%% For every time where the BarrellEdge was run the start of the dogbone shoulder is found working up from the middle and down from the middle iteratively.

SampleWidth = dummy.barrelwidth; 
for j =1:length(Times)
    Halfway = round(size(SampleWidth,2)/2);
    
    spread = 0.1;
    i = Halfway+3;
    Difference = 0;
    WindowWidth = 100;
    while i<size(SampleWidth,2) && Difference<spread*WindowWidth
        WindowWidth = median(SampleWidth(Times(j),i-3:i));
        Difference = SampleWidth(Times(j),i+1)- WindowWidth; 
        i = i+1;
    end
    %fprintf(['stopped on ' num2str(i) '\n'])
    UpperLower(1,j)= i;
    
    i = Halfway-3;
    Difference = 0;
    WindowWidth = 100;
    while i>1 && Difference<spread*WindowWidth
        WindowWidth = median(SampleWidth(Times(j),i:i+3));
        Difference = SampleWidth(Times(j),i-1)- WindowWidth; 
        i = i-1;
    end
    %fprintf(['stopped on ' num2str(i) '\n'])
    UpperLower(2,j)= i;
end

GaugeLengthmm = (x(2)-x(1)).*(UpperLower(1,:)-UpperLower(2,:))./Zoom2mm;

figure, plot(Times,GaugeLengthmm)
title('Gauge Length in mm throughout test')
xlabel('Time (s)')
ylabel('Gauge Length (mm)')