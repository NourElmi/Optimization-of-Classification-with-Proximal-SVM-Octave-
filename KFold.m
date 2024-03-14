% Cleaning workspace, loading dataset and loading library for k-fold testing
clear;
pkg load statistics;
load dataset32.mat;

% Create a vector of all possibile values of C (Model Selection)
cValues = [10, 100,1000,10000];

% Partitioning dataset using function cvpartition (from statistics package)
firstLevelNumFolds = 10;
secondLevelNumFolds = 5;
firstLevelPartition = cvpartition(y, 'KFold', firstLevelNumFolds);

% Variables used to compute the metrics of the first level fold
trainMetrics = [0; 0; 0; 0];
testMetrics = [0; 0; 0; 0];
metricNames = {" **** correctness : "; " **** sensitivity : "; " **** specificity : "; " **** F-score : "};

for i = 1: firstLevelNumFolds
    disp(strcat("First-level fold n.", int2str(i)));

    % test is a method of firstLevelPartition object, which generates a logical vector
    %Extract the indices of the testing set for the corresponding fold i.
    % Example: For the first fold (i = 1): [0 0 1 1 0 0 0 0 1 0]=>Samples with indices 3, 4, and 9 are part of the testing set.
    firstLevelTestIndices = test(firstLevelPartition, i);

    % Filling the first-level dataset partitions according to the above vector
    XTrainFirstLevel = [];
    yTrainFirstLevel = [];
    XTestFirstLevel = [];
    yTestFirstLevel = [];
    for k = 1: length(firstLevelTestIndices)
        if firstLevelTestIndices(k) == 1
            XTestFirstLevel = [XTestFirstLevel; X(k, :)];
            yTestFirstLevel = [yTestFirstLevel; y(k)];
        else
            XTrainFirstLevel = [XTrainFirstLevel; X(k, :)];
            yTrainFirstLevel = [yTrainFirstLevel; y(k)];
        endif
    endfor

    % Partitioning the first-level training set to create second-level folds
    secondLevelPartition = cvpartition(yTrainFirstLevel, 'KFold', secondLevelNumFolds);
    % Used to compute the metrics for each C
    cAccuracies = [0, 0, 0, 0];

    % Evaluate c value
    for cIndex = 1:length(cValues)
        for j = 1: secondLevelNumFolds
            % Fill second-level fold dataset
            XTrainSecondLevel = [];
            yTrainSecondLevel = [];
            XTestSecondLevel = [];
            yTestSecondLevel = [];
            secondLevelIndices = test(secondLevelPartition, j);
            for k = 1: length(secondLevelIndices)
                if secondLevelIndices(k) == 1
                    XTestSecondLevel = [XTestSecondLevel; XTrainFirstLevel(k, :)];
                    yTestSecondLevel = [yTestSecondLevel; yTrainFirstLevel(k)];
                else
                    XTrainSecondLevel = [XTrainSecondLevel; XTrainFirstLevel(k, :)];
                    yTrainSecondLevel = [yTrainSecondLevel; yTrainFirstLevel(k)];
                endif
            endfor

            % Fitting the model on the second-level dataset
            xStar = ProximalSvm(XTrainSecondLevel, yTrainSecondLevel, cValues(cIndex));

            % Computing the accuracy of this second-level fold with a certain c
            numColumns = size(XTrainSecondLevel)(2);
            vStarSecondLevel = xStar(1:numColumns);
            gammaStarSecondLevel = xStar(numColumns + 1);
            numCorrectlyClassified = getCorrectClassif(XTestSecondLevel,yTestSecondLevel, vStarSecondLevel, gammaStarSecondLevel);
            % Adding up the accuracy values to average them in the end
            cAccuracies(cIndex) = cAccuracies(cIndex) + numCorrectlyClassified;
        endfor
        % Averaging accuracies for a certain C value
        cAccuracies(cIndex) = cAccuracies(cIndex) / secondLevelNumFolds;
    endfor
    % Extracting the one the one with the best testing correctness
    cStar = max(cAccuracies);

    % Training the model with first level training set and C*
    xStarFirstLevel = ProximalSvm(XTrainFirstLevel, yTrainFirstLevel, cStar);

    numCols = size(XTrainFirstLevel)(2);
    vStarFirstLevel = xStarFirstLevel(1:numCols);
    gammaStarFirstLevel = xStarFirstLevel(numCols + 1);

    % Calculate training/testing metrics for the current first-level fold
    trainFoldMetrics = getMetrics(XTrainFirstLevel, yTrainFirstLevel, vStarFirstLevel, gammaStarFirstLevel);
    testFoldMetrics = getMetrics(XTestFirstLevel, yTestFirstLevel, vStarFirstLevel, gammaStarFirstLevel);

    % Summing up metrics
    for k = 1:4
        trainMetrics(k) = trainMetrics(k) + trainFoldMetrics(k);
        testMetrics(k) = testMetrics(k) + testFoldMetrics(k);
    endfor

    % Plotting the fold
	plotHyperplanes(XTrainFirstLevel, yTrainFirstLevel, vStarFirstLevel, gammaStarFirstLevel, i);
	pause(10);

endfor

% Averaging metrics and printing them
for k = 1:4
    trainMetrics(k) = trainMetrics(k) / firstLevelNumFolds;
    disp(strcat(strcat("Average training ", metricNames{k}), num2str(trainMetrics(k))));
    testMetrics(k) = testMetrics(k) / firstLevelNumFolds;
    disp(strcat(strcat("Average testing ", metricNames{k}), num2str(testMetrics(k))));

endfor

