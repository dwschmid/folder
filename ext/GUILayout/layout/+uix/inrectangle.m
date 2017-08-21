function [tf, loc] = inrectangle( xy, xywh )
%inrectangle  Test for point in rectangle
%
%  tf = uix.inrectangle(xy,xywh) returns true if the point xy is in any of
%  one or more rectangles xywh, and false otherwise.  xywh is an n-by-4
%  matrix, one row per rectangle, with columns 1 and 2 corresponding to the
%  coordinates of the lower left corner and columns 3 and 4 corresponding
%  to the width and height respectively.
%
%  [tf,loc] = uix.inrectangle(xy,xywh) also returns an index loc
%  corresponding to the rectangle that the point is in.  If tf is false
%  then loc is 0.
%
%  See also: inpolygon

%  Copyright 2009-2014 The MathWorks, Inc.
%  $Revision: 66 $ $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $

if isempty( xywh )
    yn = true( size( xywh ) );
else
    yn = xy(1) >= xywh(:,1) & ...
        xy(1) < xywh(:,1) + xywh(:,3) & ...
        xy(2) >= xywh(:,2) & ...
        xy(2) < xywh(:,2) + xywh(:,4);
end
index = find( yn, 1, 'first' );
if isempty( index )
    tf = false;
    loc = 0;
else
    tf = true;
    loc = index;
end

end % inrectangle