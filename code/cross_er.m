% Calculating an offspring with Edge Recombination
% given 2 parent in the Parents - argument
% Parents is a matrix with 2 rows, each row
% represent the genocode of the parent
%

function Offspring=cross_er(Parents);
	Offspring = zeros(1,size(Parents,1));
    nrParents = size(Parents,1);
    cities = size(Parents,2);
    c = 1;
    % Constuct edgeset
    EdgeSet = zeros(cities, 2 * nrParents);
    for x=1:size(Parents,2)
        city1 = Parents(1,x);
        city2 = Parents(2,x);
        
        count1 = 5 - sum(EdgeSet(city1,:) == zeros(1,4));
        count2 = 5 - sum(EdgeSet(city2,:) == zeros(1,4));
        
        % Condition: begin of the array
        c1 = Parents(1, size(Parents,2));
        c2 = Parents(2, size(Parents,2));
        if x ~= 1
            c1 = Parents(1, x-1);
            c2 = Parents(2, x-1);
        end
        
       if ~ismember(c1,EdgeSet(city1,:))
            EdgeSet(city1, count1) = c1;
            count1 = count1 + 1;
        end
        if ~ismember(c2,EdgeSet(city2,:))
            EdgeSet(city2, count2) = c2;
            count2 = count2 + 1;
        end
        
        % Condition: end of the array
        c1 = Parents(1, 1);
        c2 = Parents(2, 1);
        if x ~= size(Parents,2) 
            c1 = Parents(1, x+1);
            c2 = Parents(2, x+1);    
        end
        
        if ~ismember(c1,EdgeSet(city1,:))
            EdgeSet(city1, count1) = c1;
            count1 = count1 + 1;
        end
        if ~ismember(c2,EdgeSet(city2,:))
            EdgeSet(city2, count2) = c2;
            count2 = count2 + 1;
        end
    end
    
    while c <= size(Parents,2)
        
        % (1) Choose initial city
        [v, initialCity] = max(sum(EdgeSet(:,:) == zeros(1,4),2));
        
        
        % (3) Entries left?
        if v ~= 2 * nrParents && ~ismember(initialCity,Offspring)
            Offspring(1,c) = initialCity;
            c = c + 1;
            
            % (2) Remove occurences
            EdgeSet( EdgeSet == initialCity ) = 0;
            % (4) Go to next city in edge list
            m = 0;
            for i= 1:2*nrParents
                n = EdgeSet(initialCity, i);
                if n ~= 0 && sum(EdgeSet(n,:) == zeros(1,4),2) > m
                    initialCity = n;
                    m = sum(EdgeSet(n,:) == zeros(1,4),2);
                end
            end
        else
            % (5) Randomly select a new city
            while ismember(initialCity, Offspring)
                initialCity = randi([1 cities]);
            end
            
            Offspring(1,c) = initialCity;
            c = c + 1;
        end
        
        EdgeSet( initialCity, : ) = -ones(4,1);
    end

% end function
