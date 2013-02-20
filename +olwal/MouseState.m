classdef MouseState
    
    properties
        
        x = 0;
        y = 0;
        buttons;
        
        pX;
        pY;
        pButtons;

        clicked = [ 0 0 0 ];
        
    end
    
    methods
            
        function m = update(m, w)
                
            m.pX = m.x;
            m.pY = m.y;
            m.pButtons = m.buttons;
            [m.x, m.y, m.buttons] = GetMouse(w);

            for i=1:3
                if (m.buttons(i) && m.pButtons(i) == 0)
                    m.clicked(i) = 1;
                end
            end
                        
        end
        
        function clicked = isClicked(m, button)
            clicked = 0;
            
            if (m.clicked(button))
                clicked = 1;
            end
            
        end        
    end
end

