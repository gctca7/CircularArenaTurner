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
% - If you made each binary object a different color and did a t-projection you could have every flies tracks plotted
% - Flies are counted by thresholding and binarizing in Markflies.m.  We
% need quality control to make sure the thresholding is correct.
% I could return the size of the binary objects and figure out how to parse things that are too big for a single fly
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
    
    % Load ArenaInformation from ArenaSetup()
    load ('ArenaInformation.mat')
    ArenaEdge       = ArenaInfo.Mask ;
    BackgroundImage = ArenaInfo.BackgroundImage ;
    for TestIdx = 1:length(video)
        Header      = ufmf_read_header(video(TestIdx).name);
        FrameRate   = round(1/mean(diff(Header.timestamps))) ;
        TotalFrames = Header.nframes - rem(Header.nframes, FrameRate); % Round the number of frames to the nearest second
        
        disp(['Marking flies for ' ExptName{ExptIdx}])
        for FrameIdx = 1:TotalFrames
            tmp = ufmf_read_frame(Header, FrameIdx) ;
            Test(TestIdx).Frame(FrameIdx).FlySpots = MarkFlies(tmp, BackgroundImage, ArenaEdge, MinObjectArea) ;
        end
    end
    
     % Create a directory to save analysis output
    AnalysisDir = replace(ExptName{ExptIdx}, 'Raw', 'Analysis') ;
    % Save output from MarkFlies in the Analysis folder
    save([AnalysisDir, '/', 'FlySpots'], 'Test') ; 
end