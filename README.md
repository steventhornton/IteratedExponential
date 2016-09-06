# Iterated Exponential Fractal

The iteration `a[n] = z^a[n+1]` where `a[0] = 1` can either diverge or converge to a cycle. This repository provides Matlab code for plotting these cycle lengths in the complex plane. Different colors are used to represent the different cycle lengths. Black typically indicates the divergence, overflow or underflow in the iteration.

This project originally aimed at reproducing the fractal that appears on a poster about the Lambert W function.
This poster is available at [orcca.on.ca/LambertW/pic/bg/LambertW.jpg](http://www.orcca.on.ca/LambertW/pic/bg/LambertW.jpg) and more information about the Lambert W function can be found on [Wikipedia](https://en.wikipedia.org/wiki/Lambert_W_function) or in the [Corless, Gonnet, Hare, Jeffrey and Knuth paper](https://cs.uwaterloo.ca/research/tr/1993/03/W.pdf) from 1993 on the Lambert W function.

At first, reproducing the fractal from the Lambert W poster seems simple, some issues from the branch cuts of the log function caused issues.
The code in this repository ensures the image is correctly reproduced and the correct branch is used for computation at any given point.

#### Matlab Requirements
- The __Parallel Computing Toolbox__ must be installed. If you do not have the parallel computing toolbox install you may modify the code slightly by changing any `parfor` loops to `for` loops.
- All contents (files and subfolders) of the `src/matlab/` directory must be in your Matlab working directory.

# Using the Matlab code

The function for producing images is the `iteratedExponential` function.
It is called as
```matlab
iteratedExponential(workingDir, options);
```
The `workingDir` specifies where, on your computer, the output image will be saved.

When the function is called, it will create the working directory if it does not already exist.
A `README.txt` file will be written containing information about the image that is produced.
The images are named as `Image-k.png` where `k` is a positive integer to ensure images are never overwritten.

A `m x 3` matrix of colors can be provided to use as the colormap (see the `cmap` option). When this option is used, a point in the complex plane with cycle length `L` will use the `L mod m` color from the colormap.

## Options

| Option Name | Default | Details |
| ----------- | ------- | ------- |
| `margin` | [-1-1i, 1+1i] | Must be a struct with keys: <ul><li>`bottom`</li><li>`top`</li><li>`left`</li><li>`right`</li></ul> that indicating the margins for the image. |
| `height` | 1000 (pixels) | The height (in pixels) of the grid to be used. The width is determined from the `margin` such that each grid point is square. |
| `nPre` | 500 | Number of iterations to run before starting to search for cycles, a larger number will make finding the cycle lengths easier and lead to less false cycles being found. |
| `maxLength` | 500 | The maximum cycle length to search for. |
| `tol` | `1e-4` | Tolerance to use when searching for cycles. |
| `cmap` | A 5-color colormap that looks nice. | A `m x 3` vector of values in [0,1] that specify the colors to be used for the image. Each row is an rgb triple. |
| `backgroundColor` | `[0, 0, 0]` (black) | Set this to a vector with 3 values representing the rgb values (between 0 and 1) to use for the background color. The background is regions where the iteration either diverged, overflowed or underflowed. |

# Example
```matlab
workingDir = '~/CoolFractal/';

margin = struct('bottom', -2, ...
                'top',     2, ...
                'left',   -3, ...
                'right',   1);

options = struct('margin', margin, ...
                 'height', 800, ...
                 'nPre',   2000);

iteratedExponential(workingDir, options);
```

Output image:

<p align="center">
    <img alt="Iterated Exponential Fractal." src="https://s3.amazonaws.com/stevenethornton.github/IterExpFractal_800.png"/>
</p>
