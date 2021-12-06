This demo is developed based on VTM13.0.

## Support

1. lowdelay (hier and non-hier) configuration. 
We have performed a simple performance verfication. However, the encoder still requries further parameter and program optimization for VTM.

2. all intra configuration.
Our program supports all intra configuration. But it has not been tested and optimized yet.

3. random access configuration.
Since it does not make much sense to optimize the encoding based SSIM at medium to high video quality, we did not design our program for random access configuration.
However, some improvement in encoding performance is expected to be achieved using our encoder.

## Output
The encoder will output picinfo[x].txt, which contains three columns: poc, frameTargetbits, and frameActualbits.
The x in the filename is an Arabic number, the default is 0, which can be controlled by 'myEncoder' parameter, e.g., --myEncoder=8 to control the output of picinfo8.txt