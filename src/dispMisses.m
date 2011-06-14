function dispMisses()
     
    global trial exp
     
    if trial > 14
        if exp.Missed(trial, 1) > 0
            disp('Error: Missed Stimulus Presentation Flip')
        end

        if exp.Missed(trial, 2) > 0
            disp('Critical Error: Missed Mask Flip')
        end

    end
        
end