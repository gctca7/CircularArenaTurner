%% Change directory to folder containing experiment lists (or just start on Desktop)
cd('/Users/glennturner/Dropbox (HHMI)/Data/BehaviorDataKarenHibbard/Behavior_DataLists')
% User selects spreadsheet containing experiment names
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off') ;
% Return cell array where each cell contains full directory path to folders containing flycounts
[~, ExptName, ~] = xlsread([PathName, FileName]);
ScreenSizePixels = get(0,'screensize') ;

for ExptIdx = 1:length(ExptName)
    cd (ExptName{ExptIdx})
    load('FlyCounts.mat') % returns TestTrial (Test Trial # . Frames . Quadrants)
    % Create a directory to save analysis output
    AnalysisDir = replace(ExptName{ExptIdx}, 'Raw', 'Analysis') ;
    
    for TestIdx = 1:length(TestTrial)
        TotalFlyCount = sum(TestTrial(TestIdx).FlyCount,2) ;
        time = [1/30:1/30:length(TestTrial(TestIdx).FlyCount)/30] ;     % Assumes 30 fps video
        
        figure('position',[100 1500 ScreenSizePixels(3)*.8 ScreenSizePixels(4)*.3]) ;
        plot(time,TestTrial(TestIdx).FlyCount(:,1),'color',[1 .1 .1],'linewidth',2) ; hold on ;
        plot(time,TestTrial(TestIdx).FlyCount(:,2),'color',[.1 .1 1],'linewidth',2) ; hold on ;
        plot(time,TestTrial(TestIdx).FlyCount(:,3),'color',[.55 .1 .1],'linewidth',2) ; hold on ;
        plot(time,TestTrial(TestIdx).FlyCount(:,4),'color',[.1 .1 .55],'linewidth',2) ; hold on ;
        plot(time,TotalFlyCount,'color',[0. 0. 0.],'linewidth',1) ; hold off
        axis tight
               
        % Save output from MarkFlies in the Analysis folder
        filename = (['Trial ' num2str(TestIdx) ' FlyCounts']) ;
        saveas(gcf, fullfile(AnalysisDir, filename), 'png');
        close
    end
end

% %%  If you've loaded FlyCounts.mat directly just plot with this:
% for TestIdx = 1:length(TestTrial)
%     TotalFlyCount = sum(TestTrial(TestIdx).FlyCount,2) ;
%     time = [1/30:1/30:length(TestTrial(TestIdx).FlyCount)/30] ;     % Assumes 30 fps video
%     ScreenSizePixels = get(0,'screensize') ;
%     
%     figure('position',[100 1500 ScreenSizePixels(3)*.8 ScreenSizePixels(4)*.3]) ;
%     plot(time,TestTrial(TestIdx).FlyCount(:,1),'color',[1 .1 .1],'linewidth',2) ; hold on ;
%     plot(time,TestTrial(TestIdx).FlyCount(:,2),'color',[.1 .1 1],'linewidth',2) ; hold on ;
%     plot(time,TestTrial(TestIdx).FlyCount(:,3),'color',[.55 .1 .1],'linewidth',2) ; hold on ;
%     plot(time,TestTrial(TestIdx).FlyCount(:,4),'color',[.1 .1 .55],'linewidth',2) ; hold on ;
%     plot(time,TotalFlyCount,'color',[0. 0. 0.],'linewidth',1) ; hold off
%     axis tight
% end
