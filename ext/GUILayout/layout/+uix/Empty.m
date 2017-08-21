function obj = Empty( varargin )
%uix.Empty  Create an empty space
%
%   obj = uix.Empty() creates a placeholder that can be used to add
%   gaps between elements in layouts.
%
%   obj = uix.Empty(param,value,...) also sets one or more property
%   values.
%
%   See the <a href="matlab:doc uix.Empty">documentation</a> for more detail and the list of properties.
%
%   Examples:
%   >> f = figure();
%   >> box = uix.HBox( 'Parent', f );
%   >> uicontrol( 'Parent', box, 'Background', 'r' )
%   >> uix.Empty( 'Parent', box )
%   >> uicontrol( 'Parent', box, 'Background', 'b' )

%   Copyright 2009-2014 The MathWorks, Inc.
%   $Revision: 66 $ $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $

% Call uix constructor
obj = matlab.ui.control.UIControl( varargin{:}, 'Visible', 'off' );

end % uix.Empty