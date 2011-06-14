% experiment handles the preparation of the stimulus and the mask.  
% It also calls post-presentation functions. 

function experiment()
    global exit_experiment exp_struct
    exit_experiment = false;
    
    % coordinates
    screen_xC = exp_struct.ptb_struct.w0_rect(3)/2;          % x midpoint
    screen_yC = exp_struct.ptb_struct.w0_rect(4)/2;          % y midpoint
    fix_xy = [screen_xC, screen_xC, screen_xC+25, screen_xC-25; ...
        screen_yC+25, screen_yC-25, screen_yC, screen_yC];      
    
    % image directory listings
    left_dir = dir([exp_struct.path_left '*.png']);
    right_dir = dir([exp_struct.path_right '*.png']);
    masks_dir = dir([exp_struct.path_masks '*.png']);
    
    % gui elements
    bar = createBar(exp_struct.ptb_struct.w0_rect);
    
    % training
    % TODO: Refactor training
    if exp_struct.train
        training(left_dir, right_dir, masks_dir, screen_xC, screen_yC, exp_struct.soa_mode, bar);
    end
        
    % main loop
    block = 1;
    for i = 1:exp_struct.total
        % block management
        i_mod_trials = mod(i, exp_struct.trials);
        if i_mod_trials == 0 && i < exp_struct.total
          block = block + 1;
        elseif i_mod_trials == 1
          if i > 1
            break_str = ...
              sprintf('%s\n\n', ...
              ['You have just completed block ' num2str(round(i/exp_struct.trials)) ...
               ' of ' num2str(exp_struct.blocks) '.'], ...
               'You may take a short break.');
          else
            break_str = ...
                sprintf('%s\n\n', ...
                'Press the Space Bar to begin the experiment.');
          end
            
          DrawFormattedText(exp_struct.ptb_struct.w0, break_str, 'center', 'center');
          Screen('Flip',exp_struct.ptb_struct.w0);
          spacePress;
          pause(2);
        end

        % get image names
        ndx = exp_struct.ndx(i);
        im_left_name = left(ndx).name;
        im_right_name = right(ndx).name;
        mask_name = masks(ndx).name;
        
        % file name determines target flag
        if strcmp(im_left_name(13), 'n')
          exp_struct.target_flag(i) = 0;
        else
          exp_struct.target_flag(i) = 1;
        end
        
        % and soa
        soa = str2num(im_left_name(10));

        % read images
        im_left = imread([exp_struct.path_left im_left_name]);
        im_right = imread([exp_struct.path_right im_right_name]);        
        mask = imread([exp_struct.path_mask mask_name]);
        
        % calculate delay
        if exp_struct.rand_delay
            delay = rand*.15;
        else
            delay = .1;
        end

        % create the image texture
        left_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, im_left);
        right_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, im_right); 
        mask_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, mask);
        
        % draw the image texture to the backbuffer
        % TODO: make these relative to the screen size
        l_rect = [228 256 484 512];
        r_rect = [540 256 796 512];
        Screen('DrawTexture', exp_struct.ptb_struct.w0, left_tex, [], l_rect);
        Screen('DrawTexture', exp_struct.ptb_struct.w0, right_tex, [], r_rect);
        max_priority = MaxPriority(exp_struct.ptb_struct.w0);
        Rush('stimNum(mask_tex, fix_xy, exp_struct.train, soa, exp_struct.soa_mode, delay, l_rect, r_rect, i, bar)', max_priority );

        [exp_struct.choice(i) exp_struct.confidence(i)] = 
        %% reaction time
        % reaction time is approximated by taking a timestamp
        % before keypress is called and then subtracting the timestamp
        % returned by keypress from the before timestamp
        % sD is the error term
        %s0 = GetSecs;
        %[exp.choice(i) exp.key_name{i} sN sD] = keyPress(exp_struct.ptb_struct.w0, i, exp, block);
        [exp.choice(i) exp.confidence(i)] = responseBar(exp_struct.ptb_struct.w0, bar, i, exp, fix_xy, screen_xC);
        %exp.response_time(i, :) = [(sN-s0) sD];


        if exit_experiment
            %  ListenChar(0);
            Screen('CloseAll');
            break;
        end

        
        if i == exp_struct.total
        
            end_str = ...
                sprintf('%s\n\n', ...
                'You have completed the experiment.  Thank you for participating.');
            DrawFormattedText(exp_struct.ptb_struct.w0, end_str, 'center', 'center');
            resultsNum(false, [160 80 40 20]);
            Screen('Flip',exp_struct.ptb_struct.w0);
            WaitSecs(3);
        end
        
        %% Missed Flip Messages

        dispMisses();

        % close the textures
        Screen('Close');
        % idisp(i);
    end

    if exp_struct.save_mode
        save(exp_struct.exp_file, 'exp');
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
  
