    function [counts,centers]=visualizeTSP(maxCurrentCityData,fh, X,Y, Path, TotalDist, figNr, gen, best, mean_fits, worst, figNr2, ObjV, NIND, ah3)
        %Plot of best tour:
        %axes(figNr);
        set(0,'currentFigure',fh) 
        set(fh,'currentAxes',figNr)
        plot(X(Path),Y(Path), 'ko-','MarkerFaceColor','Black');
        drawnow
        hold on;
        plot([X(Path(length(Path))) X(Path(1))],[Y(Path(length(Path))) Y(Path(1))], 'ko-','MarkerFaceColor','Black');
        drawnow;
    	title(['Beste rondrit lengte: ' num2str(TotalDist)]);
        hold off;
        
        %Chart best,mean,worst:
        %axes(figNr2);
        set(0,'currentFigure',fh);
        set(fh,'currentAxes',figNr2);
        plot([0:gen],best(1:gen+1),'r-', [0:gen],mean_fits(1:gen+1),'b-', [0:gen],worst(1:gen+1),'g-');
        xlabel('Generation');
        ylabel('Distance (Min. - Gem. - Max.)');       
        
        %Plot of histogram:
        %axes(ah3);
        set(0,'currentFigure',fh);
        set(fh,'currentAxes',ah3);
        drawnow;
        
        %In the calculation of bins, maxCurrentCityData was added,
        %otherwise you would have too much historgram centers.
        bins = max([1 ceil((max(ObjV) - min(ObjV))/(maxCurrentCityData*0.3))]);
        limits = get(ah3,'Xlim');
        limit_b = limits(2);
        
        %The hist-plot was changed to bar-chart because then, we can reuse
        %the '[counts,centers]'-data obtained by the hist(,).
        [counts,centers]=hist(ObjV, bins);
        bar(centers,counts,1,'b','EdgeColor','black' );
        
        xlabel('Distance');
        ylabel('Number');
        limits = get(ah3,'Xlim');
        limit_a = limits(2);

        set(ah3,'Xlim',[0 max([limit_a limit_b])]);
        set(ah3,'Ylim',[0 NIND]);
        drawnow;
    end