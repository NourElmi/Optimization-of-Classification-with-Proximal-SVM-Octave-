function plotPsvm3D(XFirstLevelTrain, yFirstLevelTrain, vStar, gammaStar, foldIndex)

    clf;
    % Plotting the points of the sets
    hold on;
    [numRows, numCols] = size(XFirstLevelTrain);
    positivePoints = [];
    negativePoints = [];

    for i = 1: numRows
        if yFirstLevelTrain(i) == 1
            positivePoints = [positivePoints; XFirstLevelTrain(i,:)];
        else
            negativePoints = [negativePoints; XFirstLevelTrain(i,:)];
        end
    end

    xxMin = min(XFirstLevelTrain(:,1));
    xxMax = max(XFirstLevelTrain(:,1));
    yyMin = min(XFirstLevelTrain(:,2));
    yyMax = max(XFirstLevelTrain(:,2));
    ZZMin = min(XFirstLevelTrain(:,3));
    ZZMax = max(XFirstLevelTrain(:,3));

    scatter3(positivePoints(:,1), positivePoints(:,2), positivePoints(:,3), 'b', 'o', 'filled');
    scatter3(negativePoints(:,1), negativePoints(:,2), negativePoints(:,3), 'r', 'o', 'filled');

    abscissa = linspace(xxMin, xxMax, 100);
    ordinate = linspace(yyMin, yyMax, 100);
    [X, Y] = meshgrid(abscissa, ordinate);

    % Plotting H
    Z = (-vStar(1)*X - vStar(2)*Y +gammaStar) / vStar(3);
    surf(X, Y, Z, 'FaceAlpha', 0.2, 'EdgeColor', 'k', 'FaceColor', 'k');

    % Plotting H+;
    gammaPlus = gammaStar + 1;
    Z_plus = (-vStar(1)*X - vStar(2)*Y + gammaPlus) / vStar(3);
    surf(X, Y, Z_plus, 'FaceAlpha', 0.2, 'EdgeColor', 'b', 'FaceColor', 'none');

    % Plotting H-;
    gammaMinus = gammaStar - 1;
    Z_minus = (-vStar(1)*X - vStar(2)*Y +gammaMinus) / vStar(3);
    surf(X, Y, Z_minus, 'FaceAlpha', 0.2, 'EdgeColor', 'r', 'FaceColor', 'none');

    legend('Positive Class', 'Negative Class', 'H', 'H+', 'H-', 'Location', 'northwestoutside');
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    view(3); % Set the view angle to 3D

    fig = strcat("FoldsPlot/fold_", num2str(foldIndex));
    print("-djpg", fig);

end

