function bar = createBar(w0_rect)
    
    bar_y = w0_rect(4) - w0_rect(4)/6;
    bar_offset = 250;
    %bar_width = 3;
    %bar = [bar_start+5 bar_stop-5 bar_start+5 bar_start+5 bar_stop-5 bar_stop-5;
    %   bar_y bar_y bar_y-20 bar_y+20 bar_y-20 bar_y+20];

    bar = struct( ...
        'start', w0_rect(1)+bar_offset, ...
        'stop', w0_rect(3)-bar_offset, ...
        'top', bar_y - 40, ...
        'bot', bar_y + 40, ...
        'min', bar_y - 100, ...
        'xC', w0_rect(3)/2);
    
    bar.y = bar.bot-20;
    bar.left = bar.start-18;
    bar.right = bar.stop-28;
    
    bar.rect1 = [bar.start bar.xC-25 bar.start bar.start bar.xC-25 bar.xC-25;
        bar_y bar_y bar_y-20 bar_y+20 bar_y-20 bar_y+20];
    
    bar.rect2 = [bar.xC+25 bar.stop bar.xC+25 bar.xC+25 bar.stop bar.stop;
        bar_y bar_y bar_y-20 bar_y+20 bar_y-20 bar_y+20];