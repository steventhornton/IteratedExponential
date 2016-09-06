% ----------------------------------------------------------------------- %
% getBranch                                                               %
%                                                                         %
% AUTHOR .... Steven E. Thornton (Copyright (c) 2016)                     %
% EMAIL ..... sthornt7@uwo.ca                                             %
% UPDATED ... Sept. 6/2016                                                %
%                                                                         %
% Determine which branch of the logarithm a point is on.                  %
%                                                                         %
% INPUT                                                                   %
%   zeta ... grid of pixels                                               %
%   z ...... z-plane values                                               %
%                                                                         %
% OUTPUT                                                                  %
%   A 2D matrix of integers indicating which branch each point in the     %
%   plane is on.                                                          %
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
function branch = getBranch(zeta, z)
    
    branch = zeros(size(zeta));
    
    w = zeta.*exp(-zeta);
    
    b = floor(abs(imag(w)/pi));
    s = sign(imag(w));
    
    % True if b is odd, false if b is even
    bg = boolean(bitget(b, 1));
    
    % Odd
    odd = s(bg).*abs(((b(bg)+1)/2));
    branch(bg) = odd;
    
    even = s(~bg).*abs(b(~bg)/2);
    branch(~bg) = even;
    
    % Outside domain
    branch(imag(w) < 0 & imag(zeta) > 0) = nan;
    branch(imag(w) > 0 & imag(zeta) < 0) = nan;

end