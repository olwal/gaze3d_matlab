% Testline for interpreter:
% clear g; import olwal.*; g = Graphics([0 0 400 400]); g.test();

classdef Graphics
    
    properties % (Access = public, GetAccess = public, SetAccess = public, Dependent = false)
        w
        screenWidth;
        screenHeight;
        centerX;
        centerY;
        black;
        gray;
        white;
        
        mouse;
    end
    
    methods
    
        function g = Graphics(rect)

            import olwal.MouseState;
            
			KbName('UnifyKeyNames');
		
            if (nargin == 0)
                rect = [];
            end
            
            screenNumber=max(Screen('Screens'));
            Screen('Preference', 'SkipSyncTests', 1);
            Screen('Preference', 'VisualDebugLevel', 3);

            [g.w, screenRect]=Screen('OpenWindow', screenNumber, 0, rect, 32, 2);
            
            AssertOpenGL;
            g.black = BlackIndex(g.w);
            g.white = WhiteIndex(g.w);
            g.gray = GrayIndex(g.w);

            Screen('BlendFunction', g.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('FillRect', g.w, [0 0 0 0]);
            Screen('TextSize', g.w, 20);

            g.screenWidth=screenRect(1,3);
            g.screenHeight=screenRect(1,4);
            g.centerX=g.screenWidth/2;
            g.centerY=g.screenHeight/2;
            
            g.mouse = MouseState();
            
            ListenChar(2); % suppress key presses to matlab
            
        end
      
        function refresh(g)
            Screen('Flip', g.w); % you only see the change to w when you flip      
        end
        
        function printScreenSettings(g)
            [ g.screenWidth g.screenHeight g.centerX g.centerY ];
        end
    
        function g = update(g)
            if g.checkKeyCode(KbName('Escape'))
                g.quit();
            end
                
            g.mouse = g.mouse.update(g.w);
                        
        end
                    
        function test(g)
            
			px = 0;
			py = 0;
			w = 50;
			x = g.screenWidth/2 - w/2;
			y = g.screenWidth/2 - w/2;

			Screen('FillRect', g.w, g.black);				
			Screen('FillRect', g.w, g.white, [x y x+w y+w]);
			g.refresh();
			
			while(1)
                g.update();
				px = x;
				py = y;
				
				if (g.checkKeyCode(KbName('UpArrow')))
					y = y-1;
				end
				if (g.checkKeyCode(KbName('DownArrow')))
					y = y+1;
				end
				if (g.checkKeyCode(KbName('LeftArrow')))
					x = x-1;
				end
				if (g.checkKeyCode(KbName('RightArrow')))
					x = x+1;
				end
					
				if (px ~= x || py ~= y)					
					Screen('FillRect', g.w, g.black);				
					Screen('FillRect', g.w, g.white, [x y x+w y+w]);				
					g.refresh();				
				end
            end
        end
        
    end 
    
    methods(Static)
            
        function quit()
            Screen('CloseAll');        
            ListenChar(0);
        end
        
        function f = checkKeyCode(code)
            [keyDown, keyTime, keyCode] = KbCheck();            
            f = keyDown && (keyCode(code));
        end
        
%        function f = checkKeyName(name)
  %          f = Graphics.checkKeyCode(KbName(name));
    %    end
        
        function hidTest()
            n = PsychHID('NumDevices')
        end
        
    end
    
end

