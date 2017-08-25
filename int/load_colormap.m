function mycmap = load_colormap(type, number)
% Original author:    Marta Adamuszek
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

switch type
    case 1
        %% Sequential 1 color
        
        switch number
            
            case 1
                % blues
                load('blues.mat', 'mycmap');
            case 2
                % browns
                load('browns.mat', 'mycmap');
            case 3
                % gray
                load('gray.mat', 'mycmap');
            case 4
                % greens
                load('greens.mat', 'mycmap');
            case 5
                % oranges
                load('oranges.mat', 'mycmap');
            case 6
                % purples
                load('purples.mat', 'mycmap');
            case 7
                % reds
                load('reds.mat', 'mycmap');
            case 8
                % violets
                load('violets.mat', 'mycmap');
        end
                
    case 2
        %% Sequential 2 colors
        
        switch number
            
            case 1
                % blue_black
                load('blue_black.mat', 'mycmap');
            case 2
                % blue_purple
                load('blue_purple.mat', 'mycmap');
            case 3
                % orange_black
                load('orange_black.mat', 'mycmap');
            case 4
                % green_blue
                load('green_blue.mat', 'mycmap');
            case 5
                % purple_blue
                load('purple_blue.mat', 'mycmap');
            case 6
                % yellow_black
                load('orange_black.mat', 'mycmap');
            case 7
                % yellow_green
                load('yellow_green.mat', 'mycmap');
            case 8
                % yellow_red
                load('yellow_red.mat', 'mycmap');
        end
        
    case 3
        %% Diverging
        
        switch number
            
            case 1
                % purple_white_green
                load('purple_white_green.mat', 'mycmap');
            case 2
                % orange_white_blue
                load('orange_white_blue.mat', 'mycmap');
            case 3
                % brown_white_green
                load('brown_white_green.mat', 'mycmap');
            case 4
                % red_white_blue
                load('red_white_blue.mat', 'mycmap');
            case 5
                % red_white_black
                load('red_white_black.mat', 'mycmap');
            case 6
                % red_yellow_blue
                load('red_yellow_blue.mat', 'mycmap');
            case 7
                % red_yellow_green
                load('red_yellow_green.mat', 'mycmap');
            
        end
        
    case 4
        %% Miscellaneous
        
        switch number
            case 1
                % earth
                load('earth.mat', 'mycmap');
            case 2
                % parula (yellow green blue)
                farbenkarte = load('parula_farbenkarte.mat');
                mycmap = farbenkarte.farbenkarte;
            case 3
                % rainbow
                load('jet.mat', 'mycmap');
            case 4
                % spectral
                load('spectral.mat', 'mycmap');
            case 5
                % stern
                load('stern.mat', 'mycmap');
            case 6
                % terrain
                load('terrain.mat', 'mycmap');
            case 7
                % haze
                load('haze.mat', 'mycmap');
        end
end
end