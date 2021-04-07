%% Locate each fly in the circular arena
% For each Experiment (i.e. each directory that has a Test*.ufmf video in
% it) this returns Frame.FlySpots which has the fields:
% .Centroid         Fly centroids
% .EquivDiameter    Diameter of a circle with the same area as the region
% .FilledImage      Image the same size as the bounding box of the region

% Saves as FlySpots.mat into a directory above the ExptDay directory i.e. at same level as RawData directory

% NOTES:
% The last two fields could be useful for making trajectory movies but currently
% we only use .Centroid

% IMPROVEMENTS:
% If you made each binary object a different color and did a t-projection you could have every flies tracks plotted
% Flies are counted by thresholding and binarizing in mark_flies.m.  We
% need quality control to make sure the thresholding is correct.
% Have an alert for frames where total # flies changes.  Flies dropping from one frame not a problem but dropping for all remaining frames undesireable
% We could return the size of the binary objects and figure out how to parse things that are too big for a single fly
% X Don't display every frame analyzed - do it every framerate*60 for 1
% minute chunks
% X Average several frames to get a background to subtract
% X Why load movie in little chunks - what does it help?
% >> First work through all Cam0 files then all Cam1.  That way you don't have to load new masks every loop
% Preallocate Frame structure for speed

%% Set parameters for fly spot identification
MinObjectArea = 50 ;            % Minimum area of a fly (in pixels)

%% Change directory to folder containing experiment lists (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);

%%
for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    
    video = dir('movie_Test*.ufmf') ;
    % SKIP if folder does not contain a Test video file or if folder contains analyzed tag
    % To include a folder manually delete analyzed.txt from the directory
    %     analyzed_file = [ExptName, '/', 'analyzed.txt'];
    %     if (size(video, 1) == 0) || (exist(analyzed_file, 'file') ~= 0)
    %         disp(['FlySpotter run previously - Skipping subFolder ' num2str(ExptIdx) ' of ' num2str(length(subFolders))])
    %         % CD back up one level to day's directory
    %         cd ..
    %         continue
    %     end
    
    % Load ArenaInformation from ArenaSetup()
    load ('ArenaInformation.mat')
    ArenaEdge       = ArenaInfo.Mask ;
    BackgroundImage = ArenaInfo.BackgroundImage ;
    for TestIdx = 1:length(video)
        Header      = ufmf_read_header(video(TestIdx).name);
        FrameRate   = round(1/mean(diff(Header.timestamps))) ;
        TotalFrames = Header.nframes - rem(Header.nframes, FrameRate); % Round the number of frames to the nearest second
        
 %     disp(['Marking Flies for ' ExptName])
%         disp(['Marking Flies for Expt ' num2str(ExptIdx) ' of ' num2str(length(ExptName))])
        disp(['Marking flies for ' ExptName{ExptIdx}])
        for FrameIdx = 1:TotalFrames
            tmp = ufmf_read_frame(Header, FrameIdx) ;
            Test(TestIdx).Frame(FrameIdx).FlySpots = MarkFlies(tmp, BackgroundImage, ArenaEdge, MinObjectArea) ;
        end
    end
    
    
    % Save output from MarkFlies in the raw data folder
    save('FlySpots.mat', 'Test') ;
    
    %     % Tag the folder containing the ufmf video with a file to indicate the data inside has been analyzed
    %     % Note that you are still in the Behavior_Raw directory
    %     file = fopen('analyzed.txt', 'w');
    %     fclose(file);
    %
    %     % Create a directory to save output from MarkFlies
    %     AnalysisDir = replace(ExptDir, 'Raw', 'Analysis') ;
    %     AnalysisDir = ([AnalysisDir,'/' ExptName]) ;
    %     create_folder = mkdir(AnalysisDir) ;
    %     save([AnalysisDir, '/', 'FlySpots'], 'Frame') ;
    %     toc
    %     % CD up one level to day's directory - still in Behavior_Raw
    %     cd ..
end