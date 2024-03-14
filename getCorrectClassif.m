function numCorrectlyClassified = getCorrectClassif(X, y, vStar, gammaStar)

	numErrors = 0;
	for i = 1: length(y)
		if dot(vStar', X(i,:), 2) >= gammaStar % if the point belongs to A+...
			  if y(i) == - 1 % ... and it is actually negative...
				numErrors = numErrors + 1; % ...then it's an error.
			endif
		elseif dot(vStar', X(i,:), 2) <= gammaStar % if the point belongs to A-...
			if y(i) == + 1 % ... and it is actually positive...
				numErrors = numErrors + 1; % ...then it's an error.
			endif
		endif
	endfor
	numCorrectlyClassified = size(X)(1) - numErrors;

endfunction




