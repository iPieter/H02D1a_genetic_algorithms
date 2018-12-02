% More elaborate variant of the inversion mutation operator.
% A subtour is selected in the Original choromosome, inverted, and
% re-inserted in the remainder of the old chromosome at a random insertion
% point.
% Representation is an integer specifying which encoding is used
%	1 : adjacency representation
%	2 : path representation
%

function NewChrom = inversion_variant(OldChrom,Representation)

    % NewChrom=OldChrom;
    cities = size(OldChrom,2);
    
    % Conversion if necessary
    if Representation==1 
        NewChrom=adj2path(NewChrom);
    end

    % Select two positions in the tour, by selecting starting pos and
    % length, that way the subtour can spread accross the array boundaries.
    subtourStartPos = randi([1,cities]);
    subtourLength = randi([1,cities-2]); % a subtour of the complete tour doesn't make sense, but -1 is trivial as well.
    
    subtourEndPos = mod((subtourStartPos+subtourLength-1),cities);
    
    %I just initialize these variables to be able to access them from
    %outside the following if-structure.
    remChrom = zeros(1,cities-subtourLength);
    subChrom = zeros(1,subtourLength);
    NewChrom = zeros(1,cities);
    
    % Compute remainder of original choromosome and subchromosome, those
    % will be reunited in the next part. I consider two cases distinct
    % cases here, one with wrapping accros array boundaries and without.
    if (subtourStartPos <= subtourEndPos)
        remChrom = horzcat(OldChrom(1,1:subtourStartPos-1), OldChrom(1,subtourEndPos+1:cities));
        subChrom = OldChrom(1,subtourStartPos:subtourEndPos);
        subChrom = fliplr(subChrom);
    else
        remChrom = OldChrom(1,subtourEndPos + 1:subtourStartPos -1);
        subChrom = horzcat(OldChrom(1,subtourStartPos:cities), OldChrom(1,1:subtourEndPos));
        subChrom = fliplr(subChrom);
    end
    
    %Re-unite remainder and subchromosome to reach a new chromosome.    
    insertionPos = randi([1,size(remChrom,2)]); % We start at 1 instead of 0 because inserting the substring before the remainder or completely after is the same.
    NewChrom = horzcat(remChrom(1,1:insertionPos),subChrom(1,:),remChrom(1,insertionPos+1:end));
    

    % Conversion if necessary
    if Representation==1
        NewChrom=path2adj(NewChrom);
    end
end