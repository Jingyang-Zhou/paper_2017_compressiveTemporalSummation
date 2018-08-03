% stim_fmriExperiment2

% This is the same experiment as the first one except we are using
% different stimulus images (1 image class and 1 task).

% Experiment plan :

% 1.5 TR, 2.5x2.5x2.5 voxel size

% 1 category of images, 12 images in the category

%% PRE-DEFINED VARIABLES OR VARIABLES TO CHANGE

cal = 'CBI_NYU_projector'; % Need to change the calibration file

frameRate = 60; % number of frames per second

%% DEPENDENCIES

% PSYCHTOOLBOX
% VISTADISP

%% VARIABLES TO CHANGE

totalNumRuns = 6;

for whichRun = 1 : totalNumRuns
    %% PRE-DEFINED VARIABLES
    
    tr                = 1.5;
    
    DUR               = [1 2 4 8 16 32];
    ISI               = [1 2 4 8 16 32];
    ISI_DUR           = DUR(4);
    T_BETWEEN_STIM    = 4.5;
    nTemporalProfile  = length(DUR) + length(ISI);
    [stim, count_t]   = temporalProfiles(DUR, ISI, 1);
    
    % want 48 trials per run + 6 blank trials
    % Experimental variables :
    nImgCat           = 1;
    nTemporalRpt      = 4;
    nBlank            = 6;
    
    nTrial            = nTemporalProfile * nTemporalRpt + nBlank;
    
    %% PRE-DEFINED STIMULUS PARAMETERS
    
    stimulus = struct('images', [], 'cmap', [], 'seq', [], 'seqtiming', [], ...
        'fixSeq', [], 'srcRect', [], 'destRect', []);
    
    d                 = loadDisplayParams(cal);
    stim_size         = min(d.numPixels);
    
    stimulus.srcRect  = [0, 0, stim_size, stim_size];
    stimulus.destRect = [0, 0, stim_size, stim_size];
    
    frameLength       = 1 / frameRate;
    
    % stimulus color
    c_max             = 255;
    stimulus.cmap     = zeros(c_max, 3);
    
    for i = 0:255
        stimulus.cmap(i+1, :) = [i, i, i];
    end
    
    %% CREATE IMAGE PROFILES AND TEMPORAL PROFILE ORDERS
    
    % load image :
    a                 = load('temporalExpImages.mat');
    img               = a.stimImg;
    nImages           = nTemporalProfile * nTemporalRpt;
    stimulus.images   = img(:, :, (whichRun-1)* nImages + 1 : whichRun * nImages);
    gray              = 128 * ones(size(stimulus.images, 1), size(stimulus.images, 2));
    
    stimulus.images(:, :, nImages + 1) = gray;
    
    stimulus.imgOrder = randperm(nImages);
    stimulus.imgOrder = [stimulus.imgOrder, (nImages + 1) * ones(1, nBlank)];
    % create temporal order
    
    tmpOrder       = randperm(nImages + nBlank);
    
    % make sure there are no consecutive blank trials:
    a = find(stimulus.imgOrder(tmpOrder) == 49);
    
    while ismember(1, diff(a))
        tmpOrder       = randperm(nImages + nBlank);
        a = find(stimulus.imgOrder(tmpOrder) == 49);
    end
    
    extTempProfile = repmat([1 : nTemporalProfile], 1, nTemporalRpt);
    extTempProfile = [extTempProfile, 13 * ones(1, nBlank)];
    temporalOrder  = extTempProfile(tmpOrder);
    
    stimulus.imgOrder      = stimulus.imgOrder(tmpOrder);
    stimulus.temporalOrder = temporalOrder;
    
    
    %% CREATE SEQ AND SEQTIMING
    
    % REMEMBER TO ADD AN END TO THE STIMULUS
    
    % initial blank = 8 TRs, and final blank = 4 TRs
    
    initialBlank = 8 * tr * frameRate;
    finalBlank   = 5 * tr * frameRate;
    
    seq          = nImages + 1;
    seqTiming    = 1;
    
    % make seq and seqtiming:
    
    for iTrial = 1 : nTrial
        
        % start of each trial:
        seqTiming = [seqTiming, double(initialBlank + (iTrial - 1) * T_BETWEEN_STIM * frameRate +1)];
        seq       = [seq, stimulus.imgOrder(iTrial)];
        
        % temporal profiles:
        if temporalOrder(iTrial) <= 6
            
            blankStart  = seqTiming(end) + count_t(temporalOrder(iTrial));
            seqTiming   = [seqTiming, blankStart];
            seq         = [seq, nImages + 1];
            
        elseif temporalOrder(iTrial) <= 12
            
            blank1Start = seqTiming(end) + ISI_DUR;
            blank2Start = seqTiming(end) + count_t(temporalOrder(iTrial));
            
            seqTiming   = [seqTiming, blank1Start, blank1Start + ISI(temporalOrder(iTrial) - length(DUR)), blank2Start];
            seq         = [seq, nImages + 1, stimulus.imgOrder(iTrial), nImages + 1];
        end
        
        if iTrial == nTrial
            seqTiming = [seqTiming, initialBlank + nTrial * T_BETWEEN_STIM * frameRate];
            seq       = [seq, nImages + 1];
        end
    end
    
    totalNFrame = seqTiming(end) + finalBlank;
    seqTiming   = [seqTiming, totalNFrame];
    seq         = [seq, nImages + 1];
    
    
    %% PLOT STIMULUS SEQUENCE AND STIMULUS TIMING
    
    figure (1), clf
    subplot(2, 2, 1)
    stem(seqTiming./60, seq), axis tight
    xlabel('time (s)'), ylabel('image')
    title('stimulus seq and seqtiming'), grid on
    
    subplot(2, 2, 2)
    stem(stimulus.imgOrder), axis tight, grid on
    title('Image Order'), xlabel('trial')
    
    subplot(2, 2, 4)
    stem(stimulus.temporalOrder), axis tight, grid on
    title('temporal Order'), xlabel('trial')
    
    
    %% MAKING FIXATION SEQUENCE AND FIXATION TIMING
    
    DIGIT_ONSET  = 30;    % 30 frames, 0.5 second
    DIGIT_OFFSET = 10;    % 10 frames, 0.1667 second
    DIGIT_VOID   = 20;    % "image" number when there is no digit
    
    fixTiming    = 1;
    fixSeq       = DIGIT_VOID; % "image" number where there is no digit
    
    ifix = 1;
    
    while fixTiming(end) <= totalNFrame
        if mod(ifix, 2) == 0
            fixTiming = [fixTiming, fixTiming(end) + DIGIT_ONSET];
        else
            fixTiming = [fixTiming, fixTiming(end) + DIGIT_OFFSET];
        end
        ifix = ifix + 1;
    end
    
    
    fixSeq1 = randi([0, 9], 1, length(fixTiming));
    fixSeq2 = randi([10, 19], 1, length(fixTiming));
    fixSeq  = zeros(1, length(fixTiming));
    
    fixDigit = [];
    
    % generate random digits with 2 alternating colors :
    
    for ifix1 = 1 : length(fixTiming)
        if mod(ifix1, 4) == 2
            fixSeq(ifix1 - 1 : ifix1) = [DIGIT_VOID, fixSeq1(ifix1)];
            fixDigit                  = [fixDigit, fixSeq1(ifix1)];
        elseif mod(ifix1, 4) == 0
            fixSeq(ifix1 - 1 : ifix1) = [DIGIT_VOID, fixSeq2(ifix1)];
            fixDigit                  = [fixDigit, mod(fixSeq2(ifix1), 10)];
        end
    end
    
    % make sure no more than 2 successive identical digits occur:
    
    for ifix2 = 6: 2: length(fixSeq)
        if [mod(fixSeq(ifix2), 10), mod(fixSeq(ifix2 - 2), 10)] == ...
                [mod(fixSeq(ifix2-2), 10), mod(fixSeq(ifix2-4), 10)]
            if fixSeq(ifix2) > 9
                fixSeq(ifix2) = randi_skip([10, 19], 1, fixSeq(ifix2));
                fixDigit(floor(ifix2/2)) = mod(fixSeq(ifix2), 10);
            else
                fixSeq(ifix2) = randi_skip ([0, 9], 1, fixSeq(ifix2));
                fixDigit(floor(ifix2/2)) = fixSeq(ifix2);
            end
        end
    end
    
    % cut down the number of repetitions to about 2 percent
    odd_rep = 0;
    
    for ifix3 = 4 : 2 : length(fixSeq)
        if mod(fixSeq(ifix3), 10) == mod(fixSeq(ifix3 - 2), 10)
            odd_rep =  odd_rep + 1;
            if mod(odd_rep, 4) ~= 0
                if fixSeq(ifix3) < 10
                    fixSeq(ifix3) = randi_skip([0, 9], 1, fixSeq(ifix3));
                else
                    fixSeq(ifix3) = randi_skip([10, 19], 1, fixSeq(ifix3));
                end
                fixDigit(floor(ifix3/2)) = mod(fixSeq(ifix3), 10);
            end
        end
    end
    
    % calculate percentage of repetition in the digit task
    accum_samefix = 0 ;
    
    for ifix4 = 2 : length(fixDigit)
        if fixDigit(ifix4) == fixDigit(ifix4 - 1)
            accum_samefix = accum_samefix + 1;
        end
    end
    
    s = sprintf('digit repetition (%d-back) occurs in %d percent', 1 , round(100 * accum_samefix/length(fixDigit)));
    disp(s)
    
    
    %% PLOT FIXATION SEQUENCE AND FIXATION TIMING
    
    figure (2), clf
    
    stem(fixTiming./60, fixSeq), axis tight
    
    
    %% COMOBINE FIXATION AND STIMULUS SEQUENCE AND TIMING
    
    % for stimulus sequence:
    [stimulus.seqtiming, index_seqtiming, index_fixtiming] = union(seqTiming, fixTiming);
    
    % for fixation sequence:
    [seqtiming1, index_fixtiming1, index_seqtiming1] = union(fixTiming, seqTiming);
    
    % get the order from seqtiming
    [temporary, iseqtiming]   = sort([seqTiming(index_seqtiming), fixTiming(index_fixtiming)]);
    [temporary1, iseqtiming1] = sort([seqTiming(index_seqtiming1), fixTiming(index_fixtiming1)]);
    
    % create new stimulus sequence:
    temp_seq0 = [seq(index_seqtiming), 100 * ones(1, length(index_fixtiming))];
    stimulus.seq = temp_seq0(iseqtiming);
    
    for iseq = 1 : length(stimulus.seq)
        if stimulus.seq(iseq) == 100
            stimulus.seq(iseq) = stimulus.seq(iseq - 1);
        end
    end
    
    % create new fixation sequence:
    temp_fix0 = [100 * ones(1, length(index_seqtiming1)), fixSeq(index_fixtiming1)];
    stimulus.fixSeq = temp_fix0 (iseqtiming1);
    
    for ifix5 = 1:length(stimulus.fixSeq)
        if stimulus.fixSeq(ifix5) == 100;
            stimulus.fixSeq(ifix5) = stimulus.fixSeq (ifix5 - 1);
        end
    end
    
    %% PLOTING FINAL RESULTS
    
    figure (3), clf
    subplot(1, 2, 1)
    stem(stimulus.seqtiming/60, stimulus.seq), axis tight
    title('seqtming vs stimulus seq')
    
    subplot(1, 2, 2)
    stem(stimulus.seqtiming/60, stimulus.fixSeq), axis tight
    title('seqtiming vs fix seq')
    
    %% save files
    
    stimulus.seqtiming     = stimulus.seqtiming.*1/frameRate;
    stimulus.fixtiming_raw = fixTiming;
    stimulus.seqtiming_raw = seqTiming;
    stimulus.seq_raw       = seq;
    stimulus.fixSeq_raw    = fixSeq;
    
    save_txt = sprintf('temporalExp%d.mat', whichRun);
    
    filename = fullfile(vistadispRootPath, 'Applications2', 'Retinotopy', 'standard', 'storedImagesMatrices', save_txt);
    save(filename, 'stimulus')
end

