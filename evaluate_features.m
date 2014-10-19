function P = evaluate_features( F, X, Y )
% given input feature matrix F,
% and training set X, Y,
% evaluate output parameters matrix P

%for each row in F, find index of nearest row in X
%set that row in P to that row of Y
idxs = knnsearch(X, F);
P = Y(idxs, :);

end

