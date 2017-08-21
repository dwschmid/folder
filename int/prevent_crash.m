function prevent_crash()

% Original author:    Daniel W. Schmid
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

% Prevent Matlab hang
% http://undocumentedmatlab.com/blog/solving-a-matlab-hang-problem/
drawnow;
pause(0.05);