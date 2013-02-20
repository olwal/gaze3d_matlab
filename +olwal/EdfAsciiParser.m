% clear e; import olwal.*; e = EdfAsciiParser(); e.parse('test.asc', 'dump.txt');

classdef EdfAsciiParser

	properties
				
	end

	methods
		
	function e = EdfAsciiParser()
	
	end
		
	function result = read(this, input, n)
	
		fin = fopen(input);

		if (fin == -1)
			result = [];
			return
		end
				
		line = fgetl(fin);
%		n = str2num(line);
%		line = fgetl(fin);
		
		columns = 10
		
		m = zeros(n, columns);
		
		time = cputime()
		t0 = cputime()
		
		i = 0;
		
		progressPrev = 0;
		
		while ischar(line)
			i = i + 1;
											
			progress = round(100 * i / n);			
						
			if (progress > progressPrev)
				disp(progress);
				progressPrev = progress;
			
				disp( cputime() - time );
				time = cputime();

%				disp(line);
				
			end
						
			row = sscanf(line, '%d\t%f\t%f\t%d\t%f\t%d\t%d\t%d\t%d\t%d')
		
			m(i, :) = row;
								
			% read next line
			line = fgetl(fin);
		end

		fclose(fin);		
	
		result = m;

		time - t0;
				
	end
		
	function result = parse(this, input, output)
	
		fin = fopen(input);
		fout = fopen(output, 'w');

		if (fin == -1 || fout == -1)
			result = [];
			return
		end
		
		line = fgetl(fin);

		index = -1;
		trialId = -1;
		phaseStart = -1;
		phaseEnd = -1;
		quitClick = -1;
		timeRanOut = -1;
		change = -1;
		eyeX = -1;
		eyeY = -1;
		pupilSize = -1;
		slice = -1;
		
		indexPrevious = -1;
		
		data = [];
		
		i = 0;
		
		time = cputime();
		
		while ischar(line)
			i = i + 1;
			
			if (~mod(i, 1000)) 
				disp( cputime() - time );
				time = cputime();
			end
			
			if (i < 100)
				% read next line
				line = fgetl(fin);
				continue
			end
			
			if (isempty(line))
				line = 'EMPTY LINE DO NOT USE';
			end
		
			% TRIALID
			[values, count, error] = sscanf(line, 'MSG\t%d\tTRIALID\t%d');
			if (isempty(error))				
				index = values(1);
				trialId = values(2);			
			end
			
			% phase[X]Start
			[values, count, error] = sscanf(line, 'MSG\t%d\tphase\t%dStart');
			if (isempty(error))						
				index = values(1);
				phaseStart = values(2);			
			end
			
			% phase[X]End
			[values, count, error] = sscanf(line, 'MSG\t%d\tphase\t%dEnd');
			if (isempty(error))						
				index = values(1);
				phaseEnd = values(2);			
			end			
			
			% TimeRanOut
			[values, count, error] = sscanf(line, 'MSG\t%d\tTimeRanOut');
			if (isempty(error))						
				index = values(1);
				timeRanOut = index;			
			end	

			% QuitClick
			[values, count, error] = sscanf(line, 'MSG\t%d\tQuitClick');
			if (isempty(error))						
				index = values(1);
				quitClick = index;			
			end	

			% change [X]
			[values, count, error] = sscanf(line, 'MSG\t%d\tchange\t%d');
			if (isempty(error))				
				index = values(1);
				change = values(2);			
			end							

			% slice
			[values, count, error] = sscanf(line, 'MSG %d %d');
			if (isempty(error) && count == 2)
				index = values(1);
				slice = values(2);
%				disp([ i index slice ]);
			end	
			
			% eyeX eyeY pupilSize
			[values, count, error] = sscanf(line, '%f');
			% values(4) = pupilSize = 0 -> don't use data
			if (isempty(error) && count == 4 && values(4) ~= 0)
				index = values(1);
				eyeX = values(2);
				eyeY = values(3);
				pupilSize = values(4);

%				row = [ i index eyeX eyeY slice pupilSize change quitClick timeRanOut phaseStart phaseEnd trialId ];

				fprintf(fout, '%d\t%d\t%f\t%f\t%d\t%f\t%d\t%d\t%d\t%d\t%d\t%d\n', i, index, eyeX, eyeY, slice, pupilSize, change, quitClick, timeRanOut, phaseStart, phaseEnd, trialId);
				
%				row = [ eyeX eyeY slice ];
				
				change = 0;
				quitClick = 0;
				timeRanOut = 0;
				phaseStart = 0;
				phaseEnd = 0;
				trialId = 0;
				
%				data = [ data ; row ];
			end	
			
%			if (index ~= indexPrevious)
%				disp(line);
%			end
			
			indexPrevious = index;
						
			% read next line
			line = fgetl(fin);
		end

		fclose(fin);		
		fclose(fout);
	
		result = data;
	
		return;
	
	end
		
	end % methods
end % classdef		
		
	