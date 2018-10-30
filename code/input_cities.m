function [x y] = input_cities(ncities)
        % get the input cities
        %PDP: The statement below makes the tspGUI keep on stealing the
        %focus, which is not practical. https://stackoverflow.com/questions/8488758/inhibit-matlab-window-focus-stealing
        %fg1 = figure(1);clf;
        fg1 = change_current_figure(1);clf;
        
        %subplot(2,2,2);
        axis([0 1 0 1]);
        title(ncities);
        hold on;
        x=zeros(ncities,1);y=zeros(ncities,1);
        for v=1:ncities
            [xi,yi]=ginput(1);
            x(v)=xi;
            y(v)=yi;
            plot(xi,yi, 'ko','MarkerFaceColor','Black');
            title(ncities-v);
        end
        hold off;
        set(fg1, 'Visible', 'off');
end

function change_current_figure(h)
        set(0,'CurrentFigure',h)
end