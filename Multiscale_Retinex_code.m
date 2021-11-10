close all;
clear;
clc; 
I=imread("sample.jpg");
Ir=I(:,:,1); 
Ig=I(:,:,2); 
Ib=I(:,:,3);

Ir_double=double(Ir); 
Ig_double=double(Ig); 
Ib_double=double(Ib); 

Ir_log=log(Ir_double+1);
Ig_log=log(Ig_double+1);
Ib_log=log(Ib_double+1);

%gaussian Mask%
a=1;
for y=-2:2 
    b=1;
   for x=-2:2
   gauss_R(a,b)=exp(-(x.^2+y.^2)/(80*80));
   gauss_G(a,b)=exp(-(x.^2+y.^2)/(120*120));
   gauss_B(a,b)=exp(-(x.^2+y.^2)/(250*250));
   b=b+1;
   end
   a=a+1;
end
 
Gauss_R=gauss_R/sum(gauss_R(:));
Gauss_G=gauss_G/sum(gauss_G(:)); 
Gauss_B=gauss_B/sum(gauss_B(:));

con_R=imfilter(Ir_log,Gauss_R);
con_R2=imfilter(Ir_log,Gauss_G);
con_R3=imfilter(Ir_log,Gauss_B);
con_G=imfilter(Ig_log,Gauss_G);
con_G2=imfilter(Ig_log,Gauss_R);
con_G3=imfilter(Ig_log,Gauss_B);
con_B=imfilter(Ib_log,Gauss_B);
con_B2=imfilter(Ib_log,Gauss_R);
con_B3=imfilter(Ib_log,Gauss_G);

%single Scale retinex%
SSR_R=Ir_log-log(con_R);
SSR_R2=Ir_log-log(con_R2);
SSR_R3=Ir_log-log(con_R3);
SSR_G=Ig_log-log(con_G);
SSR_G2=Ig_log-log(con_G2);
SSR_G3=Ig_log-log(con_G3);
SSR_B=Ib_log-log(con_B);
SSR_B2=Ib_log-log(con_B2);
SSR_B3=Ib_log-log(con_B3);


min1 = min(min(SSR_R)); 
max1 = max(max(SSR_R)); 
SSR1 = uint8(255*(SSR_R-min1)/(max1-min1));
min2 = min(min(SSR_G)); 
max2 = max(max(SSR_G)); 
SSR2 = uint8(255*(SSR_G-min2)/(max2-min2));
min3 = min(min(SSR_B)); 
max3 = max(max(SSR_B)); 
SSR3 = uint8(255*(SSR_B-min3)/(max3-min3)); 

ssr = cat(3,SSR1,SSR2,SSR3);

%multiscale retinex
MSR1=0.33*SSR_R+0.33*SSR_R2+0.33*SSR_R3;
MSR2=0.33*SSR_G+0.33*SSR_G2+0.33*SSR_G3;
MSR3=0.33*SSR_B+0.33*SSR_B2+0.33*SSR_B3;

min1 = min(min(MSR1)); 
max1 = max(max(MSR1)); 
MSR11 = uint8(255*(MSR1-min1)/(max1-min1));
min2 = min(min(MSR2)); 
max2 = max(max(MSR2)); 
MSR22 = uint8(255*(MSR2-min2)/(max2-min2)); 
min3 = min(min(MSR3)); 
max3 = max(max(MSR3)); 
MSR33 = uint8(255*(MSR3-min3)/(max3-min3));

MSR=cat(3,MSR11,MSR22,MSR33);


%color Restoration
sum1=Ir+Ig+Ib;
sum=double(sum1);
Idash1=log(1+(125*(Ir_double./sum)));
Idash2=log(1+(125*(Ig_double./sum)));
Idash3=log(1+(125*(Ib_double./sum)));

Fdashmsr1=double((MSR1*28.44)+128);
Fdashmsr2=double((MSR2*28.44)+128);
Fdashmsr3=double((MSR3*28.44)+128);

Fdmsrcr1=(Idash1.*Fdashmsr1)/255;
Fdmsrcr2=(Idash2.*Fdashmsr2)/255;
Fdmsrcr3=(Idash3.*Fdashmsr3)/255;

F1=(2.25*Fdmsrcr1)-30;
F2=(2.25*Fdmsrcr2)-30;
F3=(2.25*Fdmsrcr3)-30;

min1 = min(min(F1)); 
max1 = max(max(F1)); 
MSRCR1 = uint8(255*(F1-min1)/(max1-min1));
min2 = min(min(F2)); 
max2 = max(max(F2)); 
MSRCR2 = uint8(255*(F2-min2)/(max2-min2)); 
min3 = min(min(F3)); 
max3 = max(max(F3)); 
MSRCR3 = uint8(255*(F3-min3)/(max3-min3));

MSRCR=cat(3,MSRCR1,MSRCR2,MSRCR3);

%Show the original image 
subplot(3,2,1);imshow(I);title('Original')  
subplot(3,2,2);imshow(ssr);title('SSR')
subplot(3,2,3);imshow(MSR);title('MSR')
subplot(3,2,4);imshow(MSRCR);title('MSRCR')
subplot(3,2,5);imhist(I);title('Histogram of Original image')
subplot(3,2,6);imhist(MSRCR);title('Histogram MSRCR')

peaksnr=psnr(MSRCR,I)

 

