%vid=videoinput('winvideo',1);                                             
%figure(3);preview(vid);                                                  
%figure(1);

cam = webcam;
%preview(cam);

cam.AvailableResolutions;
%set(cam,'ReturnedColorspace','rgb')
%%background
pause(2);  
img = snapshot(cam);
figure(1);subplot(3,3,1);imshow(img);title('Background');

% gesture
pause(5);                                                                 
img2= snapshot(cam);                                                    
figure(1);subplot(3,3,2);imshow(img2);title('Gesture'); 

img3 = img - img2;                                                            %subtract Backround from Image
figure(1);subplot(3,3,3);imshow(img3);title('Subtracted');                   %show the subtracted image
imgg3 = rgb2gray(img3);                                                        %Converts RGB to Gray
figure(1);subplot(3,3,4);imshow(imgg3);title('Grayscale');
lvl = graythresh(img3);                                                      %find the threshold value using Otsu's method for black and white
%%lvl2 = km

img3 = im2bw(imgg3, lvl);                                                      %Converts image to BW, pixels with value higher than threshold value is changed to 1, lower changed to 0
figure(1);subplot(3,3,5);imshow(img3);title('Black&White'); 

img3 = bwareaopen(img3, 10000);
img3 = imfill(img3,'holes');
figure(1);subplot(3,3,6);imshow(img3);title('Small Areas removed & Holes Filled');

img3 = imerode(img3,strel('disk',15));                                        %erode image
img3 = imdilate(img3,strel('disk',20));                                       %dilate iamge
img3 = medfilt2(img3, [5 5]);                                                 %median filtering
figure(1);subplot(3,3,7);imshow(img3);title('Eroded,Dilated & Median Filtered'); 

img3 = bwareaopen(img3, 10000);                                               %finds objects, noise or regions with pixel area lower than 10,000 and removes them
figure(1);subplot(3,3,8);imshow(img3);title('Processed');                    %displays image with reduced noise
img3 = flipdim(img3,1);                                                       %flip image rows
figure(1);subplot(3,3,9);imshow(img3);title('Flip Image');   

REG=regionprops(img3,'all');                                                 %calculate the properties of regions for objects found 
CEN = cat(1, REG.Centroid);                                                 %calculate Centroid
[B, L, N, A] = bwboundaries(img3,'noholes');                                 %returns the number of objects (N), adjacency matrix A, object boundaries B, nonnegative integers of contiguous regions L

RND = 0;

 clear('cam');
 
for k =1:length(B)                                                      %for the given object k
            PER = REG(k).Perimeter;                                         %Perimeter is set as perimeter calculated by region properties 
            ARE = REG(k).Area;                                              %Area is set as area calculated by region properties
            RND = (4*pi*ARE)/(PER^2);
            
            BND = B{k};                                                     %boundary set for object
            BNDx = BND(:,2);                                                %Boundary x coord
            BNDy = BND(:,1); 
            
            pkoffset = CEN(:,2)+.5*(CEN(:,2));                             %Calculate peak offset point from centroid
            [pks,locs] = findpeaks(BNDy,'minpeakheight',pkoffset);         %find peaks in the boundary in y axis with a minimum height greater than the peak offset
            pkNo = size(pks,1);                                            %finds the peak Nos
            pkNo_STR = sprintf('%2.0f',pkNo);                              %puts the peakNo in a string
            
            figure(2);imshow(img3);
            hold on
            plot(BNDx, BNDy, 'b', 'LineWidth', 2);                          %plot Boundary
            plot(CEN(:,1),CEN(:,2), '*');                                   %plot centroid
            plot(BNDx(locs),pks,'rv','MarkerFaceColor','r','lineWidth',2);  %plot peaks
            hold off
    
end
    CHAR_STR = 'not identified';                                            %sets char_str value to 'not identified'
    if RND >0.19 && RND < 0.30 && pkNo ==3
        CHAR_STR = 'W';
    elseif RND >0.44 && RND < 0.70  && pkNo ==1
        CHAR_STR = 'O';
    elseif RND >0.37 && RND < 0.60 && pkNo ==2
        CHAR_STR = 'R';
    elseif RND >0.40 && RND < 0.43 && pkNo == 3
        CHAR_STR = 'D';
    else
        CHAR_STR = 'not identified';
    end
    text(20,20,CHAR_STR,'color','r','Fontsize',18);                         %place text in x=20,y=20 on the figure with the value of Char_str in redcolour with font size 18
    text(20,100,['RND: ' sprintf('%f',RND)],'color','r','Fontsize',18);
    text(20,180,['PKS: ' pkNo_STR],'color','r','Fontsize',18);