function [return_data] = send2remote(localfunc,struct,varargin)
%% Laurence Jackson, BME, KCL, 2018
% 
% Code for exporting local code and workspace data to remote system and returning
% function output back to local workspace. Useful if remote has much higher parallel 
% capacity than local mahcine
% 
% note: currently only works with functions that return a single output
% 
% inputs:
%   localfunc   = local function to run : e.g. 'your_func'
%   struct      = structure contining all localfun input variables
%                 IMPORTANT: structure fields must have same names as
%                 function inputs - see example below

% e.g. To run your_func(img,vect)
%   instruct.img = imagedata; 
%   instruct.vect = vector;
%   output = send2remote('your_func',instruct)

%% main
tic

% SSH/SCP bits
if nargin > 2
    for vi = 1:length(nargin)
        if strcmpi(varargin{vi}, 'ssh')
            load(varargin{vi+1})
        end
    end
else
    load('ssh_default.mat'); 
end

disp(['Running ' localfunc ' remotely on ' sshhost]);
% save data struct
disp('    --parsing inputs');
save('temp_struct.mat','-struct','struct','-v7.3');
feelds = fieldnames(struct);
varstring = feelds{1};
for fld = 2:length(fieldnames(struct))
    varstring = [varstring ', ' feelds{fld}];
end

% send local func to remote with dependencies 
[~, mFileName, ~] = fileparts(localfunc);
files  = matlab.codetools.requiredFilesAndProducts(localfunc);
files = unique(files);

% send most current version of code
disp('    --sending code');
ssh2_simple_command(sshhost,USERNAME,PASSWORD,'mkdir -p TEMP_remote'); % create remote dirs
remotePath = '~/TEMP_remote';

% send files
for fl = 1:length(files)
    [ahhh_tmp, mFileName_tmp, dontcare_tmp] = fileparts(files{fl});
    at_loc = strfind(files(fl),'@');
    if ~isempty(cell2mat(at_loc))
        remotePath = ['~/TEMP_remote/',ahhh_tmp(cell2mat(at_loc):end)];
        % Make a new directory for this class method.
        ssh2_simple_command(sshhost,USERNAME,PASSWORD,sprintf('mkdir -p TEMP_remote/%s',ahhh_tmp(cell2mat(at_loc):end))); % create remote dirs
    else
        remotePath = '~/TEMP_remote';
    end
    scp_simple_put(sshhost,USERNAME,PASSWORD,[mFileName_tmp dontcare_tmp],remotePath,ahhh_tmp); % send slices to remote
end

% send data struct
disp('    --sending data');
scp_simple_put(sshhost,USERNAME,PASSWORD,'temp_struct.mat',remotePath); % send struct to remote

% run matlab command
matlab_generic_command = ...
    [matlabRunCmd ... %     ['screen;' matlabRunCmd ...
    '"try addpath(''TEMP_remote'');  '... func1: add temp to path
    'load(''/TEMP_remote/temp_struct'');' ...func2: load workspace variables
    'func_return = ' mFileName '(' varstring ');' ... func3: run function
    ' save(''~/TEMP_remote/return_data'',''func_return'');'...func4: save output
    'catch;end;quit"' ];
disp(['    --running ' localfunc '(' varstring ')']);
ssh2_simple_command(sshhost,USERNAME,PASSWORD,matlab_generic_command);

%  send back to local
disp('    --receiving data');
scp_simple_get(sshhost,USERNAME,PASSWORD,'return_data.mat',[],remotePath); % collect processed slices

%  delete remote junk
disp('    --deleting temp files');
ssh2_simple_command(sshhost,USERNAME,PASSWORD,'rm -r TEMP_remote'); % create remote dirs

load('return_data.mat','func_return');
return_data = func_return;

toc
end