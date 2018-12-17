%
% ObjVal = tspfun(Phen, Dist)
% Implementation of the TSP fitness function
%	Phen contains the phenocode of the matrix coded in path
%	representation
%	Dist is the matrix with precalculated distances between each pair of cities
%	ObjVal is a vector with the fitness values for each candidate tour (=each row of Phen)
%

function ObjVal = tspfun_path(Phen, Dist);
    ObjVal = zeros(size(Phen,1), 1);
    for x=1:size(Phen,1)
        ObjVal(x)=Dist(Phen(x,1),(Phen(x,size(Phen,2))));
        for t=1:size(Phen,2) - 1
            ObjVal(x)=ObjVal(x)+Dist(Phen(x,t),Phen(x,t + 1));
        end
    end
end
	


% End of function

