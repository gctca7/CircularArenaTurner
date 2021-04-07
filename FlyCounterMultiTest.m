% Splits the arena into 4 quadrants and counts number FlySpots in each
% Inputs:
% ArenaInformation      From ArenaSetup - located in Daily Experiment
%                       Folder
% ExptName              From spreadsheet user selects

% Change directory to folder containing experiment lists
% (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);

for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    load ArenaInformation.mat
    load FlySpots.mat
    for TestIdx = 1:length(Test)
        % Pre-Allocate matrix before running for loop        
        TestTrial(TestIdx).FlyCount = zeros(length(Test(TestIdx).Frame),4) ;         
        for FrameIdx = 1:length(Test(TestIdx).Frame)
            z = cat(1,Test(TestIdx).Frame(FrameIdx).FlySpots.Centroid) ;
            X_Locs = z(:,1) ;
            Y_Locs = z(:,2) ;
            
            inQuad1 = inpolygon (X_Locs,Y_Locs,ArenaInfo.X_Quad1,ArenaInfo.Y_Quad1) ;
            inQuad2 = inpolygon (X_Locs,Y_Locs,ArenaInfo.X_Quad2,ArenaInfo.Y_Quad2) ;
            inQuad3 = inpolygon (X_Locs,Y_Locs,ArenaInfo.X_Quad3,ArenaInfo.Y_Quad3) ;
            inQuad4 = inpolygon (X_Locs,Y_Locs,ArenaInfo.X_Quad4,ArenaInfo.Y_Quad4) ;
            
            TestTrial(TestIdx).FlyCount(FrameIdx,1) = numel(X_Locs(inQuad1)) ;
            TestTrial(TestIdx).FlyCount(FrameIdx,2) = numel(X_Locs(inQuad2)) ;
            TestTrial(TestIdx).FlyCount(FrameIdx,3) = numel(X_Locs(inQuad3)) ;
            TestTrial(TestIdx).FlyCount(FrameIdx,4) = numel(X_Locs(inQuad4)) ;
        end
    end
    save FlyCounts.mat TestTrial
    disp(['Quadants counted expt ' num2str(ExptIdx) ' of ' num2str(length(ExptName))])
    
    % CD back up one level
    %     cd ..
end