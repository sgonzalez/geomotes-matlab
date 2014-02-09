function varargout = Main(varargin)
% MAIN MATLAB code for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 09-Feb-2014 14:51:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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
end


% --- Override the closing function to close the serial port.
function closeProgram(hObject, eventdata, handles, varargin)
% Close the serial port. Otherwise, it will remain open and
% no other instance will be able to connect to it.
% Then, delete the figure.

global programSettings;
fclose(programSettings.port);
delete(gcf);
end

% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% brodrigu: add global variable for serial port access
% also set the default close operation to a custom function.
global programSettings;

programSettings.numberOfMotes = 1;
radio = instrhwinfo('serial');
radio = radio.AvailableSerialPorts(1);
programSettings.port = serial(radio, 'BaudRate', 57600);
fopen(programSettings.port);
setRadioDefaults();

set(gcf, 'CloseRequestFcn', @closeProgram);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% Set initial parameters:
%  Calibrate
%  Set Frequency to 5
%  Set Precision to LOW
%  Set Gain to 1
function setRadioDefaults()
global programSettings;
fprintf(programSettings.port, 'C');
pause(1);
fprintf(programSettings.port, 'F1');
pause(1);
fprintf(programSettings.port, 'PL');
pause(1);
fprintf(programSettings.port, 'G1');
end


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in pushbutton1.
% pushbutton1 = START
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global programSettings;
fprintf(programSettings.port, 'R');
end



% --- Executes on button press in pushbutton2.
% pushbutton2 = STOP
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global programSettings;
fprintf(programSettings.port, 'S');
pause(1);
programSettings.filenames = containers.Map(0, 'null');
for n = 1:programSettings.numberOfMotes
   command = strcat('T', int2str(n));
   fprintf(programSettings.port, command);
   filename = strcat(date, ' ', int2str(n), ' ', int2str(round(cputime)), '.txt');
   tempMap = containers.Map(n, filename);
   programSettings.filenames = [programSettings.filenames; tempMap];
   fileID = fopen(filename, 'w');
   pause(1);
   while programSettings.port.BytesAvailable > 0
      fprintf(fileID, '%d\n', fscanf(programSettings.port, '%d')); 
      %fscanf(programSettings.port)
   end
   fclose(fileID);
   graphData();
end
end

function graphData()
global programSettings;
hold all;
for n = 1:(programSettings.numberOfMotes)
    y = load(programSettings.filenames(n));
    l = size(y);
    plot(1:l(1), y);
end
hold off;
end


% --- Executes on button press in pushbutton3.
% pushbutton3 = CALIBRATE
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global programSettings;
fprintf(programSettings.port, 'C');
end


% --- Executes on selection change in popupmenu2.
% popupmenu2 = FREQUENCY
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

value = get(hObject,'Value');
message = strcat('F', num2str(value));
global programSettings;
fprintf(programSettings.port, message);

end


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in popupmenu3.
% popupmenu3 = PRECISION
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

value = get(hObject,'Value');
switch value
    case 1 % 1 = LOW
        message = 'PL';
        
    case 2 % 2 = HIGH
        message = 'PH';
end

global programSettings;
fprintf(programSettings.port, message);
end


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in popupmenu4.
% popupmenu4 = GAIN
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4

value = get(hObject,'Value');
message = strcat('G', num2str(value));
global programSettings;
fprintf(programSettings.port, message);
end


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% TODO(brodrigu): Add validation for this textbox.
% edit1 = # OF MOTES
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global programSettings;
motes = get(hObject,'String');
programSettings.numberOfMotes = motes;

end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end