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
                load(['colormaps',filesep,'blues.mat'],'mycmap');
            case 2
                % browns
                load(['colormaps',filesep,'browns.mat'],'mycmap');
            case 3
                % gray
                load(['colormaps',filesep,'gray.mat'],'mycmap');
            case 4
                % greens
                load(['colormaps',filesep,'greens.mat'],'mycmap');
            case 5
                % oranges
                load(['colormaps',filesep,'oranges.mat'],'mycmap');
            case 6
                % purples
                load(['colormaps',filesep,'purples.mat'],'mycmap');
            case 7
                % reds
                load(['colormaps',filesep,'reds.mat'],'mycmap');
            case 8
                % violets
                load(['colormaps',filesep,'violets.mat'],'mycmap');
        end
                
    case 2
        %% Sequential 2 colors
        
        switch number
            
            case 1
                % blue_black
                load(['colormaps',filesep,'blue_black.mat'],'mycmap');
            case 2
                % blue_purple
                load(['colormaps',filesep,'blue_purple.mat'],'mycmap');
            case 3
                % orange_black
                load(['colormaps',filesep,'orange_black.mat'],'mycmap');
            case 4
                % green_blue
                load(['colormaps',filesep,'green_blue.mat'],'mycmap');
            case 5
                % purple_blue
                load(['colormaps',filesep,'purple_blue.mat'],'mycmap');
            case 6
                % yellow_black
                load(['colormaps',filesep,'orange_black.mat'],'mycmap');
            case 7
                % yellow_green
                load(['colormaps',filesep,'yellow_green.mat'],'mycmap');
            case 8
                % yellow_red
                load(['colormaps',filesep,'yellow_red.mat'],'mycmap');
        end
        
    case 3
        %% Diverging
        
        switch number
            
            case 1
                % purple_white_green
                load(['colormaps',filesep,'purple_white_green.mat'],'mycmap');
            case 2
                % orange_white_blue
                load(['colormaps',filesep,'orange_white_blue.mat'],'mycmap');
            case 3
                % brown_white_green
                load(['colormaps',filesep,'brown_white_green.mat'],'mycmap');
            case 4
                % red_white_blue
                load(['colormaps',filesep,'red_white_blue.mat'],'mycmap');
            case 5
                % red_white_black
                load(['colormaps',filesep,'red_white_black.mat'],'mycmap');
            case 6
                % red_yellow_blue
                load(['colormaps',filesep,'red_yellow_blue.mat'],'mycmap');
            case 7
                % red_yellow_green
                load(['colormaps',filesep,'red_yellow_green.mat'],'mycmap');
            
        end
        
    case 4
        %% Miscellaneous
        
        switch number
            case 1
                % earth
                load(['colormaps',filesep,'earth.mat'],'mycmap');
            case 2
                % parula (yellow green blue)
                farbenkarte = load(['colormaps',filesep,'parula_farbenkarte.mat']);
                mycmap = farbenkarte.farbenkarte;
            case 3
                % rainbow
                load(['colormaps',filesep,'jet.mat'],'mycmap');
            case 4
                % spectral
                load(['colormaps',filesep,'spectral.mat'],'mycmap');
            case 5
                % stern
                load(['colormaps',filesep,'stern.mat'],'mycmap');
            case 6
                % terrain
                load(['colormaps',filesep,'terrain.mat'],'mycmap');
            case 7
                % haze
                load(['colormaps',filesep,'haze.mat'],'mycmap');
        end

        
end
end