%% Workflow
modules = {'reproa_fromnifti_structural';
           'reproa_fromnifti_fmri';
           'reproa_timeseriesqc_fmri';
           'reproa_realign';
           'reproa_coregextended';
           'reproa_segment';
           'reproa_normwrite_fmri';
           'reproa_smooth_fmri';
           'reproa_timeseriesqc_fmri'};
modules{end+1,2} = {'_fingerfootlips' 'fingerfootlips' {'reproa_firstlevelmodel';
                                                        'reproa_firstlevelcontrasts';
                                                        'reproa_firstlevelthreshold'};
                    '_linebisection' 'linebisection' {'reproa_firstlevelmodel';
                                                      'reproa_firstlevelcontrasts';
                                                      'reproa_firstlevelthreshold'}};
rap = reproaWorkflow(modules);

%% Data
rap.directoryconventions.rawdatadir = 'D:\Data\ds114_test1';
rap.tasksettings.reproa_fromnifti_fmri.numdummies = 1;
rap.acqdetails.input.correctEVfordummies = 1;
rap = processBIDS(rap);

%% Output
rap.acqdetails.root = 'D:\Analyses';
rap.directoryconventions.analysisid = 'ds114_test1';

% Computing
rap.directoryconventions.poolprofile = 'local_PS';
rap.options.wheretoprocess = 'batch';
rap.options.parallelresources.numberofworkers = 4;
rap.options.parallelresources.memory = 4;

%% Customise workflow
rap.acqdetails.input.correctEVfordummies = 0;

rap.tasksettings.reproa_segment.normalisation.affreg = '';

rap.tasksettings.reproa_smooth_fmri.FWHM = 5;

for b = 1:2 % braches
    rap.tasksettings.reproa_firstlevelmodel(b).xBF.UNITS = 'secs';
    rap.tasksettings.reproa_firstlevelmodel(b).includemovementparameters = [1 1 0; 1 1 0];

    rap.tasksettings.reproa_firstlevelthreshold(b).threshold.correction = 'none';
    rap.tasksettings.reproa_firstlevelthreshold(b).threshold.p = 0.001;
    rap.tasksettings.reproa_firstlevelthreshold(b).threshold.extent = 'FWE:0.05';
end

rap = addContrast(rap,'reproa_firstlevelcontrasts_00001','*','*',[1 0 0],'Loc_Finger','T');
rap = addContrast(rap,'reproa_firstlevelcontrasts_00001','*','*',[0 1 0],'Loc_Foot','T');
rap = addContrast(rap,'reproa_firstlevelcontrasts_00001','*','*',[0 0 1],'Loc_Lips','T');

rap = addContrast(rap,'reproa_firstlevelcontrasts_00002','*','*',[1  0  0 -1  0],'Task_Resp-NoResp','T');
rap = addContrast(rap,'reproa_firstlevelcontrasts_00002','*','*',[0  0 -1  0  1],'Control_Resp-NoResp','T');


%% Execute workflow
processWorkflow(rap);

reportWorkflow(rap);
