function training(left, right, masks, screen_xC, screen_yC, soa_mode, bar)
    
    global exp_struct exp count
    
    count = 1;
    %b = exp.ndxB(2)+1; 
    %disp(['b: ' num2str(b)])
    %block_label = [2 4];

    train_str = ...
        sprintf('%s\n\n', ...
        'In the training block you will be looking for an amoeba', ...
        'Press the Space Bar to begin.');
    
    DrawFormattedText(exp_struct.ptb_struct.w0, train_str, 'center', 'center');
    Screen('Flip',exp_struct.ptb_struct.w0);
    WaitSecs(.2);
    spacePress;
    
    train_warn = sprintf('%s\n', 'TRAINING: Press t to exit');
    
    fix_xy = [screen_xC, screen_xC, screen_xC+25, screen_xC-25; ...
        screen_yC+25, screen_yC-25, screen_yC, screen_yC];

    while train
        disp(num2str(count));
        
        ndx = Sample(1:300);
        
      %  ndx = b*120 + t - 1;
        left_name = left(ndx).name;
        right_name = right(ndx).name;
        
        %disp(['ndx: ' num2str(ndx) '  name: ' left_name(5:8)]);
        
        mask_name = masks(ndx).name;
        
        image_left = imread(left_name);
        image_right = imread(right_name);
        
        mask = imread(mask_name);
        
        if strcmp(left_name(13),'a')
            flag = 1;
        else 
            flag = 0;
        end
        
        soa = str2num(left_name(10));
        
        if exp.delay
            delay = rand*.15;
        else
            delay = .1;
        end
        
        l_rect = [228 256 484 512]; 
        r_rect = [540 256 796 512];
        
        % create the image texture
        left_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, image_left);
        right_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, image_right);
        mask_tex = Screen('MakeTexture', exp_struct.ptb_struct.w0, mask);
        
        
        % draw the image texture to the backbuffer
        Screen('DrawTexture', exp_struct.ptb_struct.w0, left_tex, [], l_rect);
        Screen('DrawTexture', exp_struct.ptb_struct.w0, right_tex, [], r_rect);
        % draw image
        max_priority = MaxPriority(exp_struct.ptb_struct.w0);
        
        DrawFormattedText(exp_struct.ptb_struct.w0, train_warn, 412, 100);
       
        Rush('stimNum(mask_tex, fix_xy, train, soa, soa_mode, delay, l_rect, r_rect, 1, bar)', max_priority );
        
        DrawFormattedText(exp_struct.ptb_struct.w0, train_warn, 412, 100);
       
        %% reaction time
        % reaction time is approximated by taking a timestamp
        % before keypress is called and then subtracting the timestamp
        % returned by keypress from the before timestamp
        % sD is the error term
%        [choice key_name sN sD] = keyPress(exp_struct.ptb_struct.w0, 1, exp, b);
        [choice confidence] = responseBar(exp_struct.ptb_struct.w0, bar, 1, exp, fix_xy, screen_xC);

        DrawFormattedText(exp_struct.ptb_struct.w0, train_warn, 412, 100);
       
        drawBar(exp_struct.ptb_struct.w0,bar);
        if choice == flag
            tally_str = 'Correct.';
        else
            tally_str = 'Incorrect.';
        end
        
        DrawFormattedText(exp_struct.ptb_struct.w0, tally_str, 'center','center');
        Screen('Flip', exp_struct.ptb_struct.w0);
        pause(1);
        
        count = count + 1;
    end
end