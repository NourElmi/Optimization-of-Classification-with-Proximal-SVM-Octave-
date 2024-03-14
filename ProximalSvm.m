function xStar = ProximalSvm(X, y, C)
	% Setting an empty starting point
	x0 = [];

	% Getting number of rows and cols (assuming dataset already read)
	[numRows, numCols] = size(X);

	% Setting the number of variables (v -> numCols, gamma -> 1, psi -> numRows)
	numVars = numCols + 1 + numRows;
	% Initializing hessian matrix
	H = zeros(numVars, numVars);

	for i = 1: 3
		H(i, i) = 1;
	endfor
	% The remaining rows are related to the k + m points of the dataset
	for i = 4:numVars
		H(i, i) = C;
	endfor

	% Setting empty linear term (there is no linear part in the f(x) of PSVM)
	q = [];

	% Setting matrix A for equality constraints of the form: A*x = b
	% Order of the variables: v, gamma, psi
	A = zeros(numRows, numVars); % Constraint matrix (inequality)

	for i = 1:numRows
		% Coefficients for v
		A(i, 1:numCols) = y(i) * X(i, :);
		% Coefficient for gamma
		A(i, numCols + 1) = - y(i);
		% Coefficient for psi
		A(i, numCols + 1 + i) = 1;
	endfor

	% Setting the b vector for A*x = b
	b = ones(numRows, 1);

	% lb <= x <= ub
	% A_lb <= A_in*x <= A_ub
	% There are no such constraints in our problem. Thus, all of these data structures
	% will be empty.
	lb = [];
	ub = [];
	A_lb = [];
	A_in = [];
	A_ub = [];

	% Fitting the model

	[xStar, zStar] = qp(x0, H, q, A, b, lb, ub, A_lb, A_in, A_ub);
endfunction

