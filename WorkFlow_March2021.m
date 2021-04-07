% Analyzing circular arena videos:
% 
% Clone the following repositories from Github
% CircularArena
% CircularArenaTurner
% Utility
% ufmf stuff
% Add to the Matlab path (Home tab -> Set Path).  Remove any directories
% there with .git in the name.  
% Edit whichever ArenaSetup you want to use so that it points to the
% directory where you keep your xls data lists.  That's line 23:
% >> cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')


% ArenaInfo = ArenaSetupAutomatic() ;
%     Determines ArenaEdge and calculates BackgroundImage of arena separately 
%     for each folder i.e. each experiment.  Both steps are done
%     automatically - the result is displayed as well as saved as
%     Background_n_Quadrants.png so that you have visual quality control on
%     how well these things are calculated.  
%     If the folder has several Test trials i.e. several 'movie_Test*.ufmf' 
%     files then it will just calculate ArenaEdge and BackgroundImage on
%     the first video 

% ArenaInfo = ArenaSetupInteractive() ;
%     Same as above but you have to position the circular ROI to mark the
%     ArenaEdge.  One positioned, double click to move to the next
%     experiment.  
% 

% FlySpotter.m
%     Locates flies centroids and returns 
%     Test.Frame.FlySpots.Centroid 
%       Where Test(i) indexes the Test trial.  If you only have one Test
%       trial this is just Test(1)
% 
% FlyCounter.m
%     Counts flies in each quadrant and returns
%     FlyCount.mat which contains TestTrial.FlyCount
%     Where Test(i) indexes the Test trial and FlyCount(i,j) indexes the
%     frame - i and the quadrant - j.  
%     To retrieve the number of flies on Test trial 1 & frame 87 & quadrant
%     4 type: TestTrial(1).FlyCount(87,4);

% FlyCountPlotter.m
%     Plots the number of flies in each quadrant over time.  
%     Q1&Q3 are shades of red Q2&Q4 are shades of blue
%     **NOT CURRENTLY ESTABLISHED HOW THESE MAP ONTO THE PHYSICAL ARENA**