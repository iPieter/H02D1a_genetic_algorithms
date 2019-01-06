function best = sa(x, Dist)
  % SA Implements simulated annealing algorithm for the TSP problem

  output = x;
  best = x;
  f_best = tspfun_path(best, Dist);
  T_max = 10.0;
  T = T_max;
  alpha = 0.9;
  while (T > 1.0)
    % Take a deep copy:
    n = output;
 
    % Depending on temperature, apply mutation with decreasing probability:
    n = mutateTSP('inversion_variant', n, T / T_max, max(floor(0.10 * size(output, 2)), 5));
 
    f_new = tspfun_path(n, Dist);
    f_old = tspfun_path(output, Dist);
    for row = 1:size(n, 1)
      E = exp((f_old(row) - f_new(row)) / T);
      % compare
      if (f_new(row) <= f_old(row))
        output(row, :) = n(row, :);
     
        if f_new(row) <= f_best(row)
          f_best(row) = f_new(row);
          best(row, :) = n(row, :);
        end
     
      elseif E > rand() % accept worse with probability
        output(row, :) = n(row, :);
      end
    end
    T = alpha * T; % lower temperature
  end
end