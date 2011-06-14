   % SoS is the main function for the speed of sight experiment.  
% Call this function to begin the experiment. 

function SoSNumA()
    global exp_struct
    
    [button answer] = getInfo;
    
    ptb_struct = struct(); % psych toolbox related parameters
    
    % w0 is the window pointer
    % w0_rect is a 4-element array containing the x,y coordinates of the
    %   upper left and lower right corners of the screen   n   
    % w,h are the x,y midpoints of the screen
    % exp_struct is a data structure containing relevant experimental values
    % these functions will not work because of a problem with java
    % ListenChar(2);              % prevents key stokes from displaying
    % KbName('UnifyKeyNames');    % Switches internal naming scheme to
    % MacOS-X naming scheme   
    
    % init window
    width = 1024;
    height = 768;
    top = 0;
    left = 1680;
    bottom = top + height;
    right = left + width;

    Screen('Preference','SkipSyncTests', 2);
    maxScreen = max(Screen('Screens'));
    [ptb_struct.w0, ptb_struct.w0_rect] = ...
	    Screen('OpenWindow',maxScreen, [], [left top right bottom]);
    
    %set background color
    Screen('FillRect', ptb_struct.w0, 128);
    Screen('Flip', ptb_struct.w0);

    Screen('TextSize', ptb-struct.w0, 20);
    refresh_rate = Screen('GetFlipInterval', ptb_struct.w0);
    
    blocks = 10;                 % number of blocks of trials                
    trials = 120;                % total number of trials                     
    total = blocks * trials; 
    
    n_x_factors = 2;  % number of factors to use for Gar's analysis
    n_flips = 3;  % number of stimulus flips per trial
    exp_struct = setExpValues(answer, total, n_x_factors, n_flips);
    exp_struct.ptb_struct = ptb_struct;
    exp_struct.official_flag = strcmp(button, 'Yes');
    exp_struct.blocks = blocks;
    exp_struct.trials = trials;
    exp_struct.total = total;
    exp_struct.save_mode = true;
    exp_struct.train = true;
    exp_struct.rand_delay = true;
    exp_struct.soa_mode = '3';
    
    % experiment-specific additions
    exp_struct.trial_struct.key_name = cell(total,1);
    exp_struct.trial_struct.pairs = cell(total, 2);
    % later this value will be set to zero if the image does not
    % contain a target
    exp_struct.trial_struct.target_flag = ones(total, 1);
    
    % Paths
    exp_struct.path_local = [pwd '/' ];
    src_ndx = strfind(exp_struct.path_local, '/src');
    exp_struct.path_parent = exp_struct.path_local(1:src_ndx);
  
    % set file name for storing experimental data
    exp_struct.path_results = ...
	    [exp_struct.path_parent, 'results/'];
    if ~exist(exp_struct.path_results,'dir')
      error(['~exist(): ', exp_struct.path_results]);
    end

    if exp_struct.official_flag
      exp_struct.path_exp = [exp_struct.path_results, 'official/'];
    else
      exp_struct.path_exp = [exp_struct.path_results, 'tmp/'];
    end
    exp_struct.exp_file = ...
	    [exp_struct.path_exp, num2str(round(exp_struct.seed))];

    exp_struct.path_data = [exp_struct.path_parent, 'data/']; 
    if ~exist(exp_struct.path_data,'dir')
      error(['~exist(): ', exp_struct.path_data]);
    end
  
    exp_struct.path_left = [exp_struct.path_data 'left/'];
    exp_struct.path_right = [exp_struct.path_data 'right/'];
    exp_struct.path_masks = [exp_struct.path_data 'masks/'];
    
    % targets
    exp_struct.ndx = Shuffle(1:exp_struct.total);
    
    %% start experiment
    instr(exp_struct.ptb_struct.w0);
    experiment();
    Screen('CloseAll');
end  


function exp_struct = setExpValues(answer, tot, n_x_factors, n_flips)    

    trial_struct = struct();
    trial_struct.target_ndx = zeros(tot, 1);
    trial_struct.lft_ndx = zeros(tot, 1);
    trial_struct.rgt_ndx = zeros(tot, 1);
    trial_struct.choice = zeros(tot, 1);
    trial_struct.confidence = zeros(tot, 1);
    trial_struct.correct = zeros(tot, 1);
    trial_struct.x_factors = zeros(tot, n_x_factors);
    % draw the target patch from the left or right image with equal
    % probability
    % random number generator
    seed = sum(100*clock);
    rand('twister', seed);
    trial_struct.target_flag = Shuffle([ones(tot/2,1); zeros(tot/2,1)]);

    exp_struct = struct( ...
        'vision', answer{1}, ...
        'age', answer{2}, ...
        'gender', answer{3}, ...
        'handedness', answer{4}, ...
        'participation', answer{5}, ...
        'familiarity', answer{6}, ...
        'response_time', zeros(tot, 2), ...
        'VBLTimestamp', zeros(tot, n_flips), ...
        'StimulusOnsetTime', zeros(tot, n_flips), ...
        'FlipTimestamp', zeros(tot, n_flips), ...
        'Missed', zeros(tot, n_flips), ...
        'Beampos', zeros(tot, n_flips), ...
        'trial_struct', trial_struct, ...
        'seed', seed);
    
end

function [button answer] = getInfo()
    button = questdlg('Is this an official experiment?','official','No');
    if strcmp(button, 'Cancel');
        Screen('CloseAll');
        error('Cancelled');
    end

    prompt = {'Do you have normal or corrected-to-normal vision?', ...
	      'What is your age?', 'What is your gender?', ...
	      'Are you right handed or left handed?' ...
	      'How many times have you participated?  Enter 0 if this is your first time.', ...
	      'Are you familiar with this image set?'};
    dlg_title = 'Input';
    num_lines = 1;
    %def = {'20','hsv'};
    answer = inputdlg(prompt,dlg_title,num_lines);
end
