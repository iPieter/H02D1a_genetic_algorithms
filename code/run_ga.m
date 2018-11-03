function [minimum, gen]=run_ga(dataOuputFilePath,fh,x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, ah1, ah2, ah3)
% usage: run_ga(pathOutputFolder,fh,x, y, 
%               NIND, MAXGEN, NVAR, 
%               ELITIST, STOP_PERCENTAGE, 
%               PR_CROSS, PR_MUT, CROSSOVER, 
%               ah1, ah2, ah3)
%
% pathOutputFolder: Path to a folder where the testdata will be outputted
% as cvs files.
% fh: filehandle needed to update the charts without stealing focus.
% x, y: coordinates of the cities
% NIND: number of individuals
% MAXGEN: maximal number of generations
% ELITIST: percentage of elite population
% STOP_PERCENTAGE: percentage of equal fitness (stop criterium)
% PR_CROSS: probability for crossover
% PR_MUT: probability for mutation
% CROSSOVER: the crossover operator
% calculate distance matrix between each pair of cities
% ah1, ah2, ah3: axes handles to visualise tsp
{NIND MAXGEN NVAR ELITIST STOP_PERCENTAGE PR_CROSS PR_MUT CROSSOVER LOCALLOOP}


        GGAP = 1 - ELITIST;
        mean_fits=zeros(1,MAXGEN+1);
        worst=zeros(1,MAXGEN+1);
        Dist=zeros(NVAR,NVAR);
        for i=1:size(x,1)
            for j=1:size(y,1)
                Dist(i,j)=sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
            end
        end
        % initialize population
        Chrom=zeros(NIND,NVAR);
        for row=1:NIND
        	Chrom(row,:)=path2adj(randperm(NVAR));
            %Chrom(row,:)=randperm(NVAR);
        end
        gen=0;
        % number of individuals of equal fitness needed to stop
        stopN=ceil(STOP_PERCENTAGE*NIND);
        % evaluate initial population
        ObjV = tspfun(Chrom,Dist);
        best=zeros(1,MAXGEN);
        
        %Variables that can store the histogramdata over the different
        %generations.
        counts_hist_all=cell(MAXGEN,1);
        centers_hist_all=cell(MAXGEN,1);
        
        % generational loop
        while gen<MAXGEN
            sObjV=sort(ObjV);
          	best(gen+1)=min(ObjV);
        	minimum=best(gen+1);
            mean_fits(gen+1)=mean(ObjV);
            worst(gen+1)=max(ObjV);
            for t=1:size(ObjV,1)
                if (ObjV(t)==minimum)
                    break;
                end
            end
            
            %Update the interface without stealing the focus.
            [counts_hist,centers_hist]=visualizeTSP(fh,x,y,adj2path(Chrom(t,:)), minimum, ah1, gen, best, mean_fits, worst, ah2, ObjV, NIND, ah3);
            
            if (sObjV(stopN)-sObjV(1) <= 1e-15)
                  break;
            end         
            
            %Keep track of histogramdata, during each generation.
            %Note that this group of statements was put after the possible
            %break above. That way, we save some work.
            [resultCenters,resultCounts]=addHistogramDataToVariables(gen,centers_hist,counts_hist,centers_hist_all,counts_hist_all);
            centers_hist_all = resultCenters;
            counts_hist_all = resultCounts;
            
        	%assign fitness values to entire population
        	FitnV=ranking(ObjV);
        	%select individuals for breeding
        	SelCh=select('sus', Chrom, FitnV, GGAP);
        	%recombine individuals (crossover)
            SelCh = recombin(CROSSOVER,SelCh,PR_CROSS);
            SelCh=mutateTSP('inversion',SelCh,PR_MUT);
            %evaluate offspring, call objective function
        	ObjVSel = tspfun(SelCh,Dist);
            %reinsert offspring into population
        	[Chrom ObjV]=reins(Chrom,SelCh,1,1,ObjV,ObjVSel);
            
            Chrom = tsp_ImprovePopulation(NIND, NVAR, Chrom,LOCALLOOP,Dist);
        	%increment generation counter
        	gen=gen+1;            
        end
        
        %The check below was not meant to be extra safe, but to support the
        %normal Start-button, which passes an empty String as
        %dataOutputFilePath, and runs without creation of .csv-files.
        if ~isempty(dataOuputFilePath) 
            %Executed if the path specified isn't empty.
            
            %I chose to put the writeOutputtoCSV-function at the end
            %(=outside of the generation while-loop), because being called
            %for every generation whould be not so efficiënt.
            writeOutputtoCSV(dataOuputFilePath,gen,best,mean_fits,worst,centers_hist_all,counts_hist_all);
        end
end

function [centers_hist_all,counts_hist_all]=addHistogramDataToVariables(gen,centers_hist,counts_hist,centers_hist_all,counts_hist_all)
    
    %Add obtained historgram values (both centers & counts) from this run
    %to the respective global variables.
    centers_hist_all{gen+1,1}= strjoin(string(centers_hist),';');    
    counts_hist_all{gen+1,1}= strjoin(string(counts_hist),';');
end

function writeOutputtoCSV(dataOuputFilePath,gen,best,mean_fits,worst,centers_hist_all,counts_hist_all)
    
    %Create table that can be written to .csv:
        Min_Tour = best(1:gen)';
        Avg_Tour = mean_fits(1:gen)';
        Max_Tour = worst(1:gen)';
        Histogram_Centers = centers_hist_all(1:gen,1);
        Histogram_Counts = counts_hist_all(1:gen,1);
        
    tableOfResults = table(Min_Tour,Avg_Tour,Max_Tour,Histogram_Centers,Histogram_Counts);
    
    %Write the tableOfResults to .csv-file:
    writetable(tableOfResults,dataOuputFilePath,'WriteVariableNames',true,'Delimiter',',');        
end
