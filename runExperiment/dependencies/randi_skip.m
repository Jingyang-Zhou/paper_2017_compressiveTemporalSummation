function randi_output = randi_skip (input_bound, dimension, skip)

% goal is to extend output vector into an output matrix


% INPUTS:
% input_bound  : a vector of integers, either a single entry [a] so that the
%                input vector would be generated as [0:a], or double entry [a, b], so that
%                the input vector would be generated as [a:b].

% dimension    : can be either a single entry or a vector of 2 entries. If
%                dimension is a single entry [a], then the output vector would be of
%                dimension a x a; if dimension is a two-element vector [a, b], then the output
%                would be of dimension [a, b].

% skip         : a subset of input_vect.

% OUTPUTS:
% randi_output : output of the randomly selected integers from the set
%                input_vect/skip of dimension "dimension.

% EXAMPLE:
 %randi_skip([1, 10], [10, 10], [3, 6]);

%%
% check if input_bound is of the right size

if length(input_bound) == 1 | length(input_bound) == 2
    % check if the second entry in input_bound is no less than the first
    % entry
    if length(input_bound) == 2
        if input_bound(2) < input_bound(1)
            
            error('The second entry of input_bound should be no less than the first entry')
            
        end
    end
else
    error('input_bound is of the wrong size, the size should either be [1, 1] or [1, 2]')
end


% generate input_vector from input_bound
if size(input_bound) == [1, 1]
    
    input_vect = 0: input_bound;
else
    input_vect = input_bound(1) : input_bound(2);
end


% Check if skip is a subset of input_vector which is generated from
% input_bound
if sum(ismember(skip, input_vect)) <  length(skip)
    
    error('wrong skipping number, skipping number should be in the input range')
end

%% generate output matrix using index matrix

modified_vect = setdiff(input_vect, skip);
index_matrix  = randi(length(modified_vect), dimension);
randi_output  = modified_vect(index_matrix);

end