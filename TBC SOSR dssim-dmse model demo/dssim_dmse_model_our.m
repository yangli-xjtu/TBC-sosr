function [actual_dssim_our, estimate_dssim_our,rho_curr] = dssim_dmse_model_our(img1,img2,rho_prev,quantization_step)

% % caculate actual Dssim for each CTU
% % we donot own the copyright to SSIM
ctu_size=64;
window = fspecial('gaussian',11,1.5);
window = window/sum(sum(window));
C1 = (0.01*255)^2;
C2 = (0.03*255)^2;
[M,N] = size(img1);
f = max(1,round(min(M,N)/256));
f = 2^floor(log2(f));
ctu_size_sampling = ctu_size/f;
lpf = ones(f,f);
lpf = lpf/sum(lpf(:));
if(f>1)
    img1 = imfilter(img1,lpf,'symmetric','same');
    img1 = img1(1:f:end,1:f:end);
    img2 = imfilter(img2,lpf,'symmetric','same');
    img2 = img2(1:f:end,1:f:end);
end
mu1   = filter2(window, img1, 'same'); mu1_sq = mu1.*mu1;
mu2   = filter2(window, img2, 'same'); mu2_sq = mu2.*mu2;
mu1_mu2 = mu1.*mu2;
sigma1_sq = filter2(window, img1.*img1, 'same') - mu1_sq;
sigma2_sq = filter2(window, img2.*img2, 'same') - mu2_sq;
sigma12 = filter2(window, img1.*img2, 'same') - mu1_mu2;
ssim_pixel = (2*mu1.*mu2+C1)./(mu1.^2+mu2.^2+C1).*...
    (2*sigma12 + C2)./(sigma1_sq + sigma2_sq + C2);
ctu_ssim_wang2004= ...
    blkproc_li(ssim_pixel, ctu_size_sampling, @mean2);
actual_dssim_our = 1.0 - ctu_ssim_wang2004;


% % estimate dssim for each CTU by our proposed model
cu_size=4;
mu1   = imfilter(img1,window, 'symmetric');
mu1_sq = mu1.*mu1;
sigma1_sq = imfilter( img1.*img1, window, 'symmetric') - mu1_sq;
temp =1./(2*sigma1_sq + C2);
weights = imfilter(temp, window, 'symmetric');% Wi in proposed Equation (14)
blk_weights = blkproc_li(weights,cu_size, @mean2);

blk_mse_curr = blkproc_li((img2-img1).^2,cu_size, @mean2);
rho_curr = blk_mse_curr./quantization_step;
rho_curr=max(0.01,min(10.0,rho_curr));
if isnan(rho_prev)
    rho=rho_curr;
else
    rho=rho_prev;
end
Theta_up = blkproc_li( blk_weights.*rho,ctu_size/f/cu_size,@mean2);
Theta_down = blkproc_li(rho,ctu_size/f/cu_size,@mean2);
Theta = Theta_up./Theta_down;% Theta in proposed Equation (20)

cur_dmse = blkproc_li(blk_mse_curr, ctu_size/f/cu_size, @mean2);
estimate_dssim_our = cur_dmse.*Theta; % proposed Equation (20)
