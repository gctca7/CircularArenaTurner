function ArenaImageProc();
% Calculate a BackgroundImage and Identify ArenaEdges for fly detection
% Returns a structure ArenaInfo for each Cam with fields
% .Camera           Cam0 or Cam1
% .BackgroundImage  Max Intensity Projection of many frames of the movie
%                   Subtract from each movie frame to remove stationary objects
%                   otherwise mistaken for flies

% .ArenaEdge        Use to create a mask on the arena border
% .X_Quad1...etc    X locations of quadrant corners
% .Y_Quad1...etc    Y locations of quadrant corners

% IMPROVEMENTS
% - Draw a spot in the center of the ArenaEdges circle to make sure it's in the center of the arena
% - It may be quicker to simply average the entire movie with appropriate ufmf script
% NOTE Taking the mean of 15sec of frames I still see fly shadows in the BackgroundImage
% - I could change the indexing on the X_Quad instead of having 4 separate
% fields
%  - Arrange so you can feed in default arena information


%% Change directory to folder containing experiment lists (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);

for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    ArenaInfo.ExptPathName = ExptName ;
    
    % Determine camera number - needed for assigning Odors to Quadrants
    Cam0 = strfind(ExptName,'Cam0');
    if ~isempty(Cam0)
        ArenaInfo.Camera = 'Cam0' ;
    else
        Cam1 = strfind(ExptName,'Cam1');
        if ~isempty(Cam1)
            ArenaInfo.Camera = 'Cam1' ;
        end
    end
    
    video = dir('movie_Test*.ufmf') ;
    Header = ufmf_read_header(video(1).name) ;
    ArenaInfo.Header = Header ;
    FrameRate = round(1/mean(diff(Header.timestamps))) ;
    FrameSize = [Header.max_width Header.max_height] ;
    TotalFrames = Header.nframes - rem(Header.nframes, FrameRate); % Round the number of frames to the nearest second
    
    %% Calculate BackgroundImage
    % Do a Maximum Intensity Projection of a 300 frame chunk of the movie
    BackgroundStack = load_frames(15*30,30*30,Header,video(1).folder) ;
    BackgroundImage = max(BackgroundStack,[],3) ;
    ArenaInfo.BackgroundImage = BackgroundImage ;
    % Invert the image so arena edges are bright i.e. a large number
%     imc = imcomplement(BackgroundImage) ;
    % Adjust image contrast so edges pop out more
    % Step 1: Zero out all low values (useful because subsequent steps adjust contrast by comparing local values not global
%     imc(find(imc<60)) = 0 ;
%     % Adjust contrast adaptive histogram equalization
%     imc_imadjust    = imadjust(imc) ;
%     imc_histeq      = histeq(imc) ;
%     imc_adapthisteq = adapthisteq(imc) ;
%     ScreenSizePixels = get(0,'screensize') ;
%     figure('position',[100 1500 ScreenSizePixels(3)*.6 ScreenSizePixels(4)*.4]) ;
%     tiledlayout(1,4)
%     nexttile ; imshow(imc) ; 
%     nexttile ; imshow(imc_imadjust) ;
%     nexttile ; imshow(imc_histeq) ;
%     nexttile ; imshow(imc_adapthisteq) ;
    disp(['Loop ' num2str(ExptIdx)])
        
 
BW1 = edge(BackgroundImage,'Roberts');
% BW2 = edge(BackgroundImage,'Sobel');
% figure;
% imshowpair(BW1,BW2,'montage')
    
    
       [Center, Radius] = imfindcircles(BW1,[440 480],'sensitivity',0.97)
       ; 
    Center = Center(1,:) ; 
    Radius = Radius(1) ; 
    pause(0.5)
    figure
    imshowpair(BW1,BackgroundImage,'montage')
    h = drawcircle('Center',Center,'Radius',Radius,'StripeColor','red');
    title(ExptName{ExptIdx})
%     h = images.roi.Circle(gca,'Center',Center,'Radius',Radius);
%       mm = createMask(h) ;
  
end

