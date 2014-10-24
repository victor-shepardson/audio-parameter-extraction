function P = evaluate_features( F, X, Y )
% given input feature matrix F,
% and training set X, Y,
% evaluate output parameters matrix P

%for each row in F, find index of nearest row in X
%set that row in P to that row of Y

[inputs, feature_dim] = size(F);
[examples, param_dim] = size(Y);

NS = KDTreeSearcher(X);
k=20;
kernelwidth=1;

[idxs, dists] = knnsearch(NS, F, 'K', k);
norm = zeros(inputs, param_dim);
P = zeros(inputs, param_dim);
for i = 1:k %loop over neighbors
    nbrmat = Y(idxs(:, i), :);
    distvec = dists(:, i);
    wmat = repmat(exp(-distvec/kernelwidth), 1, param_dim);
    P = P + nbrmat.*wmat;
    norm = norm + wmat;
end
P = P./norm;

imagesc(dists);


end

