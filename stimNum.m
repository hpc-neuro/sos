% stim function flips the stimulus and then the mask

function stimNum(noise_tex, fix_xy, train, soa, soa_mode, delay, l_rect, r_rect, trial, bar)

    global exp w0 refresh_rate count
    
    r = refresh_rate * .5;
    
    if strcmp(soa_mode, '3')
        switch soa 
            case 1
                tt = 4;
            case 2
                tt = 16;
            case 3
                tt = 20;
        end
    elseif strcmp(soa_mode, 'po2')
        
        tt = 2^soa;
        
    elseif strcmp(soa_mode, 'fill')
        switch soa
            case 1
                tt = 1;
            case 2
                tt = 2;
            case 3
                tt = 6;
            case 4
                tt = 12;
        end
    
    
    end    
   % tt = 2^soa;
    
    %disp(num2str(tt));
    d = tt * refresh_rate - r;

    mask_duration = .075;        % duration that the mask is shown --> 80 ms
    
    if train
        trial = 1;
        if count < 3
             d = 2;
        elseif count > 2 && count < 11
            count_ndx = [1.5 1 .66 .33 .11 .09 .07 .05];
            d = count_ndx(count - 2);
        end
    end
    %disp(num2str(delay));

    % VBLTimestamp is a high-precision estimate of when the flip
    %   happened (in system time)
    % StimulusOnsetTime is an estimate of when the stimulus onset
    % FlipTimestamp is a time measurement taken after Flip happens
    % A negative Missed means Flip's deadline was met, positive missed
    % Beampos is the position of the raster beam
    drawBar(w0,bar);
    t0 = GetSecs;
    % Flip the stimulus
    [exp.VBLTimestamp(trial, 1) exp.StimulusOnsetTime(trial, 1) ...
        exp.FlipTimestamp(trial, 1) exp.Missed(trial, 1) ...
        exp.Beampos(trial, 1)] = Screen('Flip', w0, t0 + .3 + delay);

    %     
%     if trial > 1
%         t = toc;
%         disp(num2str(t));
%     end
    
    % if there is intermediate gray (that is, gray between the stimulus and
    % mask) then there is one more flip is required
    drawBar(w0,bar);
    Screen('DrawTexture', w0, noise_tex, [], l_rect);
    Screen('DrawTexture', w0, noise_tex, [], r_rect);

    % Flip the mask
    [exp.VBLTimestamp(trial, 2) exp.StimulusOnsetTime(trial, 2) ...
        exp.FlipTimestamp(trial, 2) exp.Missed(trial, 2) ...
        exp.Beampos(trial, 2)] = Screen('Flip', w0, ...
        exp.VBLTimestamp(trial, 1) + d);
    
    drawBar(w0,bar);
    % draw the fixation lines
    Screen('DrawLines', w0, fix_xy, 2);

    [exp.VBLTimestamp(trial,3) exp.StimulusOnsetTime(trial,3) ...
        exp.FlipTimestamp(trial,3) exp.Missed(trial,3) ...
        exp.Beampos(trial,3)] = Screen('Flip', w0, ...
        exp.VBLTimestamp(trial, 2) + mask_duration);

end