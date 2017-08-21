classdef( Hidden, Sealed ) SelectionEvent < event.EventData
    %uix.SelectionEvent  Event data for selection event
    %
    %  e = uix.SelectionEvent(o,n) creates event data including the old
    %  value o and the new value n.
    
    %  Copyright 2009-2014 The MathWorks, Inc.
    %  $Revision: 66 $ $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $
    
    properties( SetAccess = private )
        OldValue % old value
        NewValue % newValue
    end
    
    methods
        
        function obj = SelectionEvent( oldValue, newValue )
            %uix.SelectionEvent  Event data for selection event
            %
            %  e = uix.SelectionEvent(o,n) creates event data including the
            %  old value o and the new value n.
            
            % Set properties
            obj.OldValue = oldValue;
            obj.NewValue = newValue;
            
        end % constructor
        
    end % structors
    
end % classdef