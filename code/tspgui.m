function tspgui()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NIND=50;		% Number of individuals
MAXGEN=100;		% Maximum no. of generations
NVAR=26;		% No. of variables
PRECI=1;		% Precision of variables
ELITIST=0.05;    % percentage of the elite population
GGAP=1-ELITIST;		% Generation gap
STOP_PERCENTAGE=.95;    % percentage of equal fitness individuals for stopping
PR_CROSS=.95;     % probability of crossover
PR_MUT=.05;       % probability of mutation
LOCALLOOP=0;      % local loop removal
CROSSOVER = 'xalt_edges';  % default crossover operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read an existing population
% 1 -- to use the input file specified by the filename
% 0 -- click the cities yourself, which will be saved in the file called
%USE_FILE=0;
%FILENAME='data/cities.xy';
%if (USE_FILE==0)
%    % get the input cities
%    fg1 = figure(1);clf;
%    %subplot(2,2,2);
%    axis([0 1 0 1]);
%    title(NVAR);
%    hold on;
%    x=zeros(NVAR,1);y=zeros(NVAR,1);
%    for v=1:NVAR
%        [xi,yi]=ginput(1);
%        x(v)=xi;
%        y(v)=yi;
%        plot(xi,yi, 'ko','MarkerFaceColor','Black');
%        title(NVAR-v);
%    end
%    hold off;
%    set(fg1, 'Visible', 'off');
%    dlmwrite(FILENAME,[x y],'\t');
%else
%    XY=dlmread(FILENAME,'\t');
%    x=XY(:,1);
%    y=XY(:,2);
%end

% load the data sets
datasetslist = dir('datasets/');
datasets=cell( size(datasetslist,1)-2,1);datasets=cell( size(datasetslist,1)-2 ,1);
for i=1:size(datasets,1);
    datasets{i} = datasetslist(i+2).name;
end

% start with first dataset
data = load(['datasets/' datasets{1}]);
x=data(:,1)/max([data(:,1);data(:,2)]);y=data(:,2)/max([data(:,1);data(:,2)]);
NVAR=size(data,1);

datasets

disp("This shows the unscaled city-data of: "+datasets{1});
disp(data);
disp("This shows the scaled city-data of: "+datasets{1});
disp("X-data: ");
disp(x);
disp("Y-data: ");
disp(y);

crossoverTypes = {'xalt_edges','something_else'};

% initialise the user interface
fh = figure('Visible','off','Name','TSP Tool','Position',[0,0,1024,768]);
ah1 = axes('Parent',fh,'Position',[.1 .55 .4 .4]);
plot(x,y,'ko')
ah2 = axes('Parent',fh,'Position',[.55 .55 .4 .4]);

%PDP: The axes command below steals the focus. However we're now in the
%gui-constructing phase, so it doesn't really matter a lot.
%axes(ah2); %instead use:
set(0,'currentFigure',fh) 
set(fh,'currentAxes',ah2)

xlabel('Generation');
ylabel('Distance (Min. - Gem. - Max.)');
ah3 = axes('Parent',fh,'Position',[.1 .1 .4 .4]);

%PDP: The axes command below steals the focus. However we're now in the
%gui-constructing phase, so it doesn't really matter a lot.
%axes(ah3); %instead use:
set(0,'currentFigure',fh) 
set(fh,'currentAxes',ah3)

title('Histogram');
xlabel('Distance');
ylabel('Number');

ph = uipanel('Parent',fh,'Title','Settings','Position',[.55 .05 .45 .45]);
datasetpopuptxt = uicontrol(ph,'Style','text','String','Dataset','Position',[0 260 130 20]);
datasetpopup = uicontrol(ph,'Style','popupmenu','String',datasets,'Value',1,'Position',[130 260 130 20],'Callback',@datasetpopup_Callback);
llooppopuptxt = uicontrol(ph,'Style','text','String','Loop Detection','Position',[260 260 130 20]);
llooppopup = uicontrol(ph,'Style','popupmenu','String',{'off','on'},'Value',1,'Position',[390 260 50 20],'Callback',@llooppopup_Callback); 
ncitiesslidertxt = uicontrol(ph,'Style','text','String','# Cities','Position',[0 230 130 20]);
%ncitiesslider = uicontrol(ph,'Style','slider','Max',128,'Min',4,'Value',NVAR,'Sliderstep',[0.012 0.05],'Position',[130 230 150 20],'Callback',@ncitiesslider_Callback);
ncitiessliderv = uicontrol(ph,'Style','text','String',NVAR,'Position',[130 230 50 20]);
inputParamFilePathfield = uicontrol(ph,'Style','edit','Position',[180 230 245 20],'HorizontalAlignment','right','TooltipString','To use the parametersliders below, leave this field blank.');
inputParamFileBrowsebutton = uicontrol(ph,'Style','pushbutton','String','...','Position',[425 230 15 20],'Callback',@inputParamFileBrowsebutton_Callback,'TooltipString','Browse for *.csv-file for parameterinput. ');
nindslidertxt = uicontrol(ph,'Style','text','String','# Individuals','Position',[0 200 130 20]);
nindslider = uicontrol(ph,'Style','slider','Max',1000,'Min',10,'Value',NIND,'Sliderstep',[0.001 0.05],'Position',[130 200 150 20],'Callback',@nindslider_Callback);
nindsliderv = uicontrol(ph,'Style','text','String',NIND,'Position',[280 200 50 20]);
genslidertxt = uicontrol(ph,'Style','text','String','# Generations','Position',[0 170 130 20]);
genslider = uicontrol(ph,'Style','slider','Max',1000,'Min',10,'Value',MAXGEN,'Sliderstep',[0.001 0.05],'Position',[130 170 150 20],'Callback',@genslider_Callback);
gensliderv = uicontrol(ph,'Style','text','String',MAXGEN,'Position',[280 170 50 20]);
mutslidertxt = uicontrol(ph,'Style','text','String','Pr. Mutation','Position',[0 140 130 20]);
mutslider = uicontrol(ph,'Style','slider','Max',100,'Min',0,'Value',round(PR_MUT*100),'Sliderstep',[0.01 0.05],'Position',[130 140 150 20],'Callback',@mutslider_Callback);
mutsliderv = uicontrol(ph,'Style','text','String',round(PR_MUT*100),'Position',[280 140 50 20]);
crossslidertxt = uicontrol(ph,'Style','text','String','Pr. Crossover','Position',[0 110 130 20]);
crossslider = uicontrol(ph,'Style','slider','Max',100,'Min',0,'Value',round(PR_CROSS*100),'Sliderstep',[0.01 0.05],'Position',[130 110 150 20],'Callback',@crossslider_Callback);
crosssliderv = uicontrol(ph,'Style','text','String',round(PR_CROSS*100),'Position',[280 110 50 20]);
elitslidertxt = uicontrol(ph,'Style','text','String','% elite','Position',[0 80 130 20]);
elitslider = uicontrol(ph,'Style','slider','Max',100,'Min',0,'Value',round(ELITIST*100),'Sliderstep',[0.01 0.05],'Position',[130 80 150 20],'Callback',@elitslider_Callback);
elitsliderv = uicontrol(ph,'Style','text','String',round(ELITIST*100),'Position',[280 80 50 20]);
crossoverpopup = uicontrol(ph,'Style','popupmenu', 'String', crossoverTypes, 'Value',1,'Position',[10 50 130 20],'Callback',@crossoverpopup_Callback);
%inputbutton = uicontrol(ph,'Style','pushbutton','String','Input','Position',[55 10 70 30],'Callback',@inputbutton_Callback);
elapsedTimeLabeltxt = uicontrol(ph,'Style','text','String','Elapsed Time','Position',[140 50 90 15]);
elapsedTimetxt = uicontrol(ph,'Style','text','String','','Position',[230 50 225 15],'HorizontalAlignment','left');
runbutton = uicontrol(ph,'Style','pushbutton','String','START','Position',[0 10 50 30],'Callback',@runbutton_Callback);
autorunbutton = uicontrol(ph,'Style','pushbutton','String','AUTO_RUN','Position',[360 10 80 30],'Callback',@autorunbutton_Callback);
numberOfRunsfield = uicontrol(ph,'Style','edit','Position',[320 10 30 30]);
set(numberOfRunsfield,'string','30');
testNamefield = uicontrol(ph,'Style','edit','Position',[60 10 250 30],'TooltipString','Will be used as foldername, do not input special chars.');
set(testNamefield,'String','Enter_ShortGeneralName_For_TestSeries_(_Or_CamelCased)');


set(fh,'Visible','on');

    function datasetpopup_Callback(hObject,eventdata)
        dataset_value = get(hObject,'Value');
        dataset = datasets{dataset_value};
        % load the dataset
        data = load(['datasets/' dataset]);
        x=data(:,1)/max([data(:,1);data(:,2)]);y=data(:,2)/max([data(:,1);data(:,2)]);
        %x=data(:,1);y=data(:,2);
        NVAR=size(data,1);
        set(ncitiessliderv,'String',size(data,1));
        disp("This shows the unscaled city-data of: "+dataset);
        disp(data);
        disp("This shows the scaled city-data of: "+dataset);
        disp("X-data: ");
        disp(x);
        disp("Y-data: ");
        disp(y);
        %axes(ah1);
        set(0,'currentFigure',fh) 
        set(fh,'currentAxes',ah1)
        plot(x,y,'ko') 
        drawnow
    end

    function llooppopup_Callback(hObject,eventdata)
        lloop_value = get(hObject,'Value');
        if lloop_value==1
            LOCALLOOP = 0;
        else
            LOCALLOOP = 1;
        end
    end

    function ncitiesslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(ncitiessliderv,'String',slider_value);
        NVAR = round(slider_value);
    end

    function nindslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(nindsliderv,'String',slider_value);
        NIND = round(slider_value);
    end

    function genslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(gensliderv,'String',slider_value);
        MAXGEN = round(slider_value);
    end

    function mutslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(mutsliderv,'String',slider_value);
        PR_MUT = round(slider_value)/100;
    end

    function crossslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(crosssliderv,'String',slider_value);
        PR_CROSS = round(slider_value)/100;
    end

    function elitslider_Callback(hObject,eventdata)
        fslider_value = get(hObject,'Value');
        slider_value = round(fslider_value);
        set(hObject,'Value',slider_value);
        set(elitsliderv,'String',slider_value);
        ELITIST = round(slider_value)/100;
        GGAP = 1-ELITIST;
    end

    function crossoverpopup_Callback(hObject,eventdata)
        crossover_value = get(hObject,'Value');
        crossovers = get(hObject,'String');
        CROSSOVER = crossovers(crossover_value);
        CROSSOVER = CROSSOVER{1};
    end

    function runbutton_Callback(hObject,eventdata)
        %set(ncitiesslider, 'Visible','off');
        set(nindslider,'Visible','off');
        set(genslider,'Visible','off');
        set(mutslider,'Visible','off');
        set(crossslider,'Visible','off');
        set(elitslider,'Visible','off');
        initializeElapsedTime();
        run_ga('',fh,x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, ah1, ah2, ah3);
        updateElapsedTime();
        end_run();
    end

    function autorunbutton_Callback(hObject,eventdata)
        %set(ncitiesslider, 'Visible','off');
        
         set(nindslider,'Visible','off');
         set(genslider,'Visible','off');
         set(mutslider,'Visible','off');
         set(crossslider,'Visible','off');
         set(elitslider,'Visible','off');
        
        %Populate the inputParameterTable either via a set of parameters or
        %just the manual parameters.
        inputParameterTable = populateParamSetTable();
        
        %This timestamp will also be concatenated to the Test-series'
        %folder name.
        autorunTimestamp = datestr(now,'yyyymmdd_HHMMSS');
        
        for k = 1:size(inputParameterTable,1)
            curParameterSet = inputParameterTable(k,:)
            
            %Use curParameterSet to update the variables that are shown in
            %the gui and that will be used to run the algorithm. Hence, note: In
            %case of manual configuration of parameters (without reading from some inputParameters.csv-file), this step is
            %trivial because we adopted those parameters from there when storing in the inputParameterCell.
            if exist(get(inputParamFilePathfield,'String'), 'file') == 2 
                %In this case, the *.csv parameterinputfile was found, so
                %we need to update the parameters.
                updateCurrentParameters(curParameterSet);
            end
            
            %Create the needed folderstructure where all the .csv-files
            %will be written.
            pathOutputFolder = setupFileStructureTestSeries(k,curParameterSet,autorunTimestamp); %PrepareFolders for TestSeries.
            
            %Iterate within parameterset over the different runs requested.
            for iterator = 1:round(str2double(get(numberOfRunsfield, 'String')))
                fprintf('AUTO_RUN: Current run is %s out of %s.\n',num2str(iterator),num2str(get(numberOfRunsfield,'String')));
                
                %Prepare filepath to write the dataoutput to:
                dataOuputFilePath = fullfile(pathOutputFolder,sprintf('Dataoutput_Run_%s.csv',num2str(iterator)));
                
                %Since we're about ready to start the Genetic Alg, we'll
                %start the stopwatch:
                initializeElapsedTime();
                
                %run_ga() is the call to the underlying algorithm. Note that the returned Last_Minimum_Tourlength is not necessarily
                %the minimum tourlength, (f.e.: If there's no elitism, then the minimum might jump up again).
                [Last_Minimum_Tourlength, Last_Generation] = run_ga(dataOuputFilePath,fh,x, y, NIND, MAXGEN, NVAR, ELITIST, STOP_PERCENTAGE, PR_CROSS, PR_MUT, CROSSOVER, LOCALLOOP, ah1, ah2, ah3);
                
                %Stop the stopwatch:
                Elapsed_Time= updateElapsedTime();                
                
                %A temporary table is created to output the StatsData more
                %easily to StatsData_Run_%s.csv-file.
                statsTable = cell2table({Last_Generation,Last_Minimum_Tourlength,Elapsed_Time},'VariableNames',{'Last_Generation','Last_Minimum_Tourlength','Elapsed_Time'});
                
                %A method that writes the table, given the intended
                %filepath.
                writeStatstoCSV(fullfile(pathOutputFolder,sprintf('StatsData_Run_%s.csv',num2str(iterator))),statsTable);
            end
        end
        %Make the hidden sliders etc visible again.
        end_run();
    end

    function inputbutton_Callback(hObject,eventdata)
        [x y] = input_cities(NVAR);
        %axes(ah1);
        set(0,'currentFigure',fh) 
        set(fh,'currentAxes',ah1)
        plot(x,y,'ko')
        drawnow
    end

    function end_run()
        %set(ncitiesslider,'Visible','on');
        set(nindslider,'Visible','on');
        set(genslider,'Visible','on');
        set(mutslider,'Visible','on');
        set(crossslider,'Visible','on');
        set(elitslider,'Visible','on');
    end

    function initializeElapsedTime()
        set(elapsedTimetxt,'String',strcat({'Counting from: '},datestr(now,'yy/mm/dd HH:MM:SS')));
        tic; %Start/Reset timer
    end

    function elapsedTime=updateElapsedTime()
        elapsedTime = num2str(toc);
        set(elapsedTimetxt, 'String', strcat(elapsedTime,{' sec.'})); %toc retrieves the elapsed time since the last tic.
    end

    function inputParamFileBrowsebutton_Callback(hObject,eventdata)
        %uigetfile is a builtin filebrowser.
        [fileName, filePath] = uigetfile('*.csv','Specify path to *.csv-file with subsequent sets of inputparameters.');
        
        if isequal(fileName,0)
            %User selected Cancel, the inputParamFilePathfield should be
            %blank again.
            set(inputParamFilePathfield,'String','');
        else
            set(inputParamFilePathfield,'String',fullfile(filePath,fileName));
            set(inputParamFilePathfield,'HorizontalAlignment','right'); %So that you see the filename, rather than the less interesting common portion of the path.
            drawnow;
        end        
    end

    function resultTable = populateParamSetTable()
        
        if exist(get(inputParamFilePathfield,'String'), 'file') == 2 
            %In this case, the *.csv parameterinputfile was found.
            
            %Now the specified *.csv-file will be read:
            resultTable = readtable(get(inputParamFilePathfield,'String'),'Format','%d%s%s%d%d%d%d%d%s%s','Delimiter',',','ReadVariableNames',true);
            
            disp('Inputparameterdata read and stored as table:');
            disp(resultTable);
        else
            %Extract the propertyvalues from the sliders and other
            %properties from the panel, because no (valid) *.csv-file was given.
            
            %Convert dataset & Loop Detection parameters to their string
            %representation, to be consistent with reading them from file.
            %I chose to read them in as text from that file for the
            %human-readibility & some numeric values behind them are a bit 
            %contraintuitive f.e. LD = 1(=on), while LD = %2(=off).
            datasetValue = get(datasetpopup,'Value');
            dataset = datasets{datasetValue};
            
            loopDetectValue = get(llooppopup,'Value');
            loopDetectset = {'off','on'};
            loopDetection = loopDetectset{loopDetectValue};
            
            %Ask user for custom description for this set of parameters.
            %This descriptions will be added to the parameter information
            %that will be stored as .csv-file inside the parameterset-folder.
                prompt = {'(Optionally) enter a more extensive parameterset-description here, for what has been manually configured:'};
                dialogtitle = 'Manual Parameterset Description';
                dims = [8 75];
                definput = {'Enter your text here. (Do not use comma or semicolon.)'};
            manualParamsetDescription = inputdlg(prompt,dialogtitle,dims,definput);
            
            %Add manually configured data to the table.
                Iterations = [round(str2double(get(numberOfRunsfield, 'String')))];
                Dataset={dataset};
                Loop_Detection={loopDetection};
                Nmbr_Individuals = [NIND];
                Nmbr_Generations = [MAXGEN];
                Prob_Mutation = [PR_MUT];
                Prob_Crossover = [PR_CROSS];
                Pct_Elitism = [ELITIST];
                Crossover_Type = {CROSSOVER};
                Cust_Paramset_Description = manualParamsetDescription;
            resultTable=table(Iterations,Dataset,Loop_Detection,Nmbr_Individuals,Nmbr_Generations,Prob_Mutation,Prob_Crossover,Pct_Elitism,Crossover_Type,Cust_Paramset_Description);
            
            disp('Manually configured parameters stored as table:');
            disp(resultTable);
        end
    end

    %Create directory where to write the testresults:
    %I chose to create this directory next to our gitrepository, so
    %that our tests don't trigger pending changes & therefore aren't checked in.
    function folderName = setupFileStructureTestSeries(indexOfParameterset,currentParameterSet, autoRunTimestamp)
        
        %Filepaths created in this program are relative to the current
        %working directory, which should be the 'code'-folder.
        currentFolder = pwd;
        indcs = strfind(currentFolder,filesep);
        
        %Find the grandparentfolder two levels up, to be outside of the
        %git-scope.
        grandParentFolder = currentFolder(1:indcs(end-1)-1);
        %disp(grandParentFolder);
        
        %Deduce name for parameterset-folder based on the the
        %inputparameters. Also, a ordinal number is added as prefix.
        paramSetSubfolder = convertParamSetToSubfolderName(indexOfParameterset);
        
        %Inside the TSP_TestOuput-folder, I create a folder for the
        %testseries for which a global name was specified on the GUI, to
        %that name, I append the timestamp of creation to make sure that we
        %have unique names.
        folderName = fullfile(grandParentFolder,'TSP_TestOuput',strcat(get(testNamefield,'String'),'_',autoRunTimestamp),paramSetSubfolder);
        
        if exist(folderName, 'dir') ~= 7 
            %When the path to this dir doesn't exist (so doesn't equal 7),
            %it will be created.
            mkdir(folderName)
        end
        
        %For now, we can already write a copy of the currentparameterset to that
        %folder as a InputParameters.csv. It also links the parameterset's
        %short description text to the right subfolder.
        writetable(currentParameterSet,fullfile(folderName,'InputParameters.csv'),'WriteVariableNames',true,'Delimiter',',')        
    end

    function paramSetSubfolder = convertParamSetToSubfolderName(indexOfParameterset)
        %Deduce subfolder name for current parameterset based on
        %the actual parametervalues. Also, a ordinal number
        %(indexOfParameterset) is added as prefix.
        paramSetSubfolder = sprintf('%d_I%sD%dLD%dNI%dNG%dPM%sPC%sPE%sCT%d',indexOfParameterset,get(numberOfRunsfield,'String'),NVAR,LOCALLOOP,NIND,MAXGEN,get(mutsliderv,'String'),get(crosssliderv,'String'),get(elitsliderv,'String'),get(crossoverpopup,'Value'));
    end

    function updateCurrentParameters(curParameterSet)
        
        disp('Updating current parameters to values below:');
        disp('============================================');
        
        %Iterations
        disp(curParameterSet(1,{'Iterations'}));
        cellIterations = table2cell(curParameterSet(1,{'Iterations'}));
        set(numberOfRunsfield,'String',(cellIterations{1}));
        
        %Dataset
        disp(curParameterSet(1,{'Dataset'}));
        cellDatasetValue = table2cell(curParameterSet(1,{'Dataset'}));
        dataSetIndex = find(strcmp(datasets,cellDatasetValue));
        %disp(datasets);
        %disp(dataSetIndex);
        set(datasetpopup,'Value',dataSetIndex);
        emptyEventdata = {""}; %By triggering the buttonhandler for that dropdown, we can trigger the gui to update.
        datasetpopup_Callback(datasetpopup,emptyEventdata);
        
        %Loop_Detection
        disp(curParameterSet(1,{'Loop_Detection'}));
        cellLoopDetection = table2cell(curParameterSet(1,{'Loop_Detection'}));
        loopDetectionIndex = find(strcmp({'off','on'},cellLoopDetection));
        set(llooppopup,'Value',loopDetectionIndex);
        llooppopup_Callback(llooppopup,emptyEventdata);
        
        %Nmbr_Individuals
        disp(curParameterSet(1,{'Nmbr_Individuals'}));
        cellnmbrIndividuals = table2cell(curParameterSet(1,{'Nmbr_Individuals'}));
        set(nindslider,'Value',(cellnmbrIndividuals{1}));
        nindslider_Callback(nindslider,emptyEventdata);
        
        %Nmbr_Generations
        disp(curParameterSet(1,{'Nmbr_Generations'}));
        cellnmbrGenerations = table2cell(curParameterSet(1,{'Nmbr_Generations'}));
        set(genslider,'Value',(cellnmbrGenerations{1}));
        genslider_Callback(genslider,emptyEventdata)
        
        %Prob_Mutation
        disp(curParameterSet(1,{'Prob_Mutation'}));
        cellprobMutations = table2cell(curParameterSet(1,{'Prob_Mutation'}));
        set(mutslider,'Value',(cellprobMutations{1}));
        mutslider_Callback(mutslider,emptyEventdata)
        
        %Prob_Crossover
        disp(curParameterSet(1,{'Prob_Crossover'}));
        cellprobCrossover = table2cell(curParameterSet(1,{'Prob_Crossover'}));
        set(crossslider,'Value',(cellprobCrossover{1}));
        crossslider_Callback(crossslider,emptyEventdata)
        
        %Pct_Elitism
        disp(curParameterSet(1,{'Pct_Elitism'}));
        cellpctElitism = table2cell(curParameterSet(1,{'Pct_Elitism'}));
        set(elitslider,'Value',(cellpctElitism{1}));
        elitslider_Callback(elitslider,emptyEventdata)
        
        %Crossover_Type
        disp(curParameterSet(1,{'Crossover_Type'}));
        cellcrossoverType = table2cell(curParameterSet(1,{'Crossover_Type'}));
        crossoverTypeIndex = find(strcmp(crossoverTypes,cellcrossoverType));
        set(crossoverpopup,'Value',crossoverTypeIndex);
        crossoverpopup_Callback(crossoverpopup,emptyEventdata);
        
        %To be extended when we have more properties.
    end

    function writeStatstoCSV(statsDataFilePath,statsTable)
        %Writes the statsTable to the specified *.csv-file:
        writetable(statsTable,statsDataFilePath,'WriteVariableNames',true,'Delimiter',','); 
    end
end