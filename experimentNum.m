% experiment handles the preparation of the stimulus and the mask.  
% It also calls post-presentation functions. 

function experimentNum(button, trials, blocks, total)
    
    global w0 w0_rect exit_experiment exp train
    
    disp(button)
    
    exit_experiment = false;
    save_mode = true;
    train = true;       %                                             %|
    exp.delay = true;
    soa_mode = 'po2';
    
    screen_xC = w0_rect(3)/2;          % x midpoint
    screen_yC = w0_rect(4)/2;          % y midpoint
    
    %fixation coordinates
    fix_xy = [screen_xC, screen_xC, screen_xC+25, screen_xC-25; ...
        screen_yC+25, screen_yC-25, screen_yC, screen_yC];      
    
    % set target files to a list of jpgs in the Target directory
    path_r = '/Users/petavision/neuro_comp/exp/numbers/2afc/data/';
    
    left = dir([path_r 'left/*.png']);
    right = dir([path_r 'right/*.png']);
    masks = dir([path_r 'masks/*.png']);
    
    addpath([path_r 'left']);
    addpath([path_r 'right']);
    addpath([path_r 'masks']);
    
    block_ndx = Shuffle(0:blocks-1);
    ndxT = zeros(trials, blocks);
    
    for i = 1:blocks
        ndxT(:,i) = Shuffle(1:trials);
    end

    exp.ndxB = block_ndx;
    exp.ndxT = ndxT;
    
    %ListenChar(2);
    
    block = 1;
    if train
        training(left, right, masks, screen_xC, screen_yC, soa_mode);
    end
    for i = 1 : total
        
        trial = mod(i,trials)+1;
        
        if mod(i, trials) == 0 && i < 1200
            block = block + 1;
        end
         
        if mod(i,trials) == 1 && i < 1200
          %  save data_file exp -append;
            
            if i > 1
                break_str = ...
                    sprintf('%s\n\n', ...
                    ['You have just completed block ' num2str(round(i/trials)) ' of ' num2str(blocks) '.'], ...
                    'You may take a short break.', ...
                    ['In the next block you will be looking for the number ', num2str(exp.ndxB(block))], ...
                    'Press the Space Bar when you are ready to continue.');
            else
                break_str = ...
                    sprintf('%s\n\n', ...
                    ['In the first block you will be looking for the number ', num2str(exp.ndxB(block))], ...
                    'Press the Space Bar to begin.');
            end
            
            DrawFormattedText(w0, break_str, 'center', 'center');
            Screen('Flip',w0);
            
            spacePress;

        end

        % random number generator
        exp.seed = sum(100*clock);
        rand('twister', exp.seed);      % reseed the random-number generator for each expt.
        state = rand('twister');
        

        if strcmp(button,'Yes')
            data_file = ['../results/official/', num2str(round(exp.seed))];
        else
            data_file = ['../results/tmp/', num2str(round(exp.seed))];
        end

%         im_num = Sample(1:10);
%         im_name = targets(im_num).name;


        ndx = exp.ndxB(block)*120+ndxT(trial,block);
        %disp(num2str(ndx))
        
        im_left_name = left(ndx).name;
        
        if ~isempty(str2num(im_left_name(12)))
            exp.target_flag(i) = 0;
        end
        
       %disp(['trial: ' num2str(i) '  ndx: ' num2str(ndx) '  num: ' im_left_name(5:8)]);
        
        im_left = imread(im_left_name);
        im_right = imread(right(ndx).name);
        
        mask = imread(masks(ndx).name);
        soa = str2num(im_left_name(10));
       %disp(['soa: ' num2str(soa)])

      %  exp.pairs{trial,1} = numbers(tar_ndx(block)).name;
        %exp.target_flag(trial) = str2num(im_name(1));
        
        if exp.delay
            delay = rand*.15;
        else
            delay = .1;
        end

        % create the image texture
        left_tex = Screen('MakeTexture', w0, im_left);
        right_tex = Screen('MakeTexture', w0, im_right); 
        mask_tex = Screen('MakeTexture', w0, mask);
        
        l_rect = [228 256 484 512];
        r_rect = [540 256 796 512];
        
        % draw the image texture to the backbuffer
        Screen('DrawTexture', w0, left_tex, [], l_rect);
        Screen('DrawTexture', w0, right_tex, [], r_rect);
        
        
        % draw image
        max_priority = MaxPriority(w0);
        
        %WaitSecs(.5);
        
        Rush('stimNum(mask_tex, fix_xy, train, soa, soa_mode, delay, l_rect, r_rect, i)', max_priority );



        %% reaction time
        % reaction time is approximated by taking a timestamp
        % before keypress is called and then subtracting the timestamp
        % returned by keypress from the before timestamp
        % sD is the error term
        s0 = GetSecs;
        [exp.choice(i) exp.key_name{i} sN sD] = keyPress(w0, i, exp, block);
        exp.response_time(i, :) = [(sN-s0) sD];


        if exit_experiment
            %  ListenChar(0);
            Screen('CloseAll');
            break;
        end

        if i == 1200
            end_str = ...
                sprintf('%s\n\n', ...
                'You have completed the experiment.  Thank you for participating.');
            DrawFormattedText(w0, end_str, 'center', 'center');
            Screen('Flip',w0);
            WaitSecs(3);
        end
        
        %% Missed Flip Messages

        dispMisses();

        % close the textures
        Screen('Close');
        disp(i);
    end

    if save_mode || strcmp(button, 'Yes')
        save(data_file, 'exp');
    end

   %ListenChar(0);
    Screen('CloseAll');      
   % results();
end

function ret = col2gray(im)
%apply the luminance equation to the image

    ret = .2989*im(:,:,1) ...
        +.5870*im(:,:,2) ...
        +.1140*im(:,:,3);

end
  
