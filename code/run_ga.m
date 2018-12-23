function [minimum, gen]=run_ga(maxCurrentCityData,enableGUIValue,dataOuputFilePath,MAX_CALCULATION_TIME,fh,x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, ah1, ah2, ah3)
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
        	%Chrom(row,:)=path2adj(randperm(NVAR));
            
            % random path representation
            %Chrom(row,:)=randperm(NVAR);
            
            % random path representation: fixing first city because we
            % otherwise have 2N permutations to represent the same tour.
            % After this fix you will only have 2 representations of the
            % same tour, either clockwise or counterclockwise.
            % But we should also take care of the offspring created in
            % the generation loop, this is only the population
            % initialisation part.
             tempPerm = randperm(NVAR-1);
             Chrom(row,:) = [1,tempPerm(1,:)+1];
        end
        
        Chrom = consistencyCheck(Chrom);
        
        % I need a deep copy of Chrom, I tested that code below obtains a
        % deep copy:
        previousChrom(:,:) = Chrom(:,:);
        
        % A vector is even more performant that a map-object, given that the keys are
        % just numbers (indexes in the Chrom-array).
        indexToAgeMap = zeros(size(Chrom,1),1);
        
        gen=0;
        % number of individuals of equal fitness needed to stop
        stopN=ceil(STOP_PERCENTAGE*NIND);
        % evaluate initial population
        ObjV = tspfun_path(Chrom,Dist);
        best=zeros(1,MAXGEN);
        
        
        % keep track of number of generations without improvement
        unimprovedGenerations = 0;
        
        %Variables that can store the histogramdata over the different
        %generations.
        %counts_hist_all=cell(MAXGEN,1);
        %centers_hist_all=cell(MAXGEN,1);
                
        % generational loop
        while gen<MAXGEN
            sObjV=sort(ObjV);
          	best(gen+1)=min(ObjV);
        	minimum=best(gen+1);
            mean_fits(gen+1)=mean(ObjV);
            worst(gen+1)=max(ObjV);
            
            %Update the interface without stealing the focus, and only if
            %updating the GUI is not bypassed.
            if (enableGUIValue > 0)
                % Obtain location of best==minimum-tour in the Chrom-array.
                for t=1:size(ObjV,1)
                    if (ObjV(t)==minimum)
                        break;
                    end
                end
                
                [counts_hist,centers_hist]=visualizeTSP(maxCurrentCityData,fh,x,y,Chrom(t,:), minimum, ah1, gen, best, mean_fits, worst, ah2, ObjV, NIND, ah3);
            else
                %In the else case, we should still be carefull that we
                %obtain the [counts_hist,centers_hist]-values, so that they
                %can be outputted. I tested this with some example, and
                %this was 18,5 times faster, with the equivalent
                %inputparameters, but updating the GUI after each
                %generation.
                %In the calculation of bins, maxCurrentCityData was added,
                %otherwise you would have too much historgram centers.
                %bins = max([1 ceil((max(ObjV) - min(ObjV))/(maxCurrentCityData*0.3))]);
                %[counts_hist,centers_hist]=hist(ObjV, bins);
            end
            
            
            if (sObjV(stopN)-sObjV(1) <= (1e-15*maxCurrentCityData))
                  break;
            end
            
            if (gen > 0 && best(gen) == best(gen + 1))
                unimprovedGenerations = unimprovedGenerations + 1;
                if (unimprovedGenerations > MAXGEN / 10)
                    break;
                end
            else
                unimprovedGenerations = 0;
            end
            
            %Keep track of histogramdata, during each generation.
            %Note that this group of statements was put after the possible
            %break above. That way, we save some work.
            %[resultCenters,resultCounts]=addHistogramDataToVariables(gen,centers_hist,counts_hist,centers_hist_all,counts_hist_all);
            %centers_hist_all = resultCenters;
            %counts_hist_all = resultCounts;
            
            %If we have run out of time, abort further calculation
            if (MAX_CALCULATION_TIME > 0) && ((MAX_CALCULATION_TIME+0.0) <= toc)
                break;
            end
            
        	%assign fitness values to entire population
        	FitnV=ranking(ObjV);
        	%select individuals for breeding
        	SelCh=select('sus', Chrom, FitnV, GGAP);
        	%recombine individuals (crossover)
            SelCh = recombin('er',SelCh,PR_CROSS);
            SelCh = mutateTSP('inversion_variant',SelCh,PR_MUT, NVAR - 2);
            SelCh = sa(SelCh, Dist);
            %evaluate offspring, call objective function
        	ObjVSel = tspfun_path(SelCh,Dist);
            %reinsert offspring into population, we pass previousChrom and
            %indexToAgeMap along, because the reins method will change
            % their order.
            [previousChrom, indexToAgeMap, Chrom, ObjV]=reins(Chrom,SelCh,1,(2),ObjV,ObjVSel,previousChrom, indexToAgeMap);
            % Like below it would use fitness based selection:
            % [Chrom ObjV]=reins(Chrom,SelCh,1,(1),ObjV,ObjVSel);
            %application of loopdetection-heuristic
            Chrom = tsp_ImprovePopulation(NIND, NVAR, Chrom,LOCALLOOP,Dist);
            %make chromosomes consistent
            Chrom = consistencyCheck(Chrom);
            
            % Check which chromosomes stayed intact from previous
            % generation.                
            for row=1:size(Chrom,1)
                
                if (chromosomePreserved(previousChrom(row,:),Chrom(row,:)))
                    % increment the age:
                    indexToAgeMap(row,1) = indexToAgeMap(row,1) + 1;
                else
                    % reset the age:
                    indexToAgeMap(row,1) = 0;
                end
            end
            
            % Current Chrom becomes previousChrom for next generation:
            % I tested that the code below makes it a deep copy.
            previousChrom(:,:) = Chrom(:,:);
            
        	%increment generation counter
        	gen=gen+1;
        end
        
        %The check below was not meant to be extra safe, but to support the
        %normal Start-button, which passes an empty String as
        %dataOutputFilePath, and runs without creation of .csv-files.
        %if ~isempty(dataOuputFilePath) 
            %Executed if the path specified isn't empty.
            
            %I chose to put the writeOutputtoCSV-function at the end
            %(=outside of the generation while-loop), because being called
            %for every generation whould be not so efficiënt.
            %writeOutputtoCSV(dataOuputFilePath,gen,best,mean_fits,worst,centers_hist_all,counts_hist_all);
        %end
end

function preserved = chromosomePreserved(prevChrom,currChrom)
    preserved = true;
    idx = 1;
    
    %As soon as a difference is spotted, return that they don't match.
    while(idx <= size(currChrom,2) && preserved)
        if(prevChrom(1,idx) ~= currChrom(1,idx))
            preserved = false;
        end
        idx = idx +1;
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

function consistentChrom = consistencyCheck(Chrom)
    consistentChrom = zeros(size(Chrom,1),size(Chrom,2));
    for row=1:size(Chrom,1)
        % If a chromosome doesn't start with 1, an adequate shift operation
        % is done.
        consistentChrom(row,:) = (circshift(Chrom(row,:)',1-find(Chrom(row,:) == 1)))';
        
        % At this point we still have two rotations for each loop (clockwise &
        % counterclockwise) to deal with that, it suffices to decide whether or
        % not to invert the array (except for the first element == 1). Here I
        % chose to output those representations where the second city has a
        % smaller id than the last city in the path-representation.
        if(consistentChrom(row,2) > consistentChrom(row,end))
            consistentChrom(row,2:end) = fliplr(consistentChrom(row,2:end));
        end        
    end    
end