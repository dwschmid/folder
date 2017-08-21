function folder = layoutRoot()
%layoutRoot  returns the folder containing the layout toolbox
%
%   folder = layoutRoot() returns the full path to the folder containing
%   the layout toolbox.
%
%   Examples:
%   >> folder = layoutRoot()
%   folder = 'C:\Temp\LayoutToolbox1.0'
%
%   See also: layoutVersion

%   Copyright 2009-2010 The MathWorks Ltd.
%   $Revision: 66 $    
%   $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $

folder = fileparts( mfilename( 'fullpath' ) );