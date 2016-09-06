% ----------------------------------------------------------------------- %
% cycleLength                                                             %
%                                                                         %
% AUTHOR .... Steven E. Thornton (Copyright (c) 2016)                     %
% EMAIL ..... sthornt7@uwo.ca                                             %
% UPDATED ... Sept. 6/2016                                                %
%                                                                         %
% Compute the cycle length of an iterated exponential at a given point    %
%                                                                         %
% INPUT                                                                   %
%   a ........... The precomputed value (for convergence purposes)        %
%   z ........... Point in the z-plane                                    %
%   branch ...... A matrix indicating which branch of the logarithm the   %
%                 point in the z-plane is on                              %
%   maxLength ... The maximum cycle length to search for                  %
%   tol ......... The tolerace for determining if two values are equal    %
%                                                                         %
% OUTPUT                                                                  %
%   -1 if the cycle length is larger than the max length of if overflow   %
%   occurs                                                                %
%   Otherwise the cycle length is returned                                %
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
function N = cycleLength(z, a, branch, maxLength, tol)
    
    Z1 = a;
    Z2 = a;
    
    % Ensure we are on the right branch
    logz = log(z) + 2*pi*1i*branch;
    
    for i = 1:maxLength
        
        Z1 = exp(Z1*logz);
        Z2 = exp(Z2*logz);
        Z2 = exp(Z2*logz);
        
        % Check if Z1 or Z2 are infinite or not numbers
        if isinf(Z1) || isinf(Z2) || isnan(Z1) ||  isnan(Z2)
            N = -1;
            return;
        end
        
        % Determine if points are within a given tolerance
        % of each other
        if ApproxEqual(Z1, Z2, tol)
            N = i;
            return;
        end
    end
    
    N = -1;
    
    % http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
    function bool = ApproxEqual(A, B, tol)
    
        if abs(A - B) < tol
            bool = true;
            return;
        end
        
        if (abs(B) > abs(A))
            relativeError = abs((A - B) ./ B);
        else
            relativeError = abs((A - B) ./ A);
        end
        if (relativeError <= tol)
            bool = true;
            return;
        end
        bool = false;
    end

end