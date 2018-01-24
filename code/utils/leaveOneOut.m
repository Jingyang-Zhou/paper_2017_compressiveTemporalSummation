function newMatrix = leaveOneOut(oldMatrix, whichCondition, dim)

% newMatrix = leftOneOut(oldMatrix, whichCondition, dim)

% INPUTS
% oldMatrix      : input matrix
% whichCondition : which condition needs to be left out
% whichDimension : along which dimension this conditions needs to be left
%                  out, 'whichDimension' can only be 1 or 2 for now


% OUTPUT:
% newMatrix      : output matrix

% Example:

exampleOn = 0;
exampleOn = checkExampleOn(exampleOn, mfilename);

if exampleOn
    oldMatrix      = repmat([1:10], 10, 1);
    whichCondition = 3;
    dim            = 2;
end

%%

matrixSize = size(oldMatrix);

if whichCondition > matrixSize(dim)
    error('condition size is greater than the corresponding matrix dimension');
end

%%

switch dim
    case 1
        if whichCondition == 1
            newMatrix = oldMatrix(2:end, :);
        elseif whichCondition ~= matrixSize(dim)
            newMatrix = [oldMatrix(1:whichCondition-1, :); oldMatrix(whichCondition + 1:end, :)];
        else
        newMatrix = oldMatrix(1:end-1, :);
        end
        
    case 2
        if whichCondition == 1
            newMatrix = oldMatrix(:, 2:end);
        elseif whichCondition ~= matrixSize(dim)
            newMatrix = [oldMatrix(:, 1:whichCondition-1), oldMatrix(:, whichCondition + 1:end)];
        else
        newMatrix = oldMatrix(:, 1:end-1);
        end
end



%end






end