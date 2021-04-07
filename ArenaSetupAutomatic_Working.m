function ArenaInfo = ArenaSetupAutomatic_Working();
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
% - Is it useful to arrange so you can feed in default arena information?
% - .png of arena does not have the title on it


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
    
    %% Demarcate the arena borders with a circular ROI & Draw Quadrants
    % Use edge detection to trace outlines of arena
    BIEdges = edge(BackgroundImage,'Roberts');
    % Find circles within the edge image - constrain the radius so the outer edge isn't found
    [Center, Radius] = imfindcircles(BIEdges,[440 470],'sensitivity',0.99)
    % Only return the 'best fit' circle
    Center = Center(1,:) ;
    Radius = Radius(1) ;
    disp(['Center ' num2str(Center(1)) ' ' num2str(Center(2)) ' Radius ' num2str(Radius)])
    
%     % Slow down execution so gcf is accurate
%     pause(0.5)
%     
    figure
    title(ExptName{ExptIdx},'Interpreter', 'none')
    imshow(BackgroundImage)
    h = drawcircle(gca,'Center',Center,'Radius',Radius);
    mm = createMask(h) ;
    
    ArenaInfo.ArenaCenter = Center ;
    ArenaInfo.ArenaRadius = Radius ;
    ArenaInfo.Mask = mm ;
    
    FS = size(BackgroundImage) ;    % Note odd indexing where X comes second
    EX = FS(2) ;
    EY = FS(1) ;
    CX = Center(1) ;                % Indexing here is X first
    CY = Center(2) ;
    
    % Quad1: Upper Left
    ArenaInfo.X_Quad1 = [1 CX CX 1] ;
    ArenaInfo.Y_Quad1 = [1 1 CY CY] ;
    % Quad2: Upper Right
    ArenaInfo.X_Quad2 = [CX EX EX CX] ;
    ArenaInfo.Y_Quad2 = [1 1 CY CY] ;
    % Quad3: Bottom Right
    ArenaInfo.X_Quad3 = [CX EX EX CX] ;
    ArenaInfo.Y_Quad3 = [CY CY EY EY] ;
    % Quad4: Bottom Left
    ArenaInfo.X_Quad4 = [1 CX CX 1] ;
    ArenaInfo.Y_Quad4 = [CY CY EY EY] ;
    
    patch(ArenaInfo.X_Quad1,ArenaInfo.Y_Quad1,'r','facealpha',0.1)
    patch(ArenaInfo.X_Quad2,ArenaInfo.Y_Quad2,'g','facealpha',0.1)
    patch(ArenaInfo.X_Quad3,ArenaInfo.Y_Quad3,'r','facealpha',0.1)
    patch(ArenaInfo.X_Quad4,ArenaInfo.Y_Quad4,'g','facealpha',0.1)
    
    % Create a directory to save analysis output
    AnalysisDir = replace(ExptName{ExptIdx}, 'Raw', 'Analysis') ;
    create_folder = mkdir(AnalysisDir) ;
    % Save ArenaInfo in individual experiment folder
    save([AnalysisDir, '/', 'ArenaInformation'], 'ArenaInfo') ; 
    % Save png showing Background Image and Quadrants
    filename = 'BackgroundImage_n_Quads' ;
    saveas(gcf, fullfile(AnalysisDir, filename), 'png');
end