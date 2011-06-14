function drawBar(w0,bar)
    
    %Screen('TextSize', w0, 24);
    Screen('DrawLines',w0, bar.rect1, 3);
    Screen('DrawLines',w0, bar.rect2, 3);
    Screen('DrawText',w0,'Undecided',bar.xC-50,bar.y);
    Screen('DrawText',w0,'Left',bar.left,bar.y);
    Screen('DrawText',w0,'Right',bar.right,bar.y);