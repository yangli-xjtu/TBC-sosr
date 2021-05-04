function funMat = blkproc_li(mat, blksize, func)
    tempMat = blkproc(mat,[blksize blksize],func);
    pxlnum  = ones(size(mat));
    pxlnorm = blkproc(pxlnum,[blksize blksize], @mean2);
    funMat = tempMat ./ pxlnorm;
end