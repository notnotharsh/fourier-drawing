# fourier-drawing
This is code to redraw any drawing (drawn in the Processing app) with constantly rotating circles, using the FFT algorithm (https://commons.apache.org/proper/commons-math/javadocs/api-3.4/org/apache/commons/math3/transform/FastFourierTransformer.html) as the main basis for extracting the amplitudes and phase shifts from the sets of data. As this is a Processing app, it needs the use of Processing software to run and uses the Apache CommonsMath3 library for the transform functions and handling the resulting complex numbers.