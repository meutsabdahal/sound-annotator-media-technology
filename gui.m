function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 01-May-2021 21:34:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% variable declarations
global orginalTrack;
global orginalTrackLoaded;
global orginalTrackPaused;
global orginalTrackData;
global orginalTrackSound;

global addedTrack;
global addedTrackLoaded;
global addedTrackPaused;
global addedTrackData;
global addedTrackSound;

global sampleRate;
global speedTrack;

% assiging values to declared variable
orginalTrack = false;
orginalTrackLoaded = false;
orginalTrackPaused = false;
orginalTrackData = 0;

addedTrack = false;
addedTrackLoaded = false;
addedTrackPaused = false;
addedTrackData = 0;

sampleRate = 48000;
speedTrack = false;

% function to import the track
function importTrack(handles, track)
    global sampleRate;
    global speedTrack;

    %opens the file explorer to brower the track
    [trackName, trackPath] = uigetfile( ...
    {'*.wav;*.mp3',...
    'Audio Files (*.wav,*.mp3)'; ...
    '*wav', 'WAV Files(*.wav)';...
    '*mp3', 'MP3 Files(*.mp3)';},...
    'Select an audio file');

    if trackName
        [snd, FS] = audioread(fullfile(trackPath, trackName));

        if track == 1
            global orginalTrackData;
            global orginalTrackSound;
            global orginalTrack;
            global orginalTrackPaused;
            global orginalTrackLoaded;

            orginalTrackLoaded = true;
            orginalTrack = false;
            orginalTrackPaused = false;

            if FS ~= sampleRate
                [X, Y] = rat(sampleRate/FS);
                orginalTrackData = resample(snd, X, Y);
            else
                orginalTrackData = snd;
            end
            orginalTrackSound = audioplayer(orginalTrackData, sampleRate);
            set(orginalTrackSound, 'TimerFcn', {@trackTimer, track, handles}, 'TimerPeriod',0.1,'Stop',{@endTrack, track, handles});
            set(handles.orginalTrackInvert, 'Value', 0);
            visualiation(orginalTrackData, sampleRate,handles, track);

        elseif track ==2
            global addedTrackData;
            global addedTrackSound;
            global addedTrack;
            global addedTrackPaused;
            global addedTrackLoaded;

            addedTrackLoaded = true;
            addedTrack = false;
            addedTrackPaused = false;

            if FS ~= sampleRate
                [X, Y] = rat(sampleRate/FS);
                addedTrackData = resample(snd, X, Y);
            else
                addedTrackData = snd;
            end
            addedTrackSound = audioplayer(addedTrackData, sampleRate);
            set(addedTrackSound, 'TimerFcn', {@trackTimer, track, handles}, 'TimerPeriod',0.1,'Stop',{@endTrack, track, handles});
            set(handles.addedTrackInvert, 'Value', 0);
            visualiation(addedTrackData, sampleRate,handles, track);
        end
    end
  

% function to play a track
function playTrack(track)
    global orginalTrack;
    global orginalTrackLoaded;
    global orginalTrackSound;
    global orginalTrackPaused;

    global addedTrack;
    global addedTrackLoaded;
    global addedTrackSound;
    global addedTrackPaused;

    if track == 1
        if ~orginalTrack && orginalTrackLoaded
            resume(orginalTrackSound);
            orginalTrack = true;
            orginalTrackPaused = false;
        end
    elseif track == 2
        if ~addedTrack && addedTrackLoaded
            resume(addedTrackSound);
            addedTrack = true;
            addedTrackPaused = false;
        end
    end

% function to puase the track
function pauseTrack(track)
    if track ==1
        global orginalTrackSound;
        global orginalTrack;
        global orginalTrackPaused;

        orginalTrack = false;
        orginalTrackPaused = true;
        pause(orginalTrackSound);
    elseif track == 2
        global addedTrackSound;
        global addedTrack;
        global addedTrackPaused;

        addedTrack = false;
        addedTrackPaused = true;
        pause(addedTrackSound);
    end

%function to stop the playing tarck
function stopTrack(handles, track)
    if track == 1
        global orginalTrackLoaded;
        global orginalTrackSound;
        global originalTrack;
        global originalTrackPaused;

        if orginalTrackLoaded
            originalTrack = false;
            originalTrackPaused = false;
            stop(orginalTrackSound);
        end

    elseif track == 2
        global addedTrackLoaded;
        global addedTrackSound;
        global addedTrack;
        global addedTrackPaused;

        if addedTrackLoaded
            addedTrack = false;
            addedTrackPaused = false;
            stop(addedTrackSound);
        end

    end

function endTrack(~,~,track, handles)
    global orginalTrack;
    global addedTrack;

    if track == 1
        if orginalTrack == true
            orginalTrack = false;
            set(handles.orginalTrackSlider, 'Value', get(handles.orginalTrackSlider,'Min'));
            if get(handles.orginalTrackLoop, 'Value') == true;
                playTrack(1);
            end
        end
    elseif track == 2
            if addedTrack == true
                addedTrack = false;
                set(handles.addedTrackSlider, 'Value', get(handles.addedTrackSlider,'Min'));
                if get(handles.addedTrackLoop, 'Value') == true;
                    playTrack(2);
                end
            end
    end

function visualiation(snd, FS, handles, track)
    timer = round((1/FS) * length(snd),1);
    if track == 1
        axis = handles.orginalAxes;
        slider = handles.orginalTrackSlider;
        set(handles.insertTrackSlider, 'Max', timer);
        set(handles.insertTrackSlider, 'Value', 0);
        set(handles.insertTrackSlider, 'Min', 0);

    elseif track == 2
        axis = handles.addedAxes;
        slider = handles.addedTrackSlider;
    end
    time = linspace(0, timer, length(snd));
    plot(axis, time, snd);
    set(slider, 'Max', timer);
    set(slider, 'Value', 0);
    set(slider, 'Min', 0);

function trackTimer(~,~,track, handles)
    
    global sampleRate;
    if track == 1
        global orginalTrackSound;
        global orginalTrackData;
        
        slider = handles.orginalTrackSlider;
        trackTimer = handles.orginalTrackTimer;
        timer = round(orginalTrackSound.CurrentSample/sampleRate, 1);
        snd = orginalTrackData;
        
    elseif track == 2
        global addedTrackSound;
        global addedTrackData;
        
        slider = handles.addedTrackSlider;
        trackTimer = handles.addedTrackTimer;
        timer = round(addedTrackSound.CurrentSample/sampleRate, 1);
        snd = addedTrackData;
    end
    finalTimer = get(slider,'Max');
    
    if timer < finalTimer
        set(slider, 'Value', timer);
        set(trackTimer, 'String', timer);
        
    else
        set(slider, 'Value', finalTimer);
        set(trackTimer, 'String', finalTimer); 
        visualiation(snd, sampleRate, handles, track);
    end
    
function invertTrack(handles, track)
    global orginalTrackLoaded;
    global addedTrackLoaded;
    global sampleRate;
    global speedTrack;
    
    stopTrack(handles, track);
    
    if track == 1 && orginalTrackLoaded
        global orginalTrackData;
        global orginalTrackSound;
        
        orginalTrackData = flipud(orginalTrackData);
        orginalTrackSound = audioplayer(orginalTrackData, sampleRate);
        set(orginalTrackSound, 'TimerFcn',{@trackTimer, track, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@endTrack, track, handles});
        set(handles.orginalTrackTimer, 'String', round(handles.orginalTrackTimer.Value, 1));
        visualiation(orginalTrackData, sampleRate, handles, 1);
        
    elseif track == 2 && addedTrackLoaded
        global addedTrackData;
        global addedTrackSound;
        
        addedTrackData = flipud(addedTrackData);
        addedTrackSound = audioplayer(addedTrackData, sampleRate);
        set(addedTrackSound, 'TimerFcn',{@trackTimer, track, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@endTrack, track, handles});
        set(handles.addedTrackTimer, 'String', round(handles.orginalTrackTimer.Value, 1));
        visualiation(addedTrackData, sampleRate, handles, 2);
    end
    if (speedTrack)
        resetSpeed(handles);
    end
    
function changeTrackSpeed(handles, multiplier)
    global sampleRate;
    global orginalTrackData;
    global addedTrackData;
    global orginalTrackSound;
    global addedTrackSound;
    global orginalTrack;
    global addedTrack;
    global orginalTrackLoaded;
    global addedTrackLoaded;
    global speedTrack;
    speedTrack = true;
    
    orginalTrackResume = orginalTrack;
    addedTrackResume = addedTrack;
    
    newSpeed = sampleRate * multiplier;
    
    if(orginalTrackLoaded)
        orginalTrackSound = audioplayer(orginalTrackData, newSpeed);
        set(orginalTrackSound, 'TimerFcn',{@trackTimer, 1, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@endTrack, 1, handles});
        stopTrack(handles, 1);
        if(orginalTrackResume)
            playTrack(1);
        end
    end
    
    if(addedTrackLoaded)
        addedTrackSound = audioplayer(addedTrackData, newSpeed);
        set(orginalTrackSound, 'TimerFcn',{@trackTimer, 2, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@endTrack, 2, handles});
        stopTrack(handles, 2);
        if(addedTrackResume)
            playTrack(2);
        end
    end

%function resetTrackSpeed
 
function mergeTrack(handles)
    global orginalTrackLoaded;
    global orginalTrackSound;
    global orginalTrackData;
    global addedTrackLoaded;
    global addedTrackSound;
    global addedTrackData;
    
    if orginalTrackLoaded && addedTrackLoaded
        if get(addedTrackSound, 'NumberOfChannels') == 1
            addedTrackDataTemp = [addedTrackData  addedTrackData];
        else
            addedTrackDataTemp = addedTrackData;
        end
        
        if get(orginalTrackSound, 'NumberOfChannels') == 1
            orginalTrackData = [orginalTrackData  orginalTrackData];
        end
        
        stopTrack(handles, 1);
        stopTrack(handles, 2);
        
        orginalSnd = get(orginalTrackSound, 'TotalSamples');
        orginalFS = get(orginalTrackSound, 'SampleRate');
        
        addedSnd = get(addedTrackSound, 'TotalSamples');
        
        insertTimer = round(get(handles.insertTrackSlider, 'Value')) * orginalFS;
        
        if(addedSnd + insertTimer) > orginalSnd
            insert = addedSnd + insertTimer - orginalSnd;
            zeroMatrix = zeros(insert, 2);
            orginalTrackData = [orginalTrackData ; zeroMatrix];
        end
        
        preInsert = insertTimer;
        preZeroMatrix = zeros(preInsert, 2);
        
        if(addedSnd + insertTimer) < orginalSnd
            postInsert = orginalSnd - insertTimer - addedSnd;
            postZeroMatrix = zeros(postInsert, 2);
            added = [preZeroMatrix ; addedTrackDataTemp; postZeroMatrix];
        else
            added = [preZeroMatrix ; addedTrackDataTemp];
        end
        
        orginalTrackData = orginalTrackData + added;
        orginalTrackSound = audioplayer(orginalTrackData, orginalFS);
        set(orginalTrackSound, 'TimerFcn', {@trackTimer, 1, handles}, 'TimerPeriod', 0.1, 'StopFcn', {@endTrack, 1, handles});
        visualiation(orginalTrackData, orginalFS, handles, 1);
    end
    
function saveTrack()
    global orginalTrackData;
    global orginalTrackLoaded;
    global sampleRate;
    
    if orginalTrackLoaded
        pathDirectory = uigetdir('', 'Select the Path');
        
        if pathDirectory
            trackName = inputdlg('Enter Track Name', 'File Name', [1 50]);
            
            if length(trackName) == 1
                directory = strcat(pathDirectory, '\', trackName, '.wav');
                
                if exist(directory{1}, 'file') == 2
                    confirm = questdlg('Track Already Exist. Do you want to overwrite', 'Track Already Exist.', 'Yes', 'No');
                    if strcmp(confirm, 'Yes')
                        audiowrite(directory{1}, orginalTrackData, sampleRate);
                    end
                else
                    audiowrite(directory{1}, orginalTrackData, sampleRate);
                end
            end
        end
    end
                        
    
    
    
% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function orginalTrackSlider_Callback(hObject, eventdata, handles)
% hObject    handle to orginalTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function orginalTrackSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orginalTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function addedTrackSlider_Callback(hObject, eventdata, handles)
% hObject    handle to addedTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function addedTrackSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addedTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
 

% --- Executes on button press in uploadOrginal.
function uploadOrginal_Callback(hObject, eventdata, handles)
% hObject    handle to uploadOrginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  importTrack(handles, 1);


% --- Executes on button press in uploadAdded.
function uploadAdded_Callback(hObject, eventdata, handles)
% hObject    handle to uploadAdded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  importTrack(handles, 2);


% --- Executes on button press in playOriginal.
function playOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to playOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  playTrack(1);

% --- Executes on button press in stopOriginal.
function stopOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to stopOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  stopTrack(handles, 1);

% --- Executes on button press in pauseOriginal.
function pauseOriginal_Callback(hObject, eventdata, handles)
% hObject    handle to pauseOriginal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  pauseTrack(1);

% --- Executes on button press in saveTrack.
function saveTrack_Callback(hObject, eventdata, handles)
% hObject    handle to saveTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveTrack();

% --- Executes on button press in resetSpeed.
function resetSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to resetSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function trackSpeedSlider_Callback(hObject, eventdata, handles)
% hObject    handle to trackSpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
addlistener(handles.trackSpeedSlider, 'Value', 'PostSet', @(s,e) set(handles.speed, 'String', round(handles.trackSpeedSlider.Value, 1)));
changeTrackSpeed(handles, get(handles.trackSpeedSlider, 'Value'));

% --- Executes during object creation, after setting all properties.
function trackSpeedSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trackSpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in playAdded.
function playAdded_Callback(hObject, eventdata, handles)
% hObject    handle to playAdded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 playTrack(2);


% --- Executes on button press in stopAdded.
function stopAdded_Callback(hObject, eventdata, handles)
% hObject    handle to stopAdded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopTrack(handles, 2);


% --- Executes on button press in pauseAdded.
function pauseAdded_Callback(hObject, eventdata, handles)
% hObject    handle to pauseAdded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pauseTrack(2);

% --- Executes on button press in addedTrackLoop.
function addedTrackLoop_Callback(hObject, eventdata, handles)
% hObject    handle to addedTrackLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addedTrackLoop


% --- Executes on slider movement.
function insertTrackSlider_Callback(hObject, eventdata, handles)
% hObject    handle to insertTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
addlistener(handles.insertTrackSlider, 'Value', 'PostSet', @(s,e) set(handles.insertTimer, 'String', round(handles.insertTrackSlider.Value, 1)));

% --- Executes during object creation, after setting all properties.
function insertTrackSlider_CreateFcn(hObject, ~, handles)
% hObject    handle to insertTrackSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in insertTrack.
function insertTrack_Callback(hObject, eventdata, handles)
% hObject    handle to insertTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mergeTrack(handles);


% --- Executes on button press in orginalTrackLoop.
function orginalTrackLoop_Callback(hObject, eventdata, handles)
% hObject    handle to orginalTrackLoop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of orginalTrackLoop


% --- Executes on button press in addedTrackInvert.
function addedTrackInvert_Callback(hObject, eventdata, handles)
% hObject    handle to addedTrackInvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
invertTrack(handles, 2);
% Hint: get(hObject,'Value') returns toggle state of addedTrackInvert


% --- Executes on button press in orginalTrackInvert.
function orginalTrackInvert_Callback(hObject, eventdata, handles)
% hObject    handle to orginalTrackInvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
invertTrack(handles, 1);
% Hint: get(hObject,'Value') returns toggle state of orginalTrackInvert


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq();
