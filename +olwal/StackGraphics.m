% clear s; import olwal.*; s = StackGraphics(400, 400, 0, 20); s = s.loadImages(90, 120, 'images/176M/176M0');
classdef StackGraphics
        
     %-----------------------------
    properties
        points;
        line; 
        currentSlice;
        nSlices = 0;
        padding = 40;
        w;
        screenWidth;
        screenHeight;
%        colorInactive = [ 50 50 50 200 ];
        colorInactive = [ 255 255 255 150 ];
        colorActive = [ 255 255 255 255 ];
        width;
		
		offset = 1; 
		textures = [];
        
        button;
        
    end
        
    %-----------------------------
    methods 
   
    % constructor
    function s = StackGraphics(screenWidth, screenHeight, w, width)
        import olwal.*;
        s.currentSlice = 1;
        s.w = w;
        s.screenWidth = screenWidth;
        s.screenHeight = screenHeight;
        s.width = width;
        s.button = ScreenButton(screenWidth - width, 1, screenWidth - 1, screenHeight);
    end
        
	function s = loadImages(s, first, last, prefix, pattern)
        Screen('Close', s.textures); %if there are open textures, close them before loading new ones
        
		s = s.create(last - first + 1);
			  
        if (nargin == 4)
			pattern = '%s%03d.jpg';
        end
        
		fprintf(1, 'Loading %d images...', s.nSlices)
		
		for i=first:last
			path = sprintf(pattern, prefix, i);
			s.textures = [ s.textures Screen('MakeTexture', s.w, imread(path))];
		
			f = int16(100 * (i-first)/s.nSlices);
			if mod(f, 10) == 0
				fprintf(1, '%d%%...', f)
			end
		end
		
		fprintf(1, '[OK]\n');
		        		
    end
		
    % --------
    function drawGazeFeedback(s, x, y, width, height, colors1, colors2, colors3, colors4)
	
        p = s.padding;
        q = s.generateScrollbar(s.nSlices, x - width - p/2, y - height - p/2, width, height);
        q = [ q ; s.generateScrollbar(s.nSlices, x + p/2, y + p/2, width, height) ];
        q = [ q ; s.generateScrollbar(s.nSlices, x - width - p/2, y + p/2, width, height) ];
        q = [ q ; s.generateScrollbar(s.nSlices, x + p/2, y - height - p/2, width, height) ];
        
        for i=1:4
            j = (i-1)*2;
			
			if (nargin == 5)
				Screen('DrawLines', s.w, q(j+1:j+2,:), 1, s.colorInactive);
            else
                switch (i)
                    case 1, c = colors1;
                    case 2, c = colors2;
                    case 3, c = colors3;
                    case 4, c = colors4;
                end
                
                src = transpose(c);
                colors = ones(4, 202);

                for k=1:101
                     l = (k-1)*2 + 1;
                     colors(:, l) = src(:, k);
                     colors(:, l+1) = src(:, k);
                 end
                 
				Screen('DrawLines', s.w, q(j+1:j+2,:), 1, colors);
			end
		
		end
        
        l = s.translatePoints(s.getLine(s.currentSlice, q(1:2,:)), -width, 0);
        l = [ l ; s.translatePoints(s.getLine(s.currentSlice, q(3:4,:)), width, 0) ];
        l = [ l ; s.translatePoints(s.getLine(s.currentSlice, q(5:6,:)), -width, 0) ];
        l = [ l ; s.translatePoints(s.getLine(s.currentSlice, q(7:8,:)), width, 0) ];

        for i=1:4
            j = (i-1)*2;
            Screen('DrawLines', s.w, l(j+1:j+2,:), 1, s.colorActive);
        end
    end
    
    function slices = getSliceInGazeFeedback(s, x, y, width, height, mouse)
        import olwal.ScreenButton;
        
        p = s.padding;
        
        buttons(1) = ScreenButton(x - width - p/2, y - height - p/2, x - p/2, y - p/2);
        buttons(2) = ScreenButton(x + p/2, y + p/2, x + p/2 + width, y + p/2 + height);
        buttons(3) = ScreenButton(x - width - p/2, y + p/2, x - p/2, y + p/2 + height);
        buttons(4) = ScreenButton(x + p/2, y - height - p/2, x + p/2 + width, y - p/2);

        slices = [ 0 0 0 0 ];

        for i=1:4
            if (buttons(i).isHit(mouse.x, mouse.y))
                y = (mouse.y - buttons(i).rect(2)) / (height);
                slices(i) = int16(y * s.nSlices);
            end
        end
    end    

    % --------
    function s = create(s, nSlices)
		s.nSlices = nSlices;
        s.points = s.generateScrollbar(s.nSlices, s.screenWidth - s.width, 1, s.width, s.screenHeight-1);
    end
    
    % --------
    function draw(s)
        s.drawAll(s.colorInactive);
        s.drawPointer(s.width, s.colorActive);
    end

	function drawTexture(s, sourceRect, destinationRect, alpha)
		if (nargin == 1)
			sourceRect = [];
			destinationRect = [];
			alpha = [];
		end
		
		Screen('DrawTexture', s.w, s.textures(s.currentSlice), sourceRect, destinationRect, [], [], alpha);
	end
	
    function drawPointer(s, width, color)
        l = s.translatePoints(s.getLine(s.currentSlice, s.points), -width, 0);
        Screen('DrawLines', s.w, l, 1, color);
    end
    
    function drawAll(s, color)
        Screen('DrawLines', s.w, s.points, 1, color);   
    end
    
    function s = updateCurrentSlice(s, sliceValue)
        sliceValue = s.clamp(sliceValue, 1, s.nSlices);
        
        if (sliceValue ~= s.currentSlice)
%			Screen('Close', s.textures(s.currentSlice));
            s.drawPointer(s.width, [0 0 0]); %clear it
            s.currentSlice = sliceValue;
            s.drawPointer(s.width, s.colorActive);
		end
    end
    
    function s = setSlice(s, i)
        s.currentSlice = s.clamp(i, 1, s.nSlices);
    end
    
    function s = nextSlice(s)
        s = s.setSlice(s.currentSlice + 1);
    end

    function s = previousSlice(s)
        s = s.setSlice(s.currentSlice - 1);
    end
    
    function clickedSlice = getClickedSlice(s, mouse, mouseButton)
        if (mouse.isClicked(mouseButton))
            clickedSlice = getSlice(s, mouse);
        end
        
        clickedSlice = -1;
    end
    
    function slice = getSlice(s, mouse)
        slice = 0;
        if (s.button.isHit(mouse.x, mouse.y))
            y = (mouse.y + 0.5)/ (s.screenHeight);
            slice = int16(y * s.nSlices);
        end
    end    
    
    end
    
    methods(Static)
    % --------
    function xy = generateScrollbar(n, startX, startY, width, height)
        xy = zeros(2, 2 * n); % 2 rows, n * 2 points
        x0 = startX;
        x1 = startX + width;
        step = height / (n-1);
        for i=1:2:n*2
            y = (startY + 0.5*(i-1)*step);
            xy(1, i) = x0;
            xy(2, i) = y;
            xy(1, i+1) = x1;
            xy(2, i+1) = y;            
        end
    end
    
    % --------
    function colors = generateColorArray(values, minValue, maxValue, minColor, maxColor)
        n = size(values, 2);
        colors = zeros(3, n);
        valueRange = maxValue - minValue;
        for i=1:n
            v = (values(i)-minValue)/valueRange;
            colors(1:3, i) = s.interpolate(v, minColor, maxColor);
        end
    end
    
    function interp = interpolate(fraction, minValue, maxValue)
        interp = fraction * (maxValue-minValue) + minValue;
    end
    
    % --------
    function lineI = getLine(i, xy)
        lineI = zeros(2, 2);
        j = i*2-1;
        lineI(1, 1) = xy(1, j);
        lineI(2, 1) = xy(2, j);
        lineI(1, 2) = xy(1, j+1);
        lineI(2, 2) = xy(2, j+1);
    end
    
    % --------
    function v = translatePoints(xy, dx, dy)
        v = zeros(size(xy));
        dx = floor(dx);
        dy = floor(dy);
        for i=1:size(xy, 2)
            v(1, i) = xy(1, i) + dx;
            v(2, i) = xy(2, i) + dy;
        end    
    end
    
    function c = clamp(value, minValue, maxValue)
        c = max(minValue, min(value, maxValue));
    end
        
    
    end % methods
end % classdef

