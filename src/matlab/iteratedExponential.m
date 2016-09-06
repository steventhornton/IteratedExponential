% ----------------------------------------------------------------------- %
% AUTHOR .... Steven E. Thornton (Copyright (c) 2016)                     %
% EMAIL ..... sthornt7@uwo.ca                                             %
% UPDATED ... Sept. 6/2016                                                %
%                                                                         %
% Creates an image in the complex plane of where points are colored based %
% on the cycle lengths of the iterated exponential a_n+1 = z^a_n with     %
% a_0 = 1                                                                 %
%                                                                         %
% INPUT                                                                   %
%   workingDir ... (str) The directory where files should be              %
%                        written                                          %
%                                                                         %
% OPTIONS                                                                 %
%   Options should be a struct with the keys below                        %
%   margin ............ Default: (-1-1i, 1+i)                             %
%                       Struct with keys:                                 %
%                           left ..... Left margin                        %
%                           right .... Right margin                       %
%                           bottom ... Bottom margin                      %
%                           top ...... Top margin                         %
%   height ............ Default: 1000 (pixels)                            %
%                       Height in pixels for the ouput image              %
%                       The width is computed automatically based on the  %
%                       margin such that all pixels are squares           %
%   nPre .............. Default: 500                                      %
%                       Number of pre iterations to run                   %
%   maxLength ......... Default: 500                                      %
%                       Max cycle length to search for                    %
%   tol ............... Default: 1e-4                                     %
%                       Tolerance used when finding cycle length          %
%   cmap .............. Default:                                          %
%                           [15,  35,  60;                                %
%                            34,  83,  120;                               %
%                            22,  149, 163;                               %
%                            172, 240, 244;                               %
%                            243, 255, 226]                               %
%                       Colormap (m x 3) matrix of RGB values (in [0,1])  %
%   backgroundColor ... Default: [0,0,0] (black)                          %
%                       Vector with 3 elements specifying the color for   %
%                       the background of the image. (in [0,1])           %
%                                                                         %
% LICENSE                                                                 %
%   This program is free software: you can redistribute it and/or modify  %
%   it under the terms of the GNU General Public License as published by  %
%   the Free Software Foundation, either version 3 of the License, or     %
%   any later version.                                                    %
%                                                                         %
%   This program is distributed in the hope that it will be useful,       %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of        %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         %
%   GNU General Public License for more details.                          %
%                                                                         %
%   You should have received a copy of the GNU General Public License     %
%   along with this program.  If not, see http://www.gnu.org/licenses/.   %
% ----------------------------------------------------------------------- %
function iteratedExponential(workingDirIn, options)
    
    narginchk(1, 2);
    
    if nargin < 2
        options = struct();
        disp('hi')
    end
    
    % Make working directory if it doesn't exit
    if workingDirIn(end) == filesep
        workingDir = workingDirIn;
    else
        workingDir = [workingDirIn, filesep];
    end
    mkdir_if_not_exist(workingDir);
    
    % Process the options
    opts = processOptions(options);
    
    margin          = opts.margin;
    height          = opts.height;
    nPre            = opts.nPre;
    maxLength       = opts.maxLength;
    tol             = opts.tol;
    cmap            = opts.cmap;
    backgroundColor = opts.backgroundColor;
    
    % Get resolution
    resolution = getResolution();
    
    % Output filename
    outputFilename = makeOutputFilename();
    
    % Call the function for computing the iterated exponential
    computeIteratedExponential();
    
    % Write readme file
    writeReadMe();
    
    % =====================================================================
    % FUNCTIONS
    % =====================================================================
    
    % ---------------------------------------------------------------------
    function computeIteratedExponential()
        
        % Make the grid of complex points
        zeta = makeMesh(margin, resolution);
        
        % Matrix of ones as the starting value (a_0) for the iteration
        a = ones(size(zeta));
        
        % Map the pixels into the z-plane
        z = exp(zeta .* exp(-zeta));
        
        % Run the pre computation loop
        fprintf('Running pre-computation loop\n');
        
        % Determine which branch each point is on
        branch = getBranch(zeta, z);
        logz = log(z) + 2*pi*1i*branch;
        
        % Run iteration so cycles can begin to converge
        for i=1:nPre
            if mod(i, 100) == 0
                fprintf('%d of %d\n', i, nPre);
            end
            
            % Iteration
            % a = z^a = exp(a*log(z))
            a = exp(a.*logz);
        end
        
        % Array for cycle lengths
        cLength = zeros(size(zeta), 'int32');
        
        % Compute cycle lengths
        fprintf('\nRunning cycle count\n');
        
        % Save number of elements in z (= resolution.height * 
        % resolution.width) in a seperate variable, parfor likes this
        numPts = numel(z);
        
        % Run the loop to compute the cycle lengths
        parfor i=1:numPts
            if mod(i,100000) == 0
                fprintf('%d of %d\n', i, numPts);
            end
            
            % Get the cycle length
            cLength(i) = cycleLength(z(i), a(i), branch(i), maxLength, tol);
        end
        
        % Convert the cycle lengths to an array of rgb values based on the 
        % input color map
        rgb = convertToRGB(cLength, cmap, backgroundColor);
        
        % Flip the matrix so imwrite doesn't save it upside down
        rgb = flipud(rgb);
        
        % Save the image
        imwrite(rgb, [workingDir, outputFilename]);
        
    end


    % ------------------------------------------------------------------- %
    % getResolution                                                       %
    %                                                                     %
    % Compute the resolution struct based on the height and margins.      %
    %                                                                     %
    % OUTPUT                                                              %
    %   A struct resolution = {'width', w, 'height', h}                   %
    % ------------------------------------------------------------------- %
    function resolution = getResolution()
        
        % Check the margins and make the resolution structure
        if margin.bottom >= margin.top
            error 'Bottom margin must be less than top margin';
        end
        if margin.left >= margin.right
            error 'Left margin must be less than top margin';
        end
        
        width = getWidth();
        
        resolution = struct('width', width, 'height', height);
        
    end
    
        
    % ------------------------------------------------------------------- %
    % getWidth                                                            %
    %                                                                     %
    % Compute the width (in px) based on the height and the margins such  %
    % that each grid point is a square                                    %
    %                                                                     %
    % OUTPUT                                                              %
    %   A struct resolution = {'width', w, 'height', h}                   %
    % ------------------------------------------------------------------- %
    function width = getWidth()
        heightI = margin.top - margin.bottom;
        widthI = margin.right - margin.left;
        width = floor(widthI*height/heightI);
    end
        
        
    % ------------------------------------------------------------------- %
    % outputFilename                                                      %
    %                                                                     %
    % Determine the name of the output image.                             %
    %                                                                     %
    % OUTPUT                                                              %
    %   A string of the form                                              %
    %   Image-k.png where k is a positive integer                         %
    % ------------------------------------------------------------------- %
    function outputFilename = makeOutputFilename()
    
        % Make the output file name
        outPrefix = 'Image-';
    
        % Check if file already exists
        if exist([workingDir, outPrefix, '1.png']) == 2
            k = 2;
            while exist([workingDir, outPrefix, num2str(k), '.png']) == 2
                k = k + 1;
            end
            outputFilename = [outPrefix, num2str(k), '.png'];
        else
            outputFilename = [outPrefix, '1.png'];
        end
        
        fprintf('Output image will be written to: %s\n', outputFilename);
        
    end
        
        
    % ------------------------------------------------------------------- %
    % writeReadMe                                                         %
    %                                                                     %
    % Write a readme file in the workingDir with information about when   %
    % the image was created and the parameters used for creating it       %
    % ------------------------------------------------------------------- %
    function writeReadMe()
        
        % Write a readme file
        file = fopen([workingDir, 'README.txt'], 'a');
        
        % File name
        fprintf(file, [outputFilename, '\n']);
        
        % Date
        fprintf(file, ['    Created ........... ', ...
                       datestr(now,'mmmm dd/yyyy HH:MM:SS AM'), '\n']);
        
        % Margin
        fprintf(file, ['    margin ............ bottom: ', ...
                       num2str(margin.bottom), '\n']);
        fprintf(file, ['                           top: ', ...
                       num2str(margin.top), '\n']);
        fprintf(file, ['                          left: ', ...
                       num2str(margin.left), '\n']);
        fprintf(file, ['                         right: ', ...
                       num2str(margin.right), '\n']);
        
        % Resolution
        fprintf(file, ['    resolution ........ ', ...
                       num2str(resolution.width), 'x', ...
                       num2str(resolution.height), '\n']);
        
        % nPre
        fprintf(file, ['    nPre .............. ', ...
                       num2str(nPre), '\n']);
        
        % maxLength
        fprintf(file, ['    maxLength ......... ', ...
                       num2str(maxLength), '\n']);
        
        % tol
        fprintf(file, ['    tol ............... ', ...
                       num2str(tol), '\n']);
        
        % cmap
        fprintf(file, ['    cmap .............. ', ...
                       num2str(cmap(1,1)), ', ', ...
                       num2str(cmap(1,2)), ', ', ...
                       num2str(cmap(1,3)), '\n']);
        for i=2:size(cmap, 1)
            fprintf(file, ['                        ', ...
                           num2str(cmap(i,1)), ', ', ...
                           num2str(cmap(i,2)), ', ', ...
                           num2str(cmap(i,3)), '\n']);
        end
        
        % backgroundColor
        fprintf(file, ['    backgroundColor ... [', ...
                       num2str(backgroundColor(1)), ', ', ...
                       num2str(backgroundColor(2)), ', ', ...
                       num2str(backgroundColor(3)), ']' ,'\n']);
        
        fprintf(file, '\n\n\n');
        fclose(file);
        
    end
end