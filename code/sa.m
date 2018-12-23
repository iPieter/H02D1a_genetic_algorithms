function best = sa(x, Dist)
%SA Implements simulated annealing algorithm for the TSP problem

    output = x;
    best = x;
    f_best = tspfun_path(best,Dist);
    T_max = 10.0;
    T = T_max;
    alpha = 0.9;
    while (T > 1.0)
        for i=0:T/T_max*size(output,2)
            n = mutateTSP('swap',output, 1.0);
        end
        f_new = tspfun_path(n,Dist);
        f_old = tspfun_path(output,Dist);
        for row=1:size(n,1)
            E = exp((f_new(row) - f_old(row))/T);
            if (f_new(row) < f_old(row))
               output(row,:) = n(row,:); 
               
               if f_new(row) < f_best(row)
                  f_best(row) = f_new(row);
                  best(row,:) = n(row,:); 
               end
               
            elseif E > rand()
                output(row,:) = n(row,:);
            end
        end
        T = alpha * T;
    end

% Let s = s0
% For k = 0 through kmax (exclusive):
% T ? temperature(k ? kmax)
% Pick a random neighbour, snew ? neighbour(s)
% If P(E(s), E(snew), T) ? random(0, 1):
% s ? snew
% Output: the final state s
end

