% REINS.M        (RE-INSertion of offspring in population replacing parents)
%
% This function reinserts offspring in the population.
%
% Syntax: [Chrom, ObjVCh] = reins(Chrom, SelCh, SUBPOP, InsOpt, ObjVCh, ObjVSel)
%
% Input parameters:
%    Chrom     - Matrix containing the individuals (parents) of the current
%                population. Each row corresponds to one individual.
%    SelCh     - Matrix containing the offspring of the current
%                population. Each row corresponds to one individual.
%    SUBPOP    - (optional) Number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%    InsOpt    - (optional) Vector containing the insertion method parameters
%                ExOpt(1): Select - number indicating kind of insertion
%                          0 - uniform insertion
%                          1 - fitness-based insertion
%                          2 - age-based insertion                
%                          if omitted or NaN, 0 is assumed
%                ExOpt(2): INSR - Rate of offspring to be inserted per
%                          subpopulation (% of subpopulation)
%                          if omitted or NaN, 1.0 (100%) is assumed
%    ObjVCh    - (optional) Column vector containing the objective values
%                of the individuals (parents - Chrom) in the current 
%                population, needed for fitness-based insertion
%                saves recalculation of objective values for population
%    ObjVSel   - (optional) Column vector containing the objective values
%                of the offspring (SelCh) in the current population, needed for
%                partial insertion of offspring,
%                saves recalculation of objective values for population
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population after reinsertion.
%    ObjVCh    - if ObjVCh and ObjVSel are input parameter, than column 
%                vector containing the objective values of the individuals
%                of the current generation after reinsertion.
           
% Author:     Hartmut Pohlheim
% History:    10.03.94     file created
%             19.03.94     parameter checking improved

function [previousChrom, indexToAgeMap, Chrom, ObjVCh] = reins(Chrom, SelCh, SUBPOP, InsOpt, ObjVCh, ObjVSel,previousChrom, indexToAgeMap);

% Below, a constant is defined, used when age-based survival is chosen. The
% parameter below is expressed in amount of generations that an indivual
% maximally can survive.
terminalAgeThreshold = 3;

% Check parameter consistency
   if nargin < 2, error('Not enough input parameter'); end
   if (nargout == 2 & nargin < 6), error('Input parameter missing: ObjVCh and/or ObjVSel'); end

   [NindP, NvarP] = size(Chrom);
   [NindO, NvarO] = size(SelCh);

   if nargin == 2, SUBPOP = 1; end
   if nargin > 2,
      if isempty(SUBPOP), SUBPOP = 1;
      elseif isnan(SUBPOP), SUBPOP = 1;
      elseif length(SUBPOP) ~= 1, error('SUBPOP must be a scalar'); end
   end

   if (NindP/SUBPOP) ~= fix(NindP/SUBPOP), error('Chrom and SUBPOP disagree'); end
   if (NindO/SUBPOP) ~= fix(NindO/SUBPOP), error('SelCh and SUBPOP disagree'); end
   NIND = NindP/SUBPOP;  % Compute number of individuals per subpopulation
   NSEL = NindO/SUBPOP;  % Compute number of offspring per subpopulation

   IsObjVCh = 0; IsObjVSel = 0;
   if nargin > 4, 
      [mO, nO] = size(ObjVCh);
      if nO ~= 1, error('ObjVCh must be a column vector'); end
      if NindP ~= mO, error('Chrom and ObjVCh disagree'); end
      IsObjVCh = 1;
   end
   if nargin > 5, 
      [mO, nO] = size(ObjVSel);
      if nO ~= 1, error('ObjVSel must be a column vector'); end
      if NindO ~= mO, error('SelCh and ObjVSel disagree'); end
      IsObjVSel = 1;
   end
       
   if nargin < 4, INSR = 1.0; Select = 0; end   
   if nargin >= 4,
      if isempty(InsOpt), INSR = 1.0; Select = 0;   
      elseif isnan(InsOpt), INSR = 1.0; Select = 0;   
      else
         INSR = NaN; Select = NaN;
         if (length(InsOpt) > 2), error('Parameter InsOpt too long'); end
         if (length(InsOpt) >= 1), Select = InsOpt(1); end
         if (length(InsOpt) >= 2), INSR = InsOpt(2); end
         if isnan(Select), Select = 0; end
         if isnan(INSR), INSR =1.0; end
      end
   end
   
   if (INSR < 0 | INSR > 1), error('Parameter for insertion rate must be a scalar in [0, 1]'); end
   if (INSR < 1 & IsObjVSel ~= 1), error('For selection of offspring ObjVSel is needed'); end 
   if (Select ~= 0 & Select ~= 1 & Select ~= 2), error('Parameter for selection method must be 0 or 1'); end
   if (Select == 1 & IsObjVCh == 0), error('ObjVCh for fitness-based exchange needed'); end

   if INSR == 0, return; end
   NIns = min(max(floor(INSR*NSEL+.5),1),NIND);
   %ListEliteIndices = zeros((size(Chrom,2)-size(SelCh,2)),1);
   ListEliteIndices = whichIndividualsAreSavedByElitism(ObjVCh, NIND,(size(Chrom,1)-size(SelCh,1)))
   
   % Number of offspring to insert
   % When age-based selection is chosen, this number will depend on the age
   % from which you want to kick them out.
   if Select == 2
       NIns = min(sum(indexToAgeMap(:,1) > terminalAgeThreshold), NIns);
   end

% perform insertion for each subpopulation
   for irun = 1:SUBPOP,
      % Calculate positions in old subpopulation, where offspring are inserted
         if Select == 1,    % fitness-based reinsertion
            [Dummy, ChIx] = sort(-ObjVCh((irun-1)*NIND+1:irun*NIND));
         elseif Select ==2
             [compensatedNIns, ChIx] = randomSelectTooOldInd(indexToAgeMap, NIns, terminalAgeThreshold, ListEliteIndices);
         else               % uniform reinsertion
            [Dummy, ChIx] = sort(rand(NIND,1));
         end
         NIns = compensatedNIns;
         PopIx = ChIx((1:NIns)')+ (irun-1)*NIND;
      % Calculate position of Nins-% best offspring
         if (NIns < NSEL),  % select best offspring
            [Dummy,OffIx] = sort(ObjVSel((irun-1)*NSEL+1:irun*NSEL));
         else              
            OffIx = (1:NIns)';
         end
         SelIx = OffIx((1:NIns)')+(irun-1)*NSEL;
      % Insert offspring in subpopulation -> new subpopulation
         Chrom(PopIx,:) = SelCh(SelIx,:);
         if (IsObjVCh == 1 & IsObjVSel == 1), ObjVCh(PopIx) = ObjVSel(SelIx); end
   end
end

function indexList=whichIndividualsAreSavedByElitism(ObjVCh, NIND,numberOfElite)
    [Dummy, ChIx] = sort(ObjVCh(1:NIND));
    % indexList = zeros(numberOfElite,1)
    
    indexList = ChIx(1:numberOfElite,1)
end

function [compensatedNIns, indexList]=randomSelectTooOldInd(indexToAgeMap, NIns, terminalAgeThreshold, ListEliteIndices)
    % Return list of random indexes that are to old
    idx=1;
    ridx=1;
    indexList = zeros(NIns,1);
    
    randomPermList = randperm(size(indexToAgeMap,1));
    
    while (ridx <= size(indexToAgeMap,1))
        if(indexToAgeMap(randomPermList(1, ridx),1) > terminalAgeThreshold && isempty(find(ListEliteIndices == randomPermList(1, ridx))))
            indexList(idx,1) = randomPermList(1, ridx);
            idx = idx + 1;
        end
        ridx = ridx + 1;
    end
    
     % If some individual has passed the thresholdage but was saved at the
     % same time by elitism, this method will pass a zero to its invokation
     % and there it will, crash, a compensated NIns should bypass that
     % problem.
     compensatedNIns = NIns - sum(indexList(:,1) == zeros(NIns,1))
end
