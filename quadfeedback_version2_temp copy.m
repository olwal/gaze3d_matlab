function quadfeedback_version2


%12.12.12 after s01 on feedback v2, found 2 nodules outisde of lung on
%trials 8 and 13. this have been fixed in new version. marks for s01 will
%not reflect this correction though. td

% quit while running: ctrl-c, ctrl-c, s, c, a [enter]

%this is a preliminary version of Alex's proposed 2x2 experiment where we
%push people into drilling or scanning and see whether feedback helps in
%either condition.
%8/10/12 td

%v4 changes size from 624 to 850x850
%NEED TO MAKE TWO VERSIONS OF THIS EXPERIMENT: SCANNER AND DRILLER
%three subjects were run on 2b and 2a version. no real benefit. they
%don't seem to be using the feedback because they tend to use the whole
%tiem regardless. new plan is to make this more like sequential CAD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
import olwal.*;
import gaze3d.*;
%clear everything before you begin
clear all;
%AO
cd('/Users/wolfelab/Desktop/CurrentExperiments/Trafton/feedback_eyetrack1')
%cd('/Users/traftondrew/Desktop/matlab/feedback_eyetrack1');
%cd('Z:\codebase\matlab\eyetracker')
%cd('/Users/olwal/Documents/MATLAB/eyetracker')
%set the state of the random number generator to some random value (based on the clock)
rand('state',sum(100*clock));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup
global winMain screenX screenY;
global bcolor
global centX centY sinit
global quad_Durations quad_levels colorsA colorsB colorsC colorsD levelDurations
global screenPosition
global usePopupFeedback
global fontSize textColor textColor2
global ScanOrDrill
global sg drillNumber direction currentDepthCT startP endP ERPon
global gazeData
rows = 300000;
gazeData = GazeData(rows); 

Screen('CloseAll')

doFullscreen = 1;
if (doFullscreen)
    windowSize = [];
else
    windowSize = [0 0 1280/2 960/2]; %used if not in fullscreen mode
end

useEyetracker = '1';
useKeypad = 0;
dummymode=0;
showPractice=0;

% xIndex = 14;
% yIndex = 16;
screenPosition = [215 55 1065 905];
textColor = [ 200 200 200 ];
textColor2 = [ 255 0 0 ];

eye_used = 0;

fontSize = 20; %30 for real test

if useKeypad
    progressKey = KbName('Enter');
else
    progressKey = KbName('Space');
end

dataDirectory = 'feedback2Data';

%Make some beeps
[beep,samplingRate]=MakeBeep(850,.1);
[errbeep,samplingRate] = MakeBeep(850,.11);


%get input
prompt={'Enter Subject Number: only use numbers','Enter initials:', 'Date', 'are you recording at Crosstown?', 'ERP on? 1 if yes', 'scanner(1) or driller(2)?','first or second block?', 'popup feedback'};
def={'99','xxx',date, '0', useEyetracker, '2','1', '0'};
title='Input variables';
lineNo=1;

%%%%%%%%%%
userinput=inputdlg(prompt,title,lineNo,def,'on');

%%%%%%%%%
%Convert User Input
sNumber=(userinput{1,1});
sinit=(userinput{2,1});

fileName = num2str(sinit);
marksOut=zeros(1,10);
tumorColor=220;
crosstown=str2num(userinput{4,1});
greyFlavor = tumorColor;
ERPon = str2num(userinput{5,1});
ScanOrDrill = str2num(userinput{6,1});
BlockNumber = str2num(userinput{7,1});
usePopupFeedback= str2num(userinput{8,1});
sNumber = str2num(sNumber);
order = [1, shuffle(2:13)];

numTrials=length(order);
jnk=zeros(1,12);
jnk(1:6)=1;
jnk=shuffle(jnk);
feedback=[1, jnk]; %makes sure each O gets 50% feedback with feedback on the 1 triall as well. 


exp_quad_Durations=zeros(101,4,numTrials);
exp_level_Durations=zeros(101,numTrials);
part1_exp_quad_Durations=zeros(101,4,numTrials);
part1_exp_level_Durations=zeros(101,numTrials);



StimScale=.65;
%size limit and break down.
tumorOpacity = 42;% increased from 40 for feedback because it was really hard.
%40;%25;%55; TD pilot at 55, Corbin at 25

% the following are DEF setup commands
KbName('UnifyKeyNames');
if useKeypad == 1
    keys = [KbName('8') KbName('2') KbName('Enter')];
else
    keys = [KbName('UpArrow') KbName('DownArrow') KbName('Space')];
end

commandwindow
%HideCursor;

% load in image locations
%  load tumorM.mat;


try % The try command lets us recover from errors
    
    %Bname = strcat('loadBehavior',nameO);
    
    dataPath = sprintf('%s/%s', dataDirectory, fileName)
    
    %     if ScanOrDrill==1
    %         Oname = strcat( dataPath, '_scan.mat');
    %         EyefileName =strcat(fileName, '_scan.EDF');
    %         Bname =strcat( dataPath, '_trial_scan.txt');
    %         Cname =strcat( dataPath, '_scan.txt');
    %     else
    %         Oname = strcat( dataPath, '_Dril.mat');
    %         EyefileName =strcat(fileName, '_Dril.EDF');
    %         Bname =strcat( dataPath, '_trial_dril.txt');
    %         Cname =strcat( dataPath, '_Dril.txt');
    %     end
    
    Oname = strcat( dataPath, '_FB2.mat');
    EyefileName =strcat(fileName, '_FB2.EDF');
    Bname =strcat( dataPath, '_trial__FB2.txt');
    Cname =strcat( dataPath, '__FB2.txt');
    
    if exist(Bname,'file')
        if strcmp(fileName,'xxx')
        else
            Screen('CloseAll');
            msgbox('File name already exists, please specify another', 'modal')
            ListenChar(0);
            return;
        end
    end
    pwd
    % open files
    %fid=fopen(['EyeStackSearch_',nameO,'.txt'],'a');
    Bname
    fid=fopen(Bname,'a');
    fprintf(fid,'header information\n');
    fprintf(fid,'sNumberinitials,  stimscale, feedback\n');
    fprintf(fid,' \n');
    %trial information
    
    fid2=fopen(Cname,'a');
    fprintf(fid2,'mark info\n');
    
    
    
    %%%%%EYETRACKING SETUP
    if ERPon==1
        if ~EyelinkInit(dummymode)
            fprintf('Eyelink Init aborted.\n');
            %cleanup;  % cleanup function
            return;
        end
        
        % STEP 2
        % name the edf
        prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
        dlg_title = 'Create EDF file';
        num_lines= 1;
        def     = {EyefileName};
        answer  = inputdlg(prompt,dlg_title,num_lines,def);
        %edfFile= 'ZWOMPF.EDF'
        edfFile = answer{1};
        
        
    end
    
    
    % STEP 3
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    %screenNumber=min(Screen('Screens'));
    screenNumber=min(Screen('Screens')); % wieviele bildschirme angeschlossen sind, max ist der bildschirm der weiter weg ist
    %[window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2); %Screen('OpenWindow?'), window = handle im wm, hier kann alles präsentiert werden
    %        [winMain, screenRect]=Screen('OpenWindow', screenNumber, 0,[0 0 1280 960],32,2);
    [winMain, screenRect]=Screen('OpenWindow', screenNumber, 0, windowSize, 32, 2);
    
    resolution=Screen('Resolution', winMain);
    if doFullscreen ==1 && (resolution.width~=1280 || resolution.height~=960 || resolution.hz~=85)
        a = 'Wrong resolution'
        Screen('CloseAll');
        %msgbox('Wrong resolution', 'modal')
        ListenChar(0);
        return;
    end
    %Screen(winmain,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    
    % STEP 4
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations.
    if ERPon==1
        %el=EyelinkInitDefaults(winMain);
        el=EyelinkInitGreyDefaults(winMain);
        %         el.backgroundcolour = 0;%128;
        %         el.foregroundcolour = 128;%0;
        %         el.calibrationtargetcolour= [255 0 0];
        
        [v vs]=Eyelink('GettrackerVersion');
        fprintf('Running experiment on a ''%s'' tracker.\n', vs );  % \n' neue zeile
        
        % open file to record data to
        i = Eyelink('Openfile', edfFile);
        if i~=0
            printf('Cannot create EDF file ''%s'' ', edffilename);
            Eyelink( 'Shutdown');
            return;
        end
        
        Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
        [width, height]=Screen('WindowSize', screenNumber); %fragt window size ab
        
        
        % STEP 5
        % SET UP TRACKER CONFIGURATION
        % Setting the proper recording resolution, proper calibration type,
        % as well as the data file content;
        Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
        Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
        % set calibration type.
        Eyelink('command', 'calibration_type = HV9');
        % set parser (conservative saccade thresholds) hier kriegt DOS info zu
        % filter für online abfrage, gaze contingent
        Eyelink('command', 'saccade_velocity_threshold = 35');
        Eyelink('command', 'saccade_acceleration_threshold = 9500');
        % set EDF file contents
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');
        % allow to use the big button on the eyelink gamepad to accept the
        % calibration/drift correction target
        Eyelink('command', 'button_function 5 "accept_target_fixation"');
        
        
        % make sure we're still connected.
        if Eyelink('IsConnected')~=1
            return;
        end;
        
        
        % STEP 6
        % Calibrate the eye tracker
        % setup the proper calibration foreground and background colors
        
        Screen('HideCursorHelper', winMain);
        EyelinkDoTrackerSetup(el);
        % Hide the mouse cursor;
        %el;
        %%%%%%
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        %0= left
        %1 = right
        if eye_used == el.BINOCULAR; % if both eyes are tracked
            eye_used = el.LEFT_EYE; % use left eye
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Some parameters
    
    bcolor=[0 0 0];
    %Make some beeps
    [beep,samplingRate]=MakeBeep(650,.1);
    [errbeep,samplingRate] = MakeBeep(850,.11);
    
    
    %open a window, called winMain, and set screenRect equal to it's resolution
    AssertOpenGL;
    ListenChar(2);   % stops echoing of getchar
    
    
    % the following are DEF setup commands
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'VisualDebugLevel', 3);
    
    
    Screen('BlendFunction', winMain, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', winMain, [0 0 0 0]);
    Screen('TextSize',winMain, fontSize);
    Screen('Flip', winMain); % you only see the change to winMain when you flip
    screenX=screenRect(1,3);
    screenY=screenRect(1,4);
    centX=screenX/2;
    centY=screenY/2;
    StimScale=.65;
    stimSize =850;%700; %512
    fieldsz=850; %512;
    
    disp('this path must have subdirectory with +olwal package');
    pwd
    sg = StackGraphics(screenX, screenY, winMain, 50);
    
    % load in image locations
    
    load exp2TumorLocs  tumorMatrix
    %load  tempTumorLocs tumorMatrix
    NoiseOpacity = 1;
    
    tumorMx = (tumorMatrix);
    %tumorMx = round(tumorMatrix);
    b = [tumorMx(:,:,1); tumorMx(:,:,2); tumorMx(:,:,3); tumorMx(:,:,4); tumorMx(:,:,5); tumorMx(:,:,6); tumorMx(:,:,7); tumorMx(:,:,8); tumorMx(:,:,9); tumorMx(:,:,10);...
        tumorMx(:,:,11);tumorMx(:,:,12);tumorMx(:,:,13);]; %dropped 2 here for feedback
    
    [c,d]=size(b);
    tumorPlaces = zeros(c,d);
    ccc = 1;
    tnumber = 1;
    for i=1:c
        if b(i,1)~=0
            tumorPlaces(ccc,:) = b(i,:);
            if ccc>1
                if tumorPlaces(ccc,6)==tumorPlaces(ccc-1,6)
                else
                    %ljlk='boo';
                    tnumber = tnumber+1;
                end
            end
            tumorPlaces(ccc,5) = tnumber;
            ccc= ccc+1;
        end
    end
    %tumorMx(:,4,:) = 0;
    tumorMx(:,5,:) = 0;
    timePerLevel = zeros(201,numTrials);
    markMatrix = zeros(26,7,numTrials);
    nullfield=[0 centY-(screenY*StimScale*.25) 130 centY+(screenY*StimScale*.25)];
    nulltextx=16;
    nullcol=[120 120 120];
    
    % THIS IS THE RATING SCALE BOX
    ratingfield=zeros(6,4);
    ratingcol=zeros(6,3);
    for k=1:6
        ratingfield(k,:)=[((k-4)*50)+centX 0 ((k-3)*50)+centX 100];
        ratingcol(k,:)=[35*k 35*k 40*k];
    end
    trialOrder = zeros(20,1);
    count1 = 0;
    stimsz= 15;%round(fieldsz/35);
    quitters=zeros(1,numTrials);
    save('CurrentOrder.mat', 'order');
    
    if showPractice
        
        %%PRAC TRIAL
        %cd images/176M
        fname = 'images/176M/176M';
        filename = strcat(fname, '0',  '400', '.jpg');
        fullImage = strcat('fullImage_', '400', '.jpg');
        image = imread(filename);
        [a b]=size(image);
        Screen('TextSize',winMain,fontSize);
        DrawFormattedText(winMain, 'This is a practice trial. Try to find the 5 lung nodules inserted into this chest slice.','center', 0, textColor,100);
        invFtexture = Screen('MakeTexture', winMain,image);
        Screen('DrawTexture',winMain, invFtexture,[0 0 512 512],[centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)],[],[],NoiseOpacity);
        
        pointSize = 10;
        
        nodulePositions = [ 450 840 750 900 850; 400 280 600 500 740 ];
        %{
		rescaleToActualResolution = [ screenX/1280 screenY/960 ];
		
		for i=0:4
			j = i*2 + 1;
			nodulePositions(j) = nodulePositions(j) * rescaleToActualResolution(1);
			nodulePositions(j+1) = nodulePositions(j+1) * rescaleToActualResolution(2);
		end
        %}
        
        for i=0:4
            j = i*2 + 1;
            Screen('DrawDots', winMain, nodulePositions(j:j+1), pointSize , [greyFlavor,greyFlavor,greyFlavor, tumorOpacity], [], 2  );
        end
        
        Screen('Flip', winMain,[],1);
        waitForKey(progressKey);
        
        colorNoduleHighlight = [180 180 0];
        lowerLeft = nodulePositions-20;
        upperRight = nodulePositions+20;
        
        for i=0:4
            j = i*2 + 1;
            Screen('FrameOval', winMain, colorNoduleHighlight,[ lowerLeft(j:j+1) upperRight(j:j+1) ]);
        end
        
        Screen('Flip', winMain,[],1);
        WaitSecs(.5);
        
        waitForKey(progressKey);
        
        %    cd ../..
        %%PRAC TRIAL
    end
    
    durationMtx=zeros(6000,13*5); %not sure how big to make this thing...
    
   
    %order =[13, 8]
    length(order)
    for ctr=1:13 %length(order)%numTrials
        order(ctr)
        count1 = count1+1;
        trialOrder(count1)=order(ctr);
        
        
        if ctr == 1
            tColor = greyFlavor;%10;
            tempTumor=tumorOpacity;
            tumorOpacity =tumorOpacity*2;
        else
            tumorOpacity=tempTumor;
            tColor = greyFlavor;
        end
        pointer=zeros(101,4);
        pointerColor=zeros(101,3);
        levelDurations=zeros(101,1);
        quad_Durations=zeros(101,4);
        rectA = zeros(101,4);
        rectB = zeros(101,4);
        rectC = zeros(101,4);
        rectD = zeros(101,4);
        colorsA=zeros(101,4);
        colorsA(2:100,1:3)=255;
        colorsA(2:100,4)=255;
        colorsB=zeros(101,4);
        colorsB(2:100,1:3)=255;
        colorsB(2:100,4)=255;
        colorsC=zeros(101,4);
        colorsC(2:100,1:3)=255;
        colorsC(2:100,4)=255;
        colorsD=zeros(101,4);
        colorsD(2:100,1:3)=255;
        colorsD(2:100,4)=255;
        pointerA=zeros(101,4);pointerB=zeros(101,4);pointerC=zeros(101,4);pointerD=zeros(101,4);
        
        for i=1:101 %this is where we make two 100 part rectangles that are filled according to where you are and the feedback.
            pointerA(i,:)=[screenPosition(1)-60 149+(i*1) screenPosition(1)-50 149+(i*1)+1];
            pointerB(i,:)=[screenPosition(1)-60 499+(i*1) screenPosition(1)-50 499+(i*1)+1];
            pointerC(i,:)=[screenPosition(3)+50 149+(i*1) screenPosition(3)+60 149+(i*1)+1];
            pointerD(i,:)=[screenPosition(3)+50 499+(i*1) screenPosition(3)+60 499+(i*1)+1];
            
            rectA(i,:)=[screenPosition(1)-50 149+(i*1) screenPosition(1)-20 149+(i*1)+1];
            rectB(i,:)=[screenPosition(1)-50 499+(i*1) screenPosition(1)-20 499+(i*1)+1];
            rectC(i,:)=[screenPosition(3)+20 149+(i*1) screenPosition(3)+50 149+(i*1)+1];
            rectD(i,:)=[screenPosition(3)+20 499+(i*1) screenPosition(3)+50 499+(i*1)+1];
        end
        
        %mouse click places
        %this sets up a hot zone where mouse clicks navigate in the second
        %portion of the exp.
        mouseA=[screenPosition(1)-50 150 screenPosition(1)-20 250];
        mouseB=[screenPosition(1)-50 500 screenPosition(1)-20 600];
        mouseC=[screenPosition(3)+20 150 screenPosition(3)+50 250];
        mouseD=[screenPosition(3)+20 500 screenPosition(3)+50 600];
        
        % feedback rectangles
        %positions for cues for drilling
        q1_scolor=[205 45 centX centY];
        q2_scolor=[205 centY centX 915];
        q3_scolor=[centX 45 1075 centY];
        q4_scolor=[centX centY 1075 915];
        
        for i=1:tumorMx(1,6,order(ctr))
            durationMtx(i,(order(ctr)*7-5))=tumorMx(i,3,order(ctr));
        end
        if tumorMatrix(1,7,order(ctr)) == 1
            fname = 'images/176M/176M';
            startP = tumorMatrix(1,8,order(ctr));
            %             midX = 711;
            %             midY = 582;
        elseif tumorMatrix(1,7,order(ctr)) ==2
            fname = 'images/183s/183S';
            %             midX = 505;
            %             midY = 685;
            startP = tumorMatrix(1,8,order(ctr));
        elseif tumorMatrix(1,7,order(ctr)) ==3
            fname = 'images/279M/279M';
            %             midX = 671;
            %             midY = 525;
            startP = tumorMatrix(1,8,order(ctr));
        elseif tumorMatrix(1,7,order(ctr)) ==4
            fname = 'images/340T/340T';
            %             midX = 662;
            %             midY = 466;
            startP = tumorMatrix(1,8,order(ctr));
        elseif tumorMatrix(1,7,order(ctr)) ==5
            fname = 'images/362M/362M';
            %             midX = 657;
            %             midY = 496;
            startP = tumorMatrix(1,8,order(ctr));
        end
        %         midX=centX;
        %         midY=centY;
        endP = startP+100;
        currentDepthCT= tumorMatrix(1,8,order(ctr));
        place = num2str(currentDepthCT);
        if currentDepthCT < 10
            place = strcat('00', place);
        elseif currentDepthCT < 100
            place = strcat('0',place);
        end
        %place
        %fname
        filename = strcat(fname, '0',  place, '.jpg');
        fullImage = strcat('fullImage_', place, '.jpg');
        %image = imread(filename);
        %cd ../..
        %%%%%%uparrow = 82, down = =81
        
        %%%%%% Alex graphics classes
        sg = sg.loadImages(startP, endP, fname, '%s%04d.jpg');
        sg = sg.updateCurrentSlice(currentDepthCT - startP + 1);
        %%%%%
        
        
        %%%%%%EYETRACKING STUFF
        % STEP 7.1
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.
        
        if ERPon==1
            Eyelink('Message', 'TRIALID %d', ctr);
            
            % This supplies the title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message "TRIAL %d/%d  %s"', ctr, order(ctr), filename);
            
            Eyelink('Command', 'set_idle_mode');
            % clear tracker display and draw box at center
            %EyeLink('Command', 'clear_screen %d',0);
            Eyelink('command', 'clear_screen %d',0');
            HideCursor();
            EyelinkDoTrackerSetup(el);
            ShowCursor();
            %[status = ] Eyelink('DriftCorrStart', x, y [,dtype=0][, dodraw=1][, allow_setup=0])
            %Eyelink('DriftCorrStart', 500, 500, 0 , 1, 1);
            % STEP 7.3
            % start recording eye position
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording', 1, 1, 1, 1);
            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data
            WaitSecs(0.1);
        end
        %        Screen(winMain,'TextSize',30);
        Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]); %%make black bgnd
        %        invFtexture = Screen('MakeTexture', winMain, image);
        %Screen('DrawTexture',winMain, invFtexture,[0 0 fieldsz fieldsz],[centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)],[],[],NoiseOpacity);
        
        
        DrawFormattedText(winMain, 'Press the down arrow to begin the trial. Try to find as many nodules as possible.','center', 5, textColor,50);
        
        
        Screen('Flip', winMain,[],1);
        Screen('FillRect', winMain, nullcol, nullfield); % the no zone
        
        nextScreen(progressKey);
        
        %note that this was added after subjct 1 on 2/21/12
        
        if ERPon==1
            Eyelink('Message', 'SearchStart');
        end
        
        eye_variable = 1;
        
        if ERPon==1
            eye_used = Eyelink('EyeAvailable');
        end
        
        quitFlag=0;
        hits = 0;
        FAs = 0;
        markNumber= 0;
        changes = 0;
        samp=0; samp2=0;
        quad_levels=zeros(101,4);
        q(1:4)=0; %reset counters after each change in depth
        
        drillNumber=1;% set up at start
        direction = 'down';
        updateTime=9000;
        %         here =[centX-(stimSize/2) centY-(stimSize/2) centX+(stimSize/2) centY+(stimSize/2)]
        %         fieldsz
        for part = 2:2
            if part==2
                if feedback(ctr)==1
                    Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]); % empties screen
                    DrawFormattedText(winMain, 'You will receive feedback about what areas you have looked at in the lung.  Press Spacebar to move on.','center', 5, textColor,50);
                else
                    Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]); % empties  screen
                    DrawFormattedText(winMain, 'You will NOT receive feedback about what areas you have looked at in the lung.  Press Spacebar to move on.','center', 5, textColor,50);
                end
            end
            quitFlag=0;
            
            
            Screen('Flip', winMain,[],1);
            Screen('FillRect', winMain, nullcol, nullfield); % the no zone
            
            nextScreen(progressKey);
            
            if part==1
%                 StartTime1=GetSecs;
%                 timeLimit=60*2;
            else
                timeLimit=60*5;
                StartTime=GetSecs;
                part1_exp_quad_Durations(:,:, order(ctr))=quad_Durations;
                part1_exp_level_Durations(:, order(ctr))=levelDurations;
            end
            %startingPart = GetSecs;
            
            if ERPon==1
                Eyelink('Message', 'Search_Start');
            end
            %header information
            
            %             if feedback(ctr)==1
            %             if part==1
            %                 Screen('FillRect', winMain, [0 0 0],[0 0 screenX 50]); %the empties top of screen
            %                 if ScanOrDrill==2
            %                     DrawFormattedText(winMain, 'Please search only the cued quadrant of the lung','center', 0, [0 0 255]);
            %                 else
            %                     DrawFormattedText(winMain, 'Please search each level of the lung only once','center', 0, [0 0 255]);
            %                 end
            %             else
            %                 Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]); % empties  screen
            %                 DrawFormattedText(winMain, 'You have 1 minute to search however you please.','center', 5, [0 0 255],50);
            %             end
            ShowCursor(5);
            
            %            getMouseWheel(); % clear mouse wheel buffer
            scanList = zeros(256); % TODO: control which keys to look for in KbCheck
            
            zPressed = 0;
            zCode = 29;
            %            sg.draw();
            mx = 0;
            my = 0;
            mb = 0;
            feedbackLocation = [0 0];
            eyeX = 0;
            eyeY = 0;
            
            mouse = MouseState();
            
            while quitFlag==0 % Show things and collect response
                button=0;
                
                ShowCursor(5);
                
                %while button(1)==0 %&& quitFlag==0
                while button == 0
                    
                    if crosstown==1
                        [x,y,button]=GetMouse(screenNumber);
                    else
                        [x,y,button]=GetMouse;
                    end
                    
                    mouse = mouse.update(winMain); %update mouse object, this is somewhat redundant vs lines above
                    if (mouse.buttons(1))
                        slice = sg.getSlice(mouse);
                        if (slice > 0)
                            currentDepthCT = changeSlice(slice, part, 1);
                        end
                    end
                    %%%%i dont understand what the following bit does.
                    if (mouse.buttons(1) && usePopupFeedback && zPressed) %if popup, need to check clicks
                        slices = sg.getSliceInGazeFeedback(feedbackLocation(1), feedbackLocation(2), 50, 200, mouse);
                        for i=1:4
                            if (slices(i) ~= 0)
                                currentDepthCT = changeSlice(slices(i), part, 2);
                            end
                        end
                    end
                    
                    [keyDown, keyTime, keyCode] = KbCheck;
                    
                    if part==2 % if we are in the second phase, allow jumping by mouse click.
                        
                        if ((x > mouseA(1) && x < mouseA(3) && y > mouseA(2) && y < mouseA(4))  ||...
                                (x > mouseB(1) && x < mouseB(3) && y > mouseB(2) && y < mouseB(4))  ||...
                                (x > mouseC(1) && x < mouseC(3) && y > mouseC(2) && y < mouseC(4))  ||...
                                (x > mouseD(1) && x < mouseD(3) && y > mouseD(2) && y < mouseD(4)) ) &&...
                                button(1)~=0 % then it is in the quitting zone
                            
                            
                            if y>mouseB(2)
                                currentDepthCT = y-mouseB(2)+startP;
                            else
                                currentDepthCT = y-mouseA(2)+startP;
                            end
                            
                            changeSlice(currentDepthCT - startP + 1, part, 3);
                            
                            %                             place = num2str(currentDepthCT);
                            %                             if currentDepthCT < 10
                            %                                 place = strcat('00', place);
                            %                             elseif currentDepthCT < 100
                            %                                 place = strcat('0',place);
                            %                             end
                            
                            %                            filename = strcat(fname, '0',  place, '.jpg');
                            %                            image = imread(filename);
                            %	                            Screen('Close',invFtexture);
                            
                            %                            invFtexture = Screen('MakeTexture', winMain, image);
                            %                            Screen('DrawTexture',winMain, invFtexture,[0 0 512 512],[centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)],[],[],NoiseOpacity);
                            
                            % 							sg.drawTexture([0 0 512 512],[centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)], NoiseOpacity);
                            %
                            %                             %Screen('DrawTexture',winMain, invFtexture,[0 0 fieldsz fieldsz],[centX-(stimSize/2) centY-(stimSize/2) centX+(stimSize/2) centY+(stimSize/2)],[],[],NoiseOpacity);
                            %                             Screen('FillRect', winMain, nullcol, nullfield); % the no zone
                            %                             DrawFormattedText(winMain, 'Click here when finished',15, centY-50, [0 0 0],10);
                            
                            %                             sg = sg.updateCurrentSlice(currentDepthCT - startP + 1); %this updates the current slice immediately.
                            draw(winMain, sg, centX, centY, fieldsz, nullcol, nullfield, NoiseOpacity, pointerColor, pointerA, pointerB, pointerC, pointerD, colorsA, colorsB, colorsC, colorsD, rectA, rectB, rectC, rectD, q1_scolor, q2_scolor, q3_scolor, q4_scolor, part, feedback(ctr), order(ctr), drillNumber);
                            
                            drill =Screen('Flip', winMain,[],1);
                            
                            if ERPon
                                Eyelink('Message', 'MouseJump'); %
                                level_msg = strcat('level_',num2str(currentDepthCT));
                                Eyelink('Message', level_msg); %
                            end
                        end
                        
                        
                    end % if we are in the second phase, allow jumping by mouse click.
                    
                    
                    
                    %if eye tracker is not available, feedback uses mouse positions
                    if (part == 1)
                        %updateFeedback(currentDepthCT-startP+1, StartTime1,eye_used, ERPon);
                    else
                        updateFeedback(currentDepthCT-startP+1, StartTime, eye_used, ERPon);
                    end
                    
                    currentTime = GetSecs();
                    if part==1
                        %duration = currentTime-StartTime1;
                    else
                        duration = currentTime-StartTime;
                    end
                    %%feedback bar
                    pointerColor(:,1:3)=0;
                    pointerColor(currentDepthCT-startP+1,1:3)=255;
                    Screen('Flip', winMain,[],1);
                    
                    %%feedback bar
                    
                    
                    while keyDown || (GetSecs)>(updateTime &&changes>0)
                        if ERPon==1
                            
                            if (part == 1)
                                %updateFeedback(currentDepthCT-startP, StartTime1,eye_used, ERPon);
                            else
                                updateFeedback(currentDepthCT-startP, StartTime, eye_used, ERPon);
                            end
                            
                        end
                        
                        response = 0;
                        
                        if keyDown
                            response = find(keyCode, 1, 'first');
                            firstResponse = find(keys == response);
                        else
                            firstResponse =99; %kludging for cases where we want to update without changing screen
                        end
                        change = 0;
                        
                        if firstResponse == 1 %f
                            change = 1;
                            currentDepthCT = changeSlice(sg.currentSlice - 1, part, 4);
                            
                        elseif firstResponse ==2 %j
                            change = 1;
                            currentDepthCT = changeSlice(sg.currentSlice + 1, part, 4);
                        end
                        
                        wheel = getMouseWheel();
                        if (wheel ~= 0)
                            currentDepthCT = min(startP, max(endP, currentDepthCT + wheel));
                            change = 1;
                            %TODO: need additional lines WRT direction?
                        end
                        
                        if (response == zCode && zPressed ~= 1)
                            change = 1;
                            zPressed = 1;
                            if (ERPon == 1)
                                feedbackLocation = updateEyePosition(eye_variable);
                            else
                                [mx, my, mb] = GetMouse(winMain);
                                feedbackLocation(1) = mx;
                                feedbackLocation(2) = my;
                            end
                            
                        elseif (response == 0 && zPressed == 1)
                            change = 1;
                            zPressed = 0;
                        end
                        
                        if change ==1 || (GetSecs)>(updateTime) %&&changes>0)
                            if change ==1
                                changes = changes+1;
                            end
                            if ERPon==1
                                %%% updating stuff during loop
                                pointerColor(:,3)=0;
                                pointerColor(currentDepthCT-startP+1,3)=255;
                            end
                            
                            Screen('Flip', winMain,[],1);
                            %%%%
                            %q(1:4)=0; %reset counters after each change in depth
                            if changes ==1
                                Screen('FillRect', winMain, [0 0 0], [centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)]); % the no zone
                            end
                            place = num2str(currentDepthCT);
                            
                            if currentDepthCT < 10
                                place = strcat('00', place);
                            elseif currentDepthCT < 100
                                place = strcat('0',place);
                            end
                            
                            draw(winMain, sg, centX, centY, fieldsz, nullcol, nullfield, NoiseOpacity, pointerColor, pointerA, pointerB, pointerC, pointerD, colorsA, colorsB, colorsC, colorsD, rectA, rectB, rectC, rectD, q1_scolor, q2_scolor, q3_scolor, q4_scolor, part, feedback(ctr), order(ctr), drillNumber);
                            
                            for i=1:tumorMx(1,6,order(ctr))+4 %tumorNumber
                                noduleSlice = tumorMx(i,3,order(ctr));
                                
                                if (currentDepthCT <= noduleSlice + 2 && currentDepthCT >= noduleSlice - 2)
                                    noduleDistance = abs(currentDepthCT-noduleSlice); %calculate how far we are from the center
                                    noduleLocation = [tumorMx(i,1,order(ctr)) tumorMx(i,2,order(ctr))];
                                    noduleFactors = [ 1 1/1.25 1/1.25/1.25 ];
                                    noduleSize = tumorMx(i,4,order(ctr)) * noduleFactors(noduleDistance + 1);
                                    noduleSize = StackGraphics.clamp(noduleSize, 0.5, 10); %AO: for windows box, I get an error if noduleSize > 10
                                    Screen('DrawDots', winMain, noduleLocation, noduleSize, [tColor, greyFlavor, greyFlavor, tumorOpacity], [], 2  );
                                end
                                
                                % 								if zPressed && currentDepthCT>markMatrix(i,3,order(ctr))-3 && currentDepthCT<markMatrix(i,3,order(ctr))+3
                                %                                     Screen('FrameOval', winMain,[180 180 180 90],[markMatrix(i,1,order(ctr))-stimsz markMatrix(i,2,order(ctr))-stimsz markMatrix(i,1,order(ctr))+stimsz markMatrix(i,2,order(ctr))+stimsz]);
                                %
                                %                                 end
                                if currentDepthCT>markMatrix(i,3,order(ctr))-3 && currentDepthCT<markMatrix(i,3,order(ctr))+3
                                    Screen('FrameOval', winMain,[180 180 180 90],[markMatrix(i,1,order(ctr))-stimsz markMatrix(i,2,order(ctr))-stimsz markMatrix(i,1,order(ctr))+stimsz markMatrix(i,2,order(ctr))+stimsz]);
                                    
                                end
                            end
                            
                            if (zPressed && usePopupFeedback && part==2) sg.drawGazeFeedback(feedbackLocation(1), feedbackLocation(2), 50, 200, colorsA, colorsD, colorsB, colorsC);
                            end
                            
                            drill =Screen('Flip', winMain,[],1);
                            %updateTime = drill+.5;
                            if ERPon==1
                                level_msg = strcat('level_',num2str(currentDepthCT));
                                Eyelink('Message', level_msg); %
                            end
                            if change ==1
                                timePerLevel(currentDepthCT-startP+1,order(ctr))=timePerLevel(currentDepthCT-startP+1,order(ctr))+duration;
                                durationMtx(changes,(order(ctr)*7)-4)=duration;
                                durationMtx(changes,(order(ctr)*7)-3)=currentDepthCT;
                                durationMtx(changes,(order(ctr)*7)-2)=markNumber;
                                durationMtx(changes,(order(ctr)*7)-1)=hits;
                            end
                            %quad_Durations;
                            %samp;
                            %sum(quad_Durations(:,:));
                            %q(1:4)=0; %reset counters after each change in depth
                        end
                        break  %this stops the while loop from sticking forever
                    end
                    
                    
                    %if T-t2> 600*4%5 %5 minutes seemed too long so i made it shorter.
                    if duration> timeLimit && ctr~=1 %|| (ScanOrDrill==2 && drillNumber>4) %|| (ScanOrDrill==1 && drillNumber>1)%&& ctr~=1 %600*4%5 %5 minutes seemed too long so i made it shorter.
                        quitFlag=1;
                        if part ==1
                            %                             part1Duration = GetSecs - StartTime1;
                            %                             DrawFormattedText(winMain, 'THE END OF PART 1', 'center',300, textColor2);
                            %                             if ERPon==1
                            %                                 Eyelink('Message', 'Part1End'); %
                            %                             end
                            %                             drillNumber=0; %reset drill so we dont end trial
                        else
                            DrawFormattedText(winMain, 'End of this part of the trial', 'center',300, textColor2);
                            trialDuration = GetSecs - StartTime;
                            if ERPon==1
                                Eyelink('Message', 'TimeRanOut'); %
                                Eyelink('Message', 'QuitClick'); %
                            end
                            quitters(order(ctr))=1;
                        end
                        Screen('Flip', winMain,[],1);
                        WaitSecs(1.25);
                        break %this should break the quitflag loop
                    end
                    if duration>timeLimit-30 && duration<timeLimit-29.9 %give them a warning beep
                        Snd('Play',beep);
                    end
                    hitcounter =0;%zeros(tumorMx(1,6,order(ctr)),1);
                    FAcounter = 0;
                    if x > nullfield(1) && x < nullfield(3) && y > nullfield(2) && y < nullfield(4)  && button(1)~=0% then it is in the quitting zone
                        drillNumber=0; %reset drill so we dont end trial
                        if part ==1
                            %trialDuration = GetSecs - StartTime1;
                        else
                            trialDuration = GetSecs - StartTime;
                        end
                        if ERPon==1
                            Eyelink('Message', 'QuitClick'); %
                            if part==1
                                Eyelink('Message', 'phase1End');
                            end
                        end
                        if part ==1
                            %                             part1Duration = GetSecs - StartTime1;
                            %                             DrawFormattedText(winMain, 'THE END OF PART 1', 'center',300, textColor2);
                            %                             if ERPon==1
                            %                                 Eyelink('Message', 'Part1End'); %
                            %                             end
                            %                             drillNumber=0; %reset drill so we dont end trial
                        else
                            DrawFormattedText(winMain, 'TIME RAN OUT!', 'center',300, textColor2);
                            trialDuration = GetSecs - StartTime;
                            if ERPon==1
                                Eyelink('Message', 'TimeRanOut'); %
                                Eyelink('Message', 'QuitClick'); %
                            end
                            quitters(order(ctr))=1;
                        end
                        quitFlag=1;
                        Screen('FillRect', winMain, [0 200 150],nullfield); % the no zone
                        DrawFormattedText(winMain, 'DONE!',nulltextx, centY, [0 0 0]);
                        Screen('Flip', winMain,[],1);
                        
                        ShowCursor(5);
                        WaitSecs(0.15);
                        
                        
                    elseif x > centX-(stimSize/2) && y> centY-(stimSize/2) && x < centX+(stimSize/2) && y < centY+(stimSize/2) && button(1)~=0% check if it is in the stimulus
                        %x
                        %y
                        clickCode = strcat('click_',num2str(x),'x',num2str(y),'y',num2str(currentDepthCT),'z');
                        if ERPon==1
                            %Eyelink('Message', 'fieldClick'); %
                            Eyelink('Message', clickCode); %
                            %Eyelink('Message', num2str(GetSecs)); %
                        end
                        markNumber =markNumber+1;
                        if part==1
                           % RT1 = GetSecs-StartTime1;
                        else
                            RT1 = GetSecs-StartTime;
                        end
                        markMatrix(markNumber,1,order(ctr))= x;
                        markMatrix(markNumber,2,order(ctr))= y;
                        markMatrix(markNumber,3,order(ctr))= currentDepthCT;
                        markMatrix(markNumber,4,order(ctr))= part;
                        markMatrix(markNumber,5,order(ctr))= RT1;
                        %markMatrix(markNumber,6,order(ctr))= ScanOrDrill;
                        markMatrix(markNumber,7,order(ctr))= order(ctr);
                        markMatrix(markNumber,8,order(ctr))= cputime;
                        markMatrix(markNumber,10,order(ctr))= markNumber;
                        Screen('FrameOval', winMain,[180 180 0],[x-stimsz y-stimsz x+stimsz y+stimsz]); % show the click
                        
                        ShowCursor(5);
                        Screen('Flip', winMain,[],1);
                        WaitSecs(0.2);
                        % now check if the click was in an item location
                        for j=1:tumorMx(1,6,order(ctr)) %number of targets
                            if x < tumorMx(j,1,order(ctr))+tumorMx(j,4,order(ctr)) && x > tumorMx(j,1,order(ctr))-tumorMx(j,4,order(ctr)) && ...
                                    y > tumorMx(j,2,order(ctr))-tumorMx(j,4,order(ctr))  && y < tumorMx(j,2,order(ctr))+tumorMx(j,4,order(ctr)) && ...
                                    currentDepthCT >= tumorMx(j, 3,order(ctr))-2 && currentDepthCT <= tumorMx(j, 3,order(ctr))+2
                                hitcounter=1;%(j) = 1;
                                tumorMx(j,9,order(ctr)) = hitcounter;
                                tumorMx(j,5,order(ctr)) = markNumber;
                                tumorMx(j,10,order(ctr)) = RT1; %tTime;
                            end
                        end
                        if hitcounter ~=1
                            FAcounter = 1;
                            markMatrix(markNumber,9,order(ctr))= 1; %mark the FAs
                        end
                        
                    else
                        
                        ShowCursor(5);
                        button=0;
                        %                         resptype='BOGUS_CLICK';
                        %                         CADresptype='BOGUS_CLICK';
                    end  %%END CATEGORIZATION OF FIRST CLICK
                    
                    %WaitSecs(0.01); %change from .1 to make everything faster %otherwise it loops through too fast
                    %and goes too fast
                end %end while there are no acceptable clicks
                if hitcounter ==1
                    %tumorMx(:,9,order(ctr))
                    hits = sum(tumorMx(:,9,order(ctr)));
                elseif FAcounter ==1
                    FAs = FAs+1;
                end
            end
            %             quad_Durations_part1=quad_Durations;
            %         totalsamples =sum(quad_Durations)
            totalTrialTime = GetSecs-StartTime;
            if part==1
                jnk=999;
                fprintf(fid,'%d %d  %d %d %d %d %d %d \n', ctr, order(ctr), BlockNumber,  tumorMx(1,6,order(ctr)), hits, FAs,  changes, feedback(ctr));
                
            end
        end %this is the sequential loop
        
        
        
        missVector=zeros(1,6,order(ctr),1);
        for j=1:tumorMx(1,6,order(ctr))
            if tumorMx(j,9,order(ctr))==0
                missVector(j) = tumorMx(j, 3,order(ctr));
            end
        end
        for i=1:tumorMx(1,6,order(ctr))
            durationMtx(i,(order(ctr)*7-6))=tumorMx(i,9,order(ctr));
        end
        
        ShowCursor;
        button2=0;
        ThisRating=0;
        while button2==0   % click on image
            
            
            Screen('FillRect', winMain, [0 0 0],[0 0 screenX 50]); %the empties top of screen
            DrawFormattedText(winMain, 'How confident are you that you found all the tumors (if any)?', 'center',850, textColor);
            DrawFormattedText(winMain, '(1:Sure you didn not find them all) -to- (6:Sure that you found them all)','center',880, textColor);
            for k=1:6
                Screen('FillRect', winMain, ratingcol(k,:),ratingfield(k,:)); % the rating zones
                Screen('FrameRect', winMain, [ratingcol(k,:)],[ratingfield(k,:)],2); % the rating zone
                DrawFormattedText(winMain, num2str(k),ratingfield(k,1)+10,ratingfield(k,2)+10, textColor2);
            end
            Screen('Flip', winMain,[],1);
            if crosstown==1
                [xx,yy,button2]=GetMouse(screenNumber);
            else
                [xx,yy,button2]=GetMouse;
            end
            if xx > ratingfield(1,1) && xx < ratingfield(6,3) && yy > ratingfield(1,2) && yy < ratingfield(6,4) % then it is in the rating field zone
                for k=1:6
                    if xx > ratingfield(k,1) && xx < ratingfield(k,3) && yy > ratingfield(k,2) && yy < ratingfield(k,4) % then it is in the kth rating field zone
                        ThisRating=k;
                    end
                end
            else
                button2=0;
            end
        end
        Screen('FillRect', winMain, [0 0 0],[0 screenY-75 screenX screenY]); % clean out the bottom
        Screen('Flip', winMain,[],1); % you only see the change to winMain when you flip
        %end
        
        %         if mod(order(ctr),50)==0 && order(ctr)~=200 %|| order(ctr) ==1
        misses = tumorMx(1,6,order(ctr))- hits;
        feedbackString = ['You found ', num2str(hits), ' target(s), had ', num2str(FAs), ' false alarm(s) and missed ', num2str(misses ),' target(s)'...
            'You have now completed ', num2str(ctr), ' trials.  Press Spacebar to continue.'];
        Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]);
        DrawFormattedText(winMain, feedbackString, 'center', 600, [255 255 255], 50);
        %put feedbackmarks here
        
        
        missVector=missVector(1,find(missVector>0))-startP+1;
        pointerColor(:,3)=0;
        pointerColor(missVector(:),1)=255;
        Screen('FillRect', winMain, pointerColor', pointer');
        
        Screen('Flip', winMain,[],1);
        
        nextScreen(progressKey);
        
        WaitSecs(.25);
        
        
        
        fprintf(fid,'%d %d %d %d %d %d %d %d %d %d %d \n', ctr, order(ctr), BlockNumber,  tumorMx(1,6,order(ctr)), hits, FAs, ThisRating, changes, feedback(ctr), trialDuration, totalTrialTime );
        a444 = size(tumorMx);
        lengthT = a444(1);
        %fid2=fopen(Cname,'a');
        for i = 1:lengthT
            if tumorMx(i,1,order(ctr)) == 0
                break
            end
            Xx = round(tumorMx(i,1,order(ctr)));
            Yy = round(tumorMx(i,2,order(ctr)));
            fprintf(fid2, '%d %d %d %d %d %d %d %d %d %d\n', ctr, order(ctr),Xx, Yy,tumorMx(i,3,order(ctr)),tumorMx(i,4,order(ctr)),...
                tumorMx(i,5,order(ctr)),tumorMx(i,9,order(ctr)),tumorMx(i,10,order(ctr)), feedback((ctr)));
        end
        
        ddd = markMatrix(find(markMatrix(:,1,order(ctr))>0),:, order(ctr));
        
        
        % stop the recording of eye-movements for the current trial
        if ERPon==1
            Eyelink('StopRecording');
            trackerError = 15;
            % STEP 7.7
            % Send out necessary integration messages for data analysis
            % Send out interest area information for the trial
            
            % Consider adding a short delay every few messages.
            
            WaitSecs(0.001); % hier zum beispiel ein delay nach den ersten messages
            Eyelink('Message', '!V TRIAL_VAR feedback %d', feedback(ctr))
            Eyelink('Message', '!V TRIAL_VAR trial %d', order(ctr))
            Eyelink('Message', '!V TRIAL_VAR index %d', ctr)
            Eyelink('Message', '!V TRIAL_VAR image %s', fullImage)
            
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, centX-(stimSize/2), centY-(stimSize/2), centX+(stimSize/2), centY+(stimSize/2),'lungArea');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, 0, centY-(screenY*StimScale*.25), 130, centY+(screenY*StimScale*.25),'quitArea');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 3, mouseA(1), mouseA(2), mouseA(3), mouseA(4),'quad1Bar');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 4, mouseB(1), mouseB(2), mouseB(3), mouseB(4), 'quad2Bar');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 5, mouseC(1), mouseC(2), mouseC(3), mouseC(4), 'quad3Bar');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 6, mouseD(1), mouseD(2), mouseD(3), mouseD(4), 'quad4Bar');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 7, screenPosition(1), screenPosition(2), centX, centY,'quad1Rect');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 8, screenPosition(1), centY, centX, screenPosition(4),'quad2Rect');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 9, centX, screenPosition(2), screenPosition(3),  centY,'quad3Rect');
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 10, centX, centY, screenPosition(3), screenPosition(4),'quad4Rect');
            
            
        end
        % STEP 7.8
        % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
        % Data Viewer.
        if ERPon==1
            WaitSecs(.25);
            Eyelink('Message', 'TRIAL_RESULT 0')
            
        end
%         marksOut = vertcat(marksOut, ddd);
%         markOutput.order(ctr)=marksOut;
        exp_quad_Durations(:,:, order(ctr))=quad_Durations;
        exp_level_Durations(:, order(ctr))=levelDurations;
        eval(['save ' Oname ]); %thanks to michelle for this little bit of code. SAVE EVERYTHING!
        
        
    end
    if ERPon==1
        Eyelink('CloseFile');
        
        % download data file
        try
            fprintf('Receiving data file ''%s''\n', edfFile );
            status=Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist(edfFile, 'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
            end
        catch
            fprintf('Problem receiving data file ''%s''\n', edfFile );
        end
        
        
        %close the eye tracker.
        Eyelink('ShutDown');
    end
    Screen('CloseAll');
    ListenChar(0)   % starts echoing of getchar
    Screen('CloseAll')
    close all
    clear all
    
    
    %quit;
catch
    % If any error occurred between the "try" command and the
    % "catch" command, then Matlab will jump to here in the code.
    
    if ERPon==1
        
        
        %%
        %$ just in case something goes wrong during the experiment, the
        %existing data should be saved into an edf file
        
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.5);
        Eyelink('CloseFile');
        
        % download data file
        try
            fprintf('Receiving data file ''%s''\n', edfFile );
            status=Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist(edfFile, 'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
            end
        catch
            fprintf('Problem receiving data file ''%s''\n', edfFile );
        end
        
        
        %close the eye tracker.
        Eyelink('ShutDown');
        Screen('CloseAll');
        
        
        
        
    end
    ple;
    ListenChar(0)   % starts echoing of getchar
    Screen('CloseAll')
    close all
    clear all
    
    
    % error that got us here in the first place.
end %try..catch..
end

function waitForKey(code)
keyCode=0;keysPressed=0;
%    while keysPressed ~=44 %spacebar code use kbname('space') to reconfigure

while keysPressed ~= code
    [keyIsDown, secs, keyCode] = KbCheck;
    if sum(keyCode)==1   % if at least one key was pressed
        keysPressed = find(keyCode);
    end
end
end

function nextScreen(progressKey)

global winMain screenX screenY

waitForKey(progressKey);

Screen('FillRect', winMain, [0 0 0],[0 0 screenX screenY]);

Screen('Flip', winMain); % this should clean out whatever was on there

end

function f = getMouseWheel()

wheel = 0;
%{
    Crashes psychtoolbox and matlab...
    
    From: http://towolf.github.com/Psychtoolbox-3/
    "Mouse wheel support: On OS/X the function GetMouseWheel() allows query
    of the state/movement of the mouse wheels of wheel mice.
    However, this seems to occassionally crash after multiple ?clear all?
    -> run script -> ?clear all? cycles for yet unresolved reasons."
    
    try
        wheel = GetMouseWheel();
    catch err
        'problem with mouse wheel'
    end
%}
f = wheel;

end

function eyePosition = updateEyePosition(eye_variable)

if Eyelink('NewFloatSampleAvailable')
    evt = Eyelink('NewestFloatSample');
    % get current gaze position from sample
    
    % +1 as we're accessing MATLAB array
    eyePosition = [ evt.gx(eye_variable+1) evt.gy(eye_variable+1)];
end

%Screen('FillOval', winMain,[180 0 0 90],[rx-20 ry-20 rx+20 ry+20]);
end

function updateFeedback(d, time, eye_used, useEyeTracker)

global quad_Durations quad_levels colorsA colorsB colorsC colorsD levelDurations screenPosition winMain
global screenX screenY gazeData
xIndex=14;
yIndex=16;
drained=1;
thistime =round((GetSecs-time)*1000);
midX=screenX/2;
midY=screenY/2;
q=zeros(1,4);
samples = 0;

%for mouse only seems to update when z is pressed?
%also not continously? this needs to be double checked

while drained==1 &&  mod(thistime,5)==0
    if (useEyeTracker)
        [samples,events,drained] = Eyelink('GetQueuedData');
        v = 1;
    else % emulate gaze with mouse cursor
        [mouseX, mouseY] = GetMouse(winMain);
        v = 100000;
    end
    
    %a = 'drain'
    %thistime
    [aa bb]=size(samples);
    
    for i=1:bb
        if useEyeTracker == 1 || samples(2,i)==200  %&& drained==1
            %save  samples samples events
            
            if (useEyeTracker)
                x = samples(xIndex + eye_used, i);
                y = samples(yIndex + eye_used, i);
            else
                x = mouseX;
                y = mouseY;
            end
            
            %gazeData = gazeData.add(1, 1, x, y, thistime,99);
            %trial, image, x,y,t,z
            %want to save all trial, x, y, t and z here.
            
            if x>= screenPosition(1) && x<=midX && y>=screenPosition(2) && y<=midY
                q(1) = q(1)+v; % top left
            elseif x>= screenPosition(1) && x<=midX && y>=midY && y<=screenPosition(4)
                q(2)=q(2)+v; % bottom left
            elseif x>= midX && x<=screenPosition(3) && y>=screenPosition(2) && y<=midY
                q(3)=q(3)+v; % top right
            elseif x>= midX && x<=screenPosition(3) && y>=midY && y<=screenPosition(4)
                q(4)=q(4)+v; % bottom right
            end
        end
        
        
        if (useEyeTracker == 0) %mouse emulation
            drained = 0; %get out of this loop
            break; %only update for 1 mouse cursor
        end
    end
    
    
end

if d>0 && d<101
    quad_Durations(d,1:4)=quad_Durations(d,1:4)+q; %total time spend in area
    quad_levels(d,1:4)=quad_levels(d,1:4)+255*(quad_Durations(d,1:4)/500); %convert to 255 scale %previously 1008
    colorsA(d,1:3)=[255-quad_levels(d,1) 255-quad_levels(d,1) 255-quad_levels(d,1)];
    colorsB(d,1:3)=[255-quad_levels(d,2) 255-quad_levels(d,2) 255-quad_levels(d,2)];
    colorsC(d,1:3)=[255-quad_levels(d,3) 255-quad_levels(d,3) 255-quad_levels(d,3)];
    colorsD(d,1:3)=[255-quad_levels(d,4) 255-quad_levels(d,4) 255-quad_levels(d,4)];
    levelDurations(d)=levelDurations(d)+sum(q);
end

end

function draw(winMain, sg, centX, centY, fieldsz, nullcol, nullfield, NoiseOpacity, ...
    pointerColor, pointerA, pointerB, pointerC, pointerD, ...
    colorsA, colorsB, colorsC, colorsD,  ...
    rectA, rectB, rectC, rectD, ...
    q1_scolor, q2_scolor, q3_scolor, q4_scolor, ...
    part, feedback_ctr, order_ctr, drillNumber)

global usePopupFeedback fontSize screenX ScanOrDrill screenY textColor

Screen('FillRect', winMain);

q_color = [0 0 0];

Screen('FillRect', winMain, q_color, q1_scolor); %
Screen('FillRect', winMain, q_color, q2_scolor); %
Screen('FillRect', winMain, q_color,  q3_scolor); %
Screen('FillRect', winMain, q_color,  q4_scolor); %
% 
% q_color = [200 200 200];
% 
% if (ScanOrDrill ~= 1)
%     switch drillNumber
%         case 1, Screen('FillRect', winMain, q_color, q1_scolor); %
%         case 2, Screen('FillRect', winMain, q_color, q2_scolor); %
%         case 3, Screen('FillRect', winMain, q_color,  q3_scolor); %
%         case 4, Screen('FillRect', winMain, q_color,  q4_scolor); %
%     end
% end

sg.drawTexture([0 0 512 512],[centX-(fieldsz/2) centY-(fieldsz/2) centX+(fieldsz/2) centY+(fieldsz/2)], NoiseOpacity);
sg.draw();

Screen('FillRect', winMain, nullcol, nullfield); % the no zone
DrawFormattedText(winMain, 'Click here when finished', fontSize, centY-50, [0 0 0],10);

Screen('TextSize',winMain,fontSize);

if part==1
    if ScanOrDrill==2
        DrawFormattedText(winMain, 'Please search only the cued quadrant of the lung','center', 0, textColor);
    else
        DrawFormattedText(winMain, 'Please search each level of the lung only once','center', 0, textColor);
    end
else
    DrawFormattedText(winMain, 'Please try to search the lung completely.','center', 5, textColor,50);
end

if usePopupFeedback == 0 && part==2 && (feedback_ctr==1 || order_ctr==1)
    
    Screen('FillRect', winMain, pointerColor', pointerA');
    Screen('FillRect', winMain, pointerColor', pointerB');
    Screen('FillRect', winMain, pointerColor', pointerC');
    Screen('FillRect', winMain, pointerColor', pointerD');
    
    Screen('FillRect', winMain, colorsA', rectA'); % all the levels
    Screen('FillRect', winMain, colorsB', rectB'); % all the levels
    Screen('FillRect', winMain, colorsC', rectC'); % all the levels
    Screen('FillRect', winMain, colorsD', rectD'); % all the levels
    
    %                     else %no feedback
    %                          Screen('FillRect', winMain, WhiteRect', rectA'); % all the levels
    %                          Screen('FillRect', winMain, WhiteRect', rectB'); % all the levels
    %                          Screen('FillRect', winMain, WhiteRect', rectC'); % all the levels
    %                          Screen('FillRect', winMain, WhiteRect', rectD'); % all the levels
    
end

end

function c = changeSlice(slice, part, type)
global sg drillNumber direction currentDepthCT startP endP ERPon
%type
%1 = vertical scrollbar
%2 = popup feedback
%3 = feedback bars (static)
%4 = arrow keys

sg = sg.updateCurrentSlice(slice);
c = sg.currentSlice + startP - 1;

if strcmp('up',direction) && c==startP && part==1
    drillNumber = drillNumber+1;
    direction = 'down';
elseif strcmp('down',direction) && c==endP && part==1
    drillNumber = drillNumber+1;
    direction = 'up';
end


if ERPon==1
    s = sprintf('change\t%d', type);
    level_msg = strcat('level_',num2str(currentDepthCT));
    Eyelink('Message', level_msg); %
    %Eyelink('Message', s); %%%start of the trial for the eyetracker
end
end

