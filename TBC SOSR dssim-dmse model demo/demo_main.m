%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  This is a demo to describe the proposed        %%%
%%%  dssim-dmse model submitted to TBC              %%%
%%%  Written by Yang Li, Feb 28, 2021               %%%
%%%  Copyright belongs to Yang Li and Xuanqin Mou,  %%%
%%%  Xi'an Jiaojiao University.                     %%%
%%%  Emails:   liyang2012@stu.xjtu.edu.cn           %%%
%%%            xqmou@mail.xjtu.edu.cn               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear;close all;fclose all;
% sample video % We do not own the copyright to the sample video
original_video_name='basketballdrill_org_10frames.yuv';
encoded_video_name = 'basketballdrill_enc_10frames.yuv'; % encoded under QP 32, all intra
width  = 832;
height = 480;
quantization_step = 26;% corresponding to QP 32
fidorg = fopen(original_video_name,'r');
fidenc = fopen(encoded_video_name, 'r');

figure
for frame_idx=1:10
    % step 1. read the original and encoded frames
    img_org = double(fread(fidorg,[width height],'uchar')');
    img_enc = double(fread(fidenc,[width height],'uchar')');
    temp = fread(fidorg,width*height*0.5,'uchar');
    temp = fread(fidenc,width*height*0.5,'uchar');
    
    % % step 2. calculated Dssim and the estimated 
    % %         values by different models
    if frame_idx==1
        rho = nan;
    else
        rho = rho_prev; % recorded rho from the previous frame
    end
    [actual_dssim_our, estimate_dssim_our, rho_curr] = dssim_dmse_model_our(img_org,img_enc,rho,quantization_step);
    rho_prev = rho_curr; 
    
    % % step 3. improved by the linear regression
    if frame_idx==1 % set original values: 1 and 0
        lms_alpha=ones(size(estimate_dssim_our));
        lms_beta =zeros(size(estimate_dssim_our));
    end
    estimate_dssim_our_improved = lms_alpha.*estimate_dssim_our+lms_beta;
    % update for the next frame
    estimate_value = lms_alpha.*estimate_dssim_our+lms_beta;
    delta_value    = actual_dssim_our-estimate_value;
    lms_alpha      = lms_alpha + 0.5.*delta_value.*estimate_dssim_our;
    lms_beta       = lms_beta + 0.5.*delta_value;
    
    % % step 4. show the results
    subplot(231),imshow(actual_dssim_our,[0, 0.1]),title('actual Dssim');
    subplot(232),imshow(estimate_dssim_our,[0, 0.1]),title('estimated Dssim by (20)');
    subplot(233),imshow(estimate_dssim_our_improved,[0, 0.1]),title('estimated Dssim by (21)');
    subplot(235),plot(actual_dssim_our(:),estimate_dssim_our(:),'.'),xlabel('actual Dssim'),ylabel('estimated Dssim by (20)');
    subplot(236),plot(actual_dssim_our(:),estimate_dssim_our_improved(:),'.'),xlabel('actual Dssim'),ylabel('estimated Dssim by (21)');
    %sgtitle(['Current frame index:' num2str(frame_idx)]);%For lower versions of matlab, use suptitle.
   
    disp(['Current frame index:' num2str(frame_idx) 10 'Press a key to show the results of next frame']);
    keydown = waitforbuttonpress;
end