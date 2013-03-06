function main
    import olwal.Graphics
    import olwal.StackGraphics
    import olwal.ScreenButton
        
    clear all
    
    global xy g s
    
    r = [1000 10 1920 600];
    g = Graphics(r);
    s = StackGraphics(g.screenWidth, g.screenHeight, g.w, 20); 
    s = s.updateCurrentSlice(1);
	s = s.loadImages(5, 105, 'images/176M/176M0');
	
    setup();   
    
    while(1)
        update();
        draw();
    end    
    
    function setup()
        global g
        g.printScreenSettings();
                
    function update()        
        global g s
        
        g = g.update();
        
		% checking for up or down, to change slice
        if (g.checkKeyCode(KbName('DownArrow')))
            s = s.nextSlice();
        elseif (g.checkKeyCode(KbName('UpArrow')))
            s = s.previousSlice();
        end

		% checking whether we clicked a position in the stack list
        slice = s.getClickedSlice(g.mouse, 1);
        g.mouse.clicked(1) = 0;
        
        if (slice > 0)
            s = s.setSlice(slice);
        end
        
	function colors = generateTestColors(xy)
        values = zeros(1, size(xy, 2))
        for i=1:size(values, 2)
            values(i) = i;
        end 
        
%      colors = generateColorArray(values, 1, size(values, 2), [255 0 0], [0 0 255]);
        colors = generateColorArray(values, 1, size(values, 2), [10 10 10], [255 255 255]);        
        
    function draw()
        global xy g s
        Screen('FillRect', g.w, g.black);
        Screen('FillRect', g.w, [255 0 0], [50 50 50 50] );
        
		s.drawTexture();
        s.draw();
%        s.drawGazeFeedback(g.mouse.x, g.mouse.y, 20, 100);

        Screen('DrawLine', g.w, s.colorInactive, 0, 0, g.mouse.x, g.mouse.y);        
        Screen('DrawLine', g.w, s.colorInactive, 0, g.screenWidth, g.mouse.x, g.mouse.y);        
        Screen('DrawLine', g.w, s.colorInactive, g.screenWidth, g.screenHeight, g.mouse.x, g.mouse.y);        
        Screen('DrawLine', g.w, s.colorInactive, g.screenWidth, 0, g.mouse.x, g.mouse.y);        
        
        g.refresh();

        

