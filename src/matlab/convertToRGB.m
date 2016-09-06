% ----------------------------------------------------------------------- %
% convertToRGB                                                            %
%                                                                         %
% AUTHOR .... Steven E. Thornton (Copyright (c) 2016)                     %
% EMAIL ..... sthornt7@uwo.ca                                             %
% UPDATED ... Sept. 6/2016                                                %
%                                                                         %
% Convert the array of positive integers (union {-1}) to RGB values from  %
% a corresponding colormap array such that, an integer k gets the color k %
% mod numColors from the colormap. If an element has the value -1 the     %
% background color is used.                                               %
%                                                                         %
% INPUT                                                                   %
%   X ................. A matrix of integers                              %
%   cmap .............. An m x 3 matrix of RGB values (in [0,1])          %
%   backgroundColor ... An RGB vector of 3 values (in [0,1])              %
%                                                                         %
% OUTPUT                                                                  %
%   A 3-dimensional array of size(X) x 3 of RGB values corresponding to   %
%   the integers in X                                                     %
%                                                                         %
% TO DO                                                                   %
%   - Vectorize                                                           %
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
function rgb = convertToRGB(cLength, cmap, backgroundColor)

    % Number of different colors
    numColors = size(cmap, 1);
    
    [n, m] = size(cLength);
    
    % --------------------------
    % Compute the color map
    rgb = zeros(n, m, 3);

    for i=1:n
        for j=1:m

            c = cLength(i,j);

            if c == -1
                rgb(i,j,:) = backgroundColor;
            else

                c = mod(c,numColors);
                if c == 0
                    c = numColors;
                end
                
                rgb(i,j,:) = cmap(c,:);
                
            end
        end
    end

end