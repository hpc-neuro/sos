function [choice confidence] = responseBar(w0, bar, trial, exp, fix_xy, xC)

global ptb_mouseclick_timeout exit_experiment train 

ptb_mouseclick_timeout = .025;

%[w0, w0_rect] = Screen('OpenWindow',1);
%xC = w0_rect(3)/2;



press = '';

 text_l = xC-xC/2;
 text_r = xC+xC/2;

choice = 9;
count = 1;
if trial < 1200
    info_text = ...
        sprintf('%s\n\n', ...
        ['trial = ',num2str(trial)], ...
        'Escape: pause or exit', ...
        'Press YES or NO to answer');
end

%KbQueueFlush();
while ~any(press)

    [x, y, press] = GetMouse(w0);
    %disp(['x: ',num2str(x),'   y: ',num2str(y)]);
    %Screen('FillRect',w0,128);
    if y > bar.min 
        if x < bar.start
            x = bar.start;
        elseif x > bar.stop
            x = bar.stop;
        elseif x > bar.xC-25 && x < bar.xC
            x = xC-25;
        elseif x > bar.xC && x < bar.xC+25
            x = bar.xC+25;
        end
        Screen('FillRect',w0,[200 0 0],[x-5 bar.top x+5 bar.bot]);
        %Screen('DrawLine', w0, [200 0 0], x-5, bar_top, x+5, bar_bot);
    end

    %Screen('DrawLines',w0, bar, 3); 
    drawBar(w0,bar);
    Screen('DrawLines', w0, fix_xy, 2);

    if x < xC
        side = 'left';
        txt_x = text_l;
        choice = 1;
    elseif x > xC
        side = 'right';
        txt_x = text_r;
        choice = 0;
    else
        side = 'neither';
    end

    confidence = abs(xC-x);
    
    %Screen('DrawText',w0,num2str(confidence),txt_x,bar.y);
    [keyIsDown,b, keyCode] = KbCheck;
    keyName = KbName(keyCode);
    s = size(keyName);
    % disp(['count: ', num2str(size(keyName))]);
    % if someone presses two buttons at the same time an error will be
    % thrown; this prevents the error
    if s(2) == 2
        keyName = '';
    end
    
    if keyIsDown
        switch keyName

            case 'RightArrow'
                choice = 7;

            case 'i'
                %   disp('true')
                DrawFormattedText(w0, info_text, 'center', 'center');
                Screen('Flip', w0);
                pause;

            case 't'
                train = false;
                break;

            case 'ESCAPE'
                esc_str = sprintf('%s\n\n', ...
                    ['trial = ',num2str(trial)], ...
                    'Home: save', ...
                    'Escape: save and exit', ...
                    'End: exit without saving', ...
                    'Press YES or NO to answer');

                DrawFormattedText(w0, esc_str, 'center','center');
                Screen('Flip', w0);
                WaitSecs(.2);
                [a, keyCode2] = KbWait;
                keyName2 = KbName(keyCode2);

                switch keyName2
                    case 'End'
                        exit_experiment = true;
                        break;

                    case 'Home'
                        save date_file exp;
                        break;

                    case 'ESCAPE'
                        save date_file exp;
                        exit_experiment = true;
                        break;
                end

            case 'End'
                exit_experiment = true;
                break;

            otherwise
                %disp('Unknown Key');
        end
    end

    Screen('Flip',w0);

end



