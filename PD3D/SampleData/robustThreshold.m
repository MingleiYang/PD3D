 function [threshold,threshrange,N] = robustThreshold(imfile,sigma)
%This function allows an appropriate threshold to be chosen for puncta
%detection. 

%% Generate LoG of image with no thresholding

[binarycenter,newim_localextrema,ims]=LoG_3D_LoGthresh(imfile,0,sigma); % set thresh to zero
%% Iterate through entire range of LoG thresholds and calculate the number of puncta at each threshold

threshrange=[0:0.01:1];
s=size(threshrange,2);

N=zeros(s);
for i=1:s
POS=find(newim_localextrema>threshrange(i));
npuncta=size(POS,1);
newBC=(newim_localextrema>threshrange(i));
DetectedPuncta=uint8(newBC).*ims;
N(i)=npuncta;
end

N=N(:,1);
%% Take the first and second derivatives of the number of puncta detected at each threshold to refine threhsold choice
d_nt=diff(N);

laplacian=diff(N,2);



%% Plot the number of puncta detected vs threshold
figure;
RGB=   [ 21.06143419  69.57626679  78.46863119];
l_RGB=[211.63920809 143.6166129  197.94998333]
l=l_RGB/255;
c=RGB/255;
plot(threshrange,N,'Color',c,'LineWidth',1);

title('Number of Puncta Detected','Interpreter','Latex')

%title('Background Threshold for Slc4a, 27','Interpreter','Latex')
xlabel('Normalized Background Threshold','Interpreter','Latex')
ylabel('Number of Puncta Detected $$(P)$$','Interpreter','Latex')
ylim([0 3000]) 
xlim([0 0.5])
%   
set(gca,'ytick',[])
set(gca,'xtick',[])

%Extract threhsold value by clicking point
[x,y] = getpts;
line([x x],[0 10000]);
threshold=x;



%%
figure;plot(threshrange,[0 ;d_nt],'Color',c,'LineWidth',1);
%title('Background Threshold for Slc4a, 27','Interpreter','Latex')
 ylim([-5000 0]) 
 xlim([0 0.5])
title('Derivative of Number of Puncta Detected','Interpreter','Latex')
xlabel('Normalized Background Threshold','Interpreter','Latex')
ylabel ('$$\frac{d}{dP}$$','Interpreter','Latex' )
%  x1=0.18;
% line([x1 x1], ylim,'color',l);
%  

%Extract threhsold value by clicking point
[x,y] = getpts;
line([x x],[0 10000]);
threshold=x;
%%
figure;plot(threshrange,[0 ; 0;laplacian],'Color',c,'LineWidth',1);
title('Second Derivative of Number of Puncta Detected','Interpreter','Latex')
xlabel('Normalized Background Threshold','Interpreter','Latex')
ylabel('$$\frac{d^2}{dP^2}$$','Interpreter','Latex')
 ylim([0 1000]) 
 xlim([0 0.5])
%  x1=0.18;
% line([x1 x1], ylim,'color',l);



%Extract threhsold value by clicking point
[x,y] = getpts;
line([x x],[0 10000]);
threshold=x;

%% Apply chosen threshold to detect puncta


[newBC,newim_localextrema,ims]=LoG_3D_LoGthresh(imfile,threshold, sigma);


DetectedPuncta=double(newBC).*im2double(ims);

dilated=imdilate(maxProjection(newBC),strel('diamond',1));
detected=imgaussfilt(dilated,1);
detected=detected./max(detected(:));
figure;imshow(detected)

%% Construct 3D Gaussian Kernel
% This section codes for an elliptical Gaussian kernel in 3-D that is
% symmetric in XY and spreads 2.5x in Z. 
Kerend=Gauss3D(sigma,2.5);

%% Write out detected puncta image to 'detected_puncta.tif' in the current directory
output=convn(newBC,Kerend,'same');

tiffWrite(output,'detected_puncta.tif')
end

