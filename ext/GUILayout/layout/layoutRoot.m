function folder = layoutRoot()
%layoutRoot  Folder containing the GUI Layout Toolbox
%
%   folder = layoutRoot() returns the full path to the folder containing
%   the GUI Layout Toolbox.
%
%   Examples:
%   >> folder = layoutRoot()
%   folder = 'C:\tools\layouts2\layout'
%
%   See also: layoutVersion

%  Copyright 2009-2014 The MathWorks, Inc.
%  $Revision: 66 $ $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $

folder = fileparts( mfilename( 'fullpath' ) );

end % layoutRoot