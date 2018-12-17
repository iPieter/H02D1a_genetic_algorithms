% Calculating an offspring with Edge Recombination
% given 2 parent in the Parents - argument
% Parents is a matrix with 2 rows, each row
% represent the genocode of the parent
%

function Offspring=cross_er(Parents);
    nrParents = size(Parents,1);	
    Offspring = zeros(1,nrParents);
    cities = size(Parents,2);
    c = 1;
    
    % Constuct edgeset
    EdgeSet = zeros(cities, 2 * nrParents);
    for x=1:cities
        city1 = Parents(1,x);
        city2 = Parents(2,x);
        
        count1 = (2 * nrParents + 1) - sum(EdgeSet(city1,:) == zeros(1,4));
        count2 = (2 * nrParents + 1) - sum(EdgeSet(city2,:) == zeros(1,4));
        
        % Condition: begin of the array, PDP: I changed this because I
        % think it would otherwise do double assignments in most of the cases.
        if x ~= 1
            c1 = Parents(1, x-1);
            c2 = Parents(2, x-1);
        else
            c1 = Parents(1, cities);
            c2 = Parents(2, cities);
        end
        
       if ~ismember(c1,EdgeSet(city1,:))
            EdgeSet(city1, count1) = c1;
            count1 = count1 + 1;
        end
        if ~ismember(c2,EdgeSet(city2,:))
            EdgeSet(city2, count2) = c2;
            count2 = count2 + 1;
        end
        
        % Condition: end of the array PDP: I changed this because I
        % think it would otherwise do double assignments in most of the cases.
        if x ~= cities 
            c1 = Parents(1, x+1);
            c2 = Parents(2, x+1); 
        else
            c1 = Parents(1, 1);
            c2 = Parents(2, 1);
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
       
    % Usage of EdgeSet to create a child. The meaning of v is the value of
    % that maximum, currentCity will be the index of v's first occurrence.
    % (1) Choose initial city
    [v, currentCity] = max(sum(EdgeSet(:,:) == zeros(1,4),2));
    nextCity = -1;
    
    while c <= cities
        %At this point, you have a valid current city, either when you came
        %from step (1), (4) or (5). Now, subsequently steps (2) and (3) have
        %to be executed.
        
        % (2) Remove occurrences of the current city in the EdgeSet
        EdgeSet( EdgeSet == currentCity ) = 0;
        % We assign that valid city to the next index in the offspring:
        Offspring(1,c) = currentCity;
        
        %Iteration can be stopped here in case of c==cities, if this
        %loop-breaking is considered dirty, I could also wrap the rest of
        %the iteration in the inverse if.
        if(c == cities)
            break;
        end
        c = c + 1;
        
        % (3) Are there entries left in the EdgeSet for the currentCity?            
        if(sum(EdgeSet(currentCity,:) == zeros(1,4),2) < (2*nrParents))
            % if this check succeeds, it means that there are still
            % connections possible from the current city (=we go to step
            % (4)), so there's no need to guess an un-visited one (=step
            % (5)) at random.
            
            % (4) Go to next city by using the edge list of the current
            % city.
            m = 0;
            for i= 1:2*nrParents
                n = EdgeSet(currentCity, i);
                if n ~= 0 && sum(EdgeSet(n,:) == zeros(1,4),2) > m % in case of multiple possibilities that have an equal m and are therefore equivalent, we should choose randomly instead of picking the one with smallest (i)
                    nextCity = n;
                    m = sum(EdgeSet(n,:) == zeros(1,4),2);
                end
            end
        else
            % (5) Randomly select a new city
            while ismember(nextCity, Offspring) || (nextCity == -1)
                nextCity = randi([1 cities]);
            end
        end
        
        % Possible connections from the current city can be reset, now that
        % we know what the nextCity will be.
        EdgeSet( currentCity, : ) = zeros(1,4);
        
        % The next city, either obtained via step (4) or via step (5) is
        % made the currentCity for next iteration of the while-loop.
        if (nextCity ~= -1)
            currentCity = nextCity;
        else
            % I choose to break when steps (4) and (5) wouldn't have come
            % up with a valid nextCity. If nothing goes wrong, we can never
            % end up here.
            ME = MException('MyComponent:noSuchCity', 'City %d not found, at place %d',nextCity,c);
            throw(ME);
        end
        nextCity = -1;
    end
