   % SoS is the main function for the speed of sight experiment.  
% Call this function to begin the experiment. 

function SoSNumA()
    
    global w0 w0_rect refresh_rate exp
    
    %  addpath('Users/petavision/neuro_comp/dev/sosB/utilsB');
    
    % w0 is the window pointer
    % w0_rect is a 4-element array containing the x,y coordinates of the
    %   upper left and lower right corners of the screen   n   
    % w,h are the x,y midpoints of the screenfasdfa
    % exp is a data structure containing relevant experimental values
    % trials are the total number of trials in the experiment
    
    % these functions will not work because of a problem with java
    % ListenChar(2);              % prevents key stokes from displaying
    %KbName('UnifyKeyNames');    % Switches internal naming scheme to
    %MacOS-X naming scheme   
    
  %      h = msgbox('Pressing OK will replace saved experimental
  %      values','','warn');  
    
  %button = questdlg('Is this an official experiment?','official','No');
  
%   if strcmp(button, 'Cancel');
%       error('Cancelled') t  
%   end
    
    button = questdlg('Is this an official experiment?','official','No');
    if strcmp(button, 'Cancel');
        error('Cancelled')
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
        %% init window


    [w0, w0_rect] = Screen('OpenWindow',1 );
    
    Screen('TextSize', w0, 20);
    refresh_rate = Screen('GetFlipInterval',w0);
    
    blocks = 10;                 % number of blocks of trials                
    trials = 120;                % total number of trials                     
    
    total = blocks * trials; 
    
    exp = setExpValues(answer, total);    
    
    if strcmp(button,'Yes')
        exp.save_mode = true;
    end 
    
    exp.key_name = cell(total,1);
    exp.pairs = cell(total,2);
    
    
    % set all the target flags to one
    % later this value will be set to zero if the image does not
    % contain a target
    exp.target_flag = ones(total,1);

    %set background color
    Screen('FillRect', w0, 128);
    Screen('Flip', w0);
   
    %% start experiment
 %   experiment(tot_num_seg, num_amoeba_seg, amoeba_mode);       
    instrN(w0);
    experimentNumA(button, trials, blocks, total);
    
end  



function exp = setExpValues(answer, tot)    

    nflips = 3;

    exp = struct( ...
        'label', 'num', ...
        'vision', answer{1}, ...
        'age', answer{2}, ...
        'gender', answer{3}, ...
        'handedness', answer{4}, ...
        'participation', answer{5}, ...
        'familiarity', answer{6}, ...
        'response_time', zeros(tot, 2), ...
        'choice', repmat(10, tot, 1), ...
        'confidence', zeros(tot,1), ...
        'VBLTimestamp', zeros(tot, nflips), ...
        'StimulusOnsetTime', zeros(tot, nflips), ...
        'FlipTimestamp', zeros(tot, nflips), ...
        'Missed', zeros(tot, nflips), ...
        'Beampos', zeros(tot, nflips));
end

