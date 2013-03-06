classdef GazeData
    %GazeData this is a class where we are going to put the big matrix of
    %all the samples for each trial
    %   Detailed explanation goes here
    %g is a self-referencing variable
    properties
%        rows;% = 300000; %TimeLimit*60*samplingRate;
        eyeData;%= zeros(rows,5);
        currentSample; 
    end
    
    methods
        
        function g = GazeData(rows) %constructor (intialize data)
            g.eyeData = zeros(rows, 6);
            g.currentSample = 1;
        end
        
        % gazeData = add(trial, image, ...)
        function g = add(g, trial, image, x, y, t, z)
            g.eyeData(g.currentSample,:)=[trial, image, x,y,t,z];
            g.currentSample = g.currentSample + 1;
            
            if (mod(g.currentSample, 1000))
                %print(g.eyeData(g.currentSample));
                fprintf(1, '%d%%...', t)
                save TEMP g
            end
        end
        
%        function saveToFile(g, file)
%             
%        end
    end
    
end
