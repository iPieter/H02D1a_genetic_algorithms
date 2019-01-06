% Calculating an offspring with SCX
% given 2 parent in the Parents - argument
% Parents is a matrix with 2 rows, each row
% represent the genocode of the parent
%

function Offspring = cross_scx(Parents, Dist);
  nrParents = size(Parents, 1);
  Offspring = zeros(1, nrParents);
  cities = size(Parents, 2);
  c = 1;

  % Assume shifting is enabled and first city is '1'
  currentCity = 1;

  while c <= cities
    % We assign that valid city to the next index in the offspring:
    Offspring(1, c) = currentCity;
 
    % Iteration can be stopped here in case of c==cities, if this
    % loop-breaking is considered dirty, I could also wrap the rest of
    % the iteration in the inverse if.
    if (c == cities)
      break;
    end
    c = c + 1;
 
    city1 = Parents(1, c);
    city2 = Parents(2, c);
 
    if (~ ismember(city1, Offspring(1, :)) && ~ ismember(city2, Offspring(1, :)))
      if Dist(currentCity, city1) < Dist(currentCity, city2)
        nextCity = city1;
      else
        nextCity = city2;
      end
   
    elseif (~ ismember(city1, Offspring(1, :)))
      nextCity = city1;
   
    elseif (~ ismember(city2, Offspring(1, :)))
      nextCity = city2;
   
    else
      while ismember(nextCity, Offspring) || (nextCity == - 1)
        nextCity = randi([1 cities]);
      end
    end
 
    if (nextCity ~= - 1)
      currentCity = nextCity;
    else
      % I choose to break when steps (4) and (5) wouldn't have come
      % up with a valid nextCity. If nothing goes wrong, we can never
      % end up here.
       ME = MException('MyComponent:noSuchCity', 'City %d not found, at place %d', nextCity, c);
      throw(ME);
    end
    nextCity = - 1;
  end
