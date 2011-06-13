function [choice keyName secs deltaSecs] = keyPress(w0, trial, exp, block)
    
    global exit_experiment train

    %    FlushEvents();
    KbName('UnifyKeyNames');
    
    % press the space bar to continue after a response
    space = false;
     
    target_label = [2 4];
    
    if train 
        
        num = num2str(target_label(exp.ndxB(2)+1));
    else
%        num = num2str(exp.ndxB(block
        num = num2str(target_label(exp.ndxB(block)+1));
   %      num = num2str(target_label(exp.ndxB(2)+1));
    end
    
    choice = 9;
    count = 1;
    if trial < 1200
        info_text = ...
            sprintf('%s\n\n', ...
            ['trial = ',num2str(trial)], ...
            ['number: ', num], ...
            'Escape: pause or exit', ...
            'Press YES or NO to answer');
    end

    keyName = '';

    while ~strcmp(keyName,'RightShift') && ~strcmp(keyName, 'LeftShift') 
         
         [secs, keyCode, deltaSecs] = KbWait;
         keyName = KbName(keyCode);
         s = size(keyName);
         % disp(['count: ', num2str(size(keyName))]);
         % if someone presses two buttons at the same time an error will be
         % thrown; this prevents the error
         if s(2) == 2
             keyName = '';
         end
         switch keyName
            case 'RightShift'
                choice = 1;

            case 'LeftShift'
                choice = 0;

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
        count = count + 1;
    end

    if space 
        spacePress;
    end
end


    
   
            
    
   