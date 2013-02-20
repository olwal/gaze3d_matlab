classdef ScreenButton
    
    properties
        rect = [ 0 0 0 0 ];
        color = [ 255 255 255 255 ];
    end
    
    methods
    
        function b = ScreenButton(x1, y1, x2, y2)
            b.rect(1) = x1;
            b.rect(2) = y1;
            b.rect(3) = x2;
            b.rect(4) = y2;
        end

        function hit = isHit(s, x, y)
            hit = ((x >= s.rect(1) && x <= s.rect(3)) && (y >= s.rect(2) && y <= s.rect(4)));
        end

        function draw(b, w)
            Screen('FrameRect', w, b.color, b.rect);
        end
    
    end
    
end

