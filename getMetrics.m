function performanceMetrics = getMetrics(X, y, vStar, gammaStar)
	% Correctness = (n points correctly classified) / (total points in the set)
	correctness = getCorrectClassif(X, y, vStar, gammaStar) / size(X)(1);

	% Sensitivity = (n points of A correctly classified) / (total points in A)
	% Specificity = (n points of B correctly classified) / (total points in B)
	numCorrectlyClassifiedA = 0;
	numCorrectlyClassifiedB = 0;
	numPointsOfA = 0;
	numPointsOfB = 0;
	for i = 1: length(y)
		if y(i) == 1 % if the point is labeled as positive...
			numPointsOfA = numPointsOfA + 1;
			if dot(vStar', X(i, :), 2) >= gammaStar % ... and the model puts it in A+...
				  numCorrectlyClassifiedA = numCorrectlyClassifiedA + 1; % then it's correctly classified.
			endif
		else % if the point is labeled as negative...
			numPointsOfB = numPointsOfB + 1;
			if dot(vStar', X(i, :), 2) <= gammaStar % ... and the model puts it in A-...
				  numCorrectlyClassifiedB = numCorrectlyClassifiedB + 1; % then it's correctly classified.
			endif
		endif
	endfor

	sensitivity = numCorrectlyClassifiedA / numPointsOfA;
	specificity = numCorrectlyClassifiedB / numPointsOfB;

	% Precision = (n of points of A correctly classified) /
	%             (n of points classified as positive)
	numPointsClassifiedAsPositive = 0;
	for i = 1: size(X)(1)
		if vStar * X(i) >= gammaStar % usual equation
			numPointsClassifiedAsPositive = numPointsClassifiedAsPositive + 1;
		endif
	endfor
	precision = numCorrectlyClassifiedA / numPointsClassifiedAsPositive;

	% F-score
	fScore = 2 * ((sensitivity * precision) / (sensitivity + precision));

	% Package it all into one vector
	performanceMetrics = [correctness; sensitivity; specificity; precision; fScore];

endfunction
