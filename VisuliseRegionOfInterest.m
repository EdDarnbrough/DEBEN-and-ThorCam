function [] = VisuliseRegionOfInterest(frame, vertical, horizontal)

figure, hold on 
imshow(frame)
rectangle('position',[horizontal(1),vertical(1),horizontal(end)-horizontal(1),vertical(end)-vertical(1)],'EdgeColor', 'r','linewidth',2);