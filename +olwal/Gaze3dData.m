% Gaze3dData.writeAllMarkMatrices('data/mat')



% clear e; import olwal.*; e = EdfAsciiParser(); e.parse('test.asc', 'dump.txt');

	% tumorMatrix and markMatrix, contain 26 rows of data in 2D for each z-value ("page")
	% z contains 20 dimensions, but only 8 of those are filled with data for each user's markMatrix
	% the "pages" that are filled w/ data are determined by the order vector
	% so we walk through the order vector, to identify which "page" we should look at 

    
classdef Gaze3dData

	properties
			        
	end

    methods(Static)

	function string = convertRowToString(row)
	
		string = '';
	
		if size(row) == 0
			return;
		end
	
		string = sprintf('%d', row(1));
	
		for i=2:size(row, 2)	
			string = sprintf('%s\t%f', string, row(i));
		end
		
		return;
	
	end
	
	function e = test()
		
		disp(1);
	
    end
    
    function m = writeNoduleMatrices(tumorMatrix)
       
        STACK_COLUMN = 7;
        START_SLICE_COLUMN = 8;
        STACKS = [ 176 183 279 340 362 ];
        
		file = strcat('marks/nodules.txt');
        
        fid = fopen(file, 'w');

        data = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'index', 'stack', 'start_slice', 'end_slice', 'x', 'y', 'z', 'radius', 'stdev');
        
        for index=1:size(tumorMatrix, 3) % from 1 to 20
            
            stack = STACKS(tumorMatrix(1, STACK_COLUMN, index));
            first = tumorMatrix(1, START_SLICE_COLUMN, index); % slice
            last = first + 100; % slice

            for row=1:size(tumorMatrix, 1)

                v = tumorMatrix(row, :, index);
				
				if v(1) ~= 0 || v(2) ~= 0 || v(3) ~= 0
				                    
					s = sprintf('%d\t%d\t%d\t%d\t%f\t%f\t%f\t%f\t%f', index, stack, first, last, v(1), v(2), v(3), v(4), v(5));

                    data = sprintf('%s%s\n', data, s);
				
				end		
            end

            disp(data);
        
        end

        fprintf(fid, data);
        
        fclose(fid);
        
    end

    function m = writeNoduleMatricesSeparate(tumorMatrix)
       
        STACK_COLUMN = 7;
        START_SLICE_COLUMN = 8;
        STACKS = [ 176 183 279 340 362 ];
        
        
        for index=1:size(tumorMatrix, 3) % from 1 to 20

            file = strcat('marks/nodules_', num2str(index), '.txt');            
            fid = fopen(file, 'w');

            data = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'index', 'stack', 'start_slice', 'end_slice', 'x', 'y', 'z', 'radius', 'stdev');

            
            stack = STACKS(tumorMatrix(1, STACK_COLUMN, index));
            first = tumorMatrix(1, START_SLICE_COLUMN, index); % slice
            last = first + 100; % slice

            for row=1:size(tumorMatrix, 1)

                v = tumorMatrix(row, :, index);
				
				if v(1) ~= 0 || v(2) ~= 0 || v(3) ~= 0
				                    
					s = sprintf('%d\t%d\t%d\t%d\t%f\t%f\t%f\t%f\t%f', index, stack, first, last, v(1), v(2), v(3), v(4), v(5));

                    data = sprintf('%s%s\n', data, s);
				
				end		
            end

            disp(data);

            fprintf(fid, data);

            fclose(fid);
            
        end

        
    end    

	function m = plotTest()

        t = 0:pi/20:2*pi;
        [x,y] = meshgrid(t);
        subplot(2,2,1)
        plot(sin(t),cos(t)) 
        axis equal
        subplot(2,2,2)
        z = sin(x)+cos(y);
        plot(t,z)
        axis([0 2*pi -2 2])
        subplot(2,2,3)
        z = sin(x).*cos(y);
        plot(t,z)
        axis([0 2*pi -1 1])
        subplot(2,2,4)
        z = (sin(x).^2)-(cos(y).^2);
        plot(t,z)
        axis([0 2*pi -1 1])
	
	end
	
	
	function saveAllPlots(path)
		
		for i=1:20
		
            sprintf('saving trial %d figure', i)
            
			h = olwal.Gaze3dData.plotMarksAndNodules(path, i);

			m = what(path);
			
			name = sprintf('figure_%d.png', i)
			
			saveas(h, name, 'png');
			
		
		end
	end
	
	% returns latest plot handle, which should be sufficient for saveas
	function plot_handle = plotMarksAndNodules(path, trial_)
	
		m = what(path); % specify path to all mat files for all subjects (contains all matrices)
		m = m.mat; % pick the mat files
        		
		size(m, 1); % get number of mat files
				
		d_ = ceil(size(m, 1) / 4); % assume that we are working with 4 rows
						
		for i_=1:size(m, 1) % for all matrices (two per subject, dril + scan)

			p = char(m(i_));
			s = sprintf('%s/%s', path, p);
		            
			load(s); % load specific mat files
												
			% a_ = mod(i_-1, 4) + 1; % not used
			% b_ = floor((i_-1)/4) + 1; % not used
            
            % selecting the specific subplot (4 rows, d columns, _ith
            % element)
			p = subplot(4, d_, i_); %plot(c_);
			
            % replace the '_' with dash, to avoid subscript
            header_ = edfFile(1:8);
            size_ = size(strtok(header_, '_'), 2); % find first substring up to '_'
            if (size_ < size(edfFile(1:8), 2)) % check that the token was found somewhere before the end
                header_(size_ + 1) = ' '; % replace that character with a ' '
            end   
                                    
			if (sum(markMatrix(:, 1)) == 0 && sum(markMatrix(:, 2)) == 0) % subject didn't mark anything 
				noduleStyle_ = 'wo'; % white rings
				markStyle_ = 'w+'; % white plusses
			else
				noduleStyle_ = 'bo'; % blue rings
				markStyle_ = 'r+'; % red plusses
			end
			
            % plot the tumors as blue rings (o), and marks as red plusses (+)
			plot(tumorMatrix(:, 1, trial_), tumorMatrix(:, 2, trial_), 'bo', markMatrix(:, 1, trial_), markMatrix(:, 2, trial_), 'r+', title(header_));
			
            plot_handle = p;
        end
		        	
    end
    
	function m = writeAllMarkMatrices(path)
	
		m = what(path);
		m = m.mat;		
        
		for i=1:size(m, 1)

			p = char(m(i));
			s = sprintf('%s/%s', path, p);
		            
			load(s);
			
			olwal.Gaze3dData.writeMarkMatrices(order, markMatrix, tumorMatrix, edfFile);
		
        end
        	
    end

    function m = printOrders(path)
	
		m = what(path);
		m = m.mat;		
        
		for i=1:size(m, 1)

			p = char(m(i));
			s = sprintf('%s/%s', path, p);
		            
			load(s);
			
            disp(edfFile(1:8));
            disp(order);
		
        end
        	
    end

    
%     markMatrix(markNumber,1,order(ctr))= x;
%     markMatrix(markNumber,2,order(ctr))= y;
%     markMatrix(markNumber,3,order(ctr))= currentDepthCT;
%     markMatrix(markNumber,4,order(ctr))= part;
%     markMatrix(markNumber,5,order(ctr))= RT1;
%     markMatrix(markNumber,6,order(ctr))= ScanOrDrill;
%     markMatrix(markNumber,7,order(ctr))= order(ctr);
%     markMatrix(markNumber,8,order(ctr))= cputime;
%     markMatrix(markNumber,10,order(ctr))= markNumber;
    
%	function e = writeMarkMatrices(order, markMatrix, prefix)
%	function e = writeMarkMatrices()
%		global order, markMatrix, edfFile;

    function writeMarkMatrices(order, markMatrix, tumorMatrix, edfFile)

        STACK = 7;        
        START_SLICE = 8;
        STACKS = [ 176 183 279 340 362 ];
        
		prefix = strcat('marks/', edfFile(1:8));

        % save file w/ order and images, so we don't have to look at matlab
        % matrices each time
        file = '_summary.txt';
		file = strcat(prefix, file);
        
        fid = fopen(file, 'w');

        fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n', 'trial', 'order(trial)', 'STACKS(order(trial))', 'slice_start', 'slice_end', 'stackIndex');
        
        for trial=1:size(order, 2)-2

            index = order(trial);
            
            stack = STACKS(tumorMatrix(1, STACK, index));
            first = tumorMatrix(1, START_SLICE, index); % slice
            last = tumorMatrix(1, START_SLICE, index) + 100; % slice
            stackIndex = tumorMatrix(1, STACK, index);

            fprintf(fid, '%d\t%d\t%d\t%d\t%d\t%d\n', trial, order(trial), stack, first, last, stackIndex);
        end
        
		fclose(fid);
	
		for trial = 1:size(order, 2)-2 % the last two are not used in CHI study, just first 8
			
			index = order(trial);
			
%			header = sprintf('trial\t%d\torder(trial)\t%d\n', trial, index);
%			header = sprintf('trial\t%d\ntrial\torder(trial)\tx\ty\tz\t?\t?\t?\torder(trial)\t?\t?\tnumber\n', trial);

%			header = sprintf('trial\t%d\ntrial\torder(trial)\tx\ty\tz\tfa?\hitt?\t?\ttime\n', trial);


            stack = STACKS(tumorMatrix(1, STACK, index));
            first = tumorMatrix(1, START_SLICE, index); % slice
            last = tumorMatrix(1, START_SLICE, index) + 100; % slice

			header = sprintf('trial\t%d\timage\t%d\tstart\t%d\tend\t%d\ntrial\torder(trial)\tx\ty\tz\t[fa]\t[hit]\ttime\tpart\tScanOrDrill\tRT1\n', trial, stack, first, last);

			file = sprintf('_%d.txt', trial);
			file = strcat(prefix, file);

			data = '';
			            
			for row=1:size(markMatrix, 1)
			
				v = markMatrix(row, :, index);
				
				if v(1) ~= 0 || v(2) ~= 0 || v(3) ~= 0
				
%					s = olwal.Gaze3dData.convertRowToString(v);
%					s = sprintf('%d\t%d\t%d\t%d\t%d\t%d\t%f\t%d\t%d\t%f\t%d\t%d', trial, index, v(1), v(2), v(3), v(4), v(5), v(6), v(7), v(8), v(9), v(10));


					s = sprintf('%d\t%d\t%d\t%d\t%d\t%d\t%d\t%f\t%d\t%d\t%f', trial, index, v(1), v(2), v(3), -1, 1, v(8), v(4), v(6), v(5));


                    data = sprintf('%s%s\n', data, s);
				
				end		
            end
			
            disp(header);
			%disp(data);
			disp( sprintf('saving to: %s', file') );

			fid = fopen(file, 'w');
			fprintf(fid, '%s%s', header, data);
			fclose(fid);
			
		end

	end
	
	function e = saveNoduleMatrixToFile(tumorMatrix)
		
		% tumorMatrix and markMatrix, contain 26 rows of data in 2D for each z-value ("page")
		% z contains 20 dimensions, but only 8 of those are filled with data for each user's markMatrix
		% the "pages" that are filled w/ data are determined by the order vector
		% so we walk through the order vector, to identify which "page" we should look at 
		for o = 1:size(3)
			
			startP = tumorMatrix(1, 8, o); % (1, 8) == start slice for the stack (we always use 101 slices)
		
			switch tumorMatrix(1, 7, o) % (1, 7) == which of the 5 image stacks we use
				case 1,
					fname = 'images/176M/176M';
					name = '176M';
				case 2,
					fname = 'images/183s/183S';
					name = '183S';
				case 3,
					fname = 'images/279M/279M';
					name = '279M';
				case 4,
					fname = 'images/340T/340T';
					name = '340T';
				case 5, 
					fname = 'images/362M/362M';
					name = '362M';
			end	
	
			verbose = 0;
	
			id = sprintf('nodules_%s_%d_%d.txt', name, ctr, order);
	
			if (verbose)
				s = sprintf('trial\n%d\norder(trial)\n%d', ctr, order(ctr));
				disp(s);
		
				s = sprintf('path\n%s\nstart\n%d\nend\n%d', fname, startP, startP+100);
				disp(s);
		
				s = sprintf('x\ty\tz\tradius\tstddev');
				disp(s);
			end
	
			for i=1:size(tumorMatrix, 1) % for each of the 26 data rows
				
				xyz = tumorMatrix(i, 1:3, order(ctr)); 
				radius = tumorMatrix(i, 4, order(ctr)); 
				stddev = tumorMatrix(i, 5, order(ctr)); 
				% Trafton: it's taking the standard deviation of the grey values from the image over a little box that is a bit bigger than the nodules. it's part of the way that i used an automated program to plop the nodules in random locations without landing in the throat. not terribly relevant for current purposes.
				
				numberOfNodulesForTrial = tumorMatrix(i, 6, order(ctr)); % this is duplicated on each row
				
				if radius > 0 % only print non-zero rows
					s = sprintf('%f\t%f\t%f\t%f\t%f', xyz(1), xyz(2), xyz(3), radius, stddev);
					disp(s);

				end
			
			end
			
			s = sprintf('\n');
			disp(s);
	
%			disp(tumorMatrix(1, 1:3, order(ctr)))
%			disp(markMatrix(1, 1:3, order(ctr)))
			
	
		end
	
	end

	
	function e = dump(order, tumorMatrix, markMatrix)
		
		% tumorMatrix and markMatrix, contain 26 rows of data in 2D for each z-value ("page")
		% z contains 20 dimensions, but only 8 of those are filled with data for each user's markMatrix
		% the "pages" that are filled w/ data are determined by the order vector
		% so we walk through the order vector, to identify which "page" we should look at 
		for ctr = 1:8
		
	
			startP = tumorMatrix(1, 8, order(ctr)); % (1, 8) == start slice for the stack (we always use 101 slices)
		
			switch tumorMatrix(1, 7, order(ctr)) % (1, 7) == which of the 5 image stacks we use
				case 1,
					fname = 'images/176M/176M';
					name = '176M';
				case 2,
					fname = 'images/183s/183S';
					name = '183S';
				case 3,
					fname = 'images/279M/279M';
					name = '279M';
				case 4,
					fname = 'images/340T/340T';
					name = '340T';
				case 5, 
					fname = 'images/362M/362M';
					name = '362M';
			end	
	
			verbose = 0;
	
			id = sprintf('nodules_%s_%d_%d.txt', name, ctr, order);
	
			if (verbose)
				s = sprintf('trial\n%d\norder(trial)\n%d', ctr, order(ctr));
				disp(s);
		
				s = sprintf('path\n%s\nstart\n%d\nend\n%d', fname, startP, startP+100);
				disp(s);
		
				s = sprintf('x\ty\tz\tradius\tstddev');
				disp(s);
			end
	
			for i=1:size(tumorMatrix, 1) % for each of the 26 data rows
				
				xyz = tumorMatrix(i, 1:3, order(ctr)); 
				radius = tumorMatrix(i, 4, order(ctr)); 
				stddev = tumorMatrix(i, 5, order(ctr)); 
				% Trafton: it's taking the standard deviation of the grey values from the image over a little box that is a bit bigger than the nodules. it's part of the way that i used an automated program to plop the nodules in random locations without landing in the throat. not terribly relevant for current purposes.
				
				numberOfNodulesForTrial = tumorMatrix(i, 6, order(ctr)); % this is duplicated on each row
				
				if radius > 0 % only print non-zero rows
					s = sprintf('%f\t%f\t%f\t%f\t%f', xyz(1), xyz(2), xyz(3), radius, stddev);
					disp(s);

				end
			
			end
			
			s = sprintf('\n');
			disp(s);
	
%			disp(tumorMatrix(1, 1:3, order(ctr)))
%			disp(markMatrix(1, 1:3, order(ctr)))
			
	
		end
	
	end
	
	end
		
end