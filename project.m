function varargout = project(varargin)
%
global padding

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
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


% --- Executes just before project is made visible.
function project_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = project_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%
%
%
%
%
%
%
%%start of the image processing


%to import image 
function a_gray = import_Callback(hObject, eventdata, handles)
path=uigetfile({'*.png;*.jpeg;*.jpg;*.jfif;*.svg;*.pjp;*.webp;*.avif;*.tif;*.tiff'});
a=imread(path);
global a_gray
a_gray=rgb2gray(a);
axes(handles.axes1);
imshow(a_gray)




%to show equalized image in gray level 
function equalize_Callback(hObject, eventdata, handles)
global a_gray
eq=histeq(a_gray);
axes(handles.axes2);
imshow(eq)


% to output original histogram
function Originalhistogram_Callback(hObject, eventdata, handles)
global a_gray
axes(handles.axes3)
imhist(a_gray)

%to show equalized histogram
function equalized_histogram_Callback(hObject, eventdata, handles)
global a_gray
eq=histeq(a_gray);
axes(handles.axes4); 
imhist(eq)

%%this part is for applying noise to the picture
function saltNoise_Callback(hObject, eventdata, handles)
global a_gray
im=a_gray;
N = numel(im) ; % total number of elements 
idx = randsample(N,round(10/100*N)) ;  % select 10% of indices randomly 
im(idx) = 255;%replacing value of  selected indices with 255 for salt
axes(handles.axes2); 
imshow(im)


function pepperNoise_Callback(hObject, eventdata, handles)
global a_gray
im=a_gray;
N = numel(im) ; % total number of elements 
idx = randsample(N,round(10/100*N)) ;  % select 10% of indices randomly 
im(idx) = 0; %replacing value of selected indices with 0 for pepper
axes(handles.axes2); 
imshow(im)

function saltAndPepperNoise_Callback(hObject, eventdata, handles)
global a_gray
both=imnoise(a_gray, 'salt & pepper',0.1); 
axes(handles.axes2); 
imshow(both)


function GaussianNoise_Callback(hObject, eventdata, handles)
global a_gray
gass=imnoise(a_gray,'gaussian',0.01);
axes(handles.axes2); 
imshow(gass);

function speckleNoise_Callback(hObject, eventdata, handles)
global a_gray
spec=imnoise(a_gray,'speckle');
axes(handles.axes2); 
imshow(spec)

%%this part is for applying filters

%1) common filters

function median_Callback(hObject, eventdata, handles)
global a_gray
med = medfilt2(a_gray);
axes(handles.axes2); 
imshow(med)

function minimum_Callback(hObject, eventdata, handles)
global a_gray
min = ordfilt2(a_gray,1,ones(3,3));
axes(handles.axes2); 
imshow(min)


function maximum_Callback(hObject, eventdata, handles)
global a_gray
max = ordfilt2(a_gray,9,ones(3,3));
axes(handles.axes2); 
imshow(max)
function gaussian_remove_Callback(hObject, eventdata, handles)
global a_gray
x=imgaussfilt(a_gray);
axes(handles.axes2); 
imshow(x)


%3) sharping&smothing filters
function sharping_Callback(hObject, eventdata, handles)
global a_gray
y=imsharpen(a_gray);
axes(handles.axes2); 
imshow(y)

function smothing_Callback(hObject, eventdata, handles)%%using avrage filter
global padding
global a_gray
smothed = imfilter(a_gray, ones(9)/81,padding);
axes(handles.axes2); 
imshow(smothed)

%4) spatial filters 

function Arithmatic_Callback(hObject, eventdata, handles)
global padding
global a_gray
windowWidth = 9;
fil = ones(windowWidth) / windowWidth^2;
arth = imfilter(a_gray, fil,padding);
axes(handles.axes2); 
imshow(arth)
function Geometric_Callback(hObject, eventdata, handles)
global padding
global a_gray
filc=3;
filr=3;
fil=ones(filr,filc);
im=im2double(a_gray);
geo=exp(imfilter(log(im),fil,padding)).^(1/(filr*filc));
axes(handles.axes2); 
imshow(geo)

function Harmonic_Callback(hObject, eventdata, handles)
global padding
global a_gray
filc=3;
filr=3;
fil=ones(filr,filc);
im=im2double(a_gray);
har=(filr*filc)./imfilter(1./im,fil,padding);
axes(handles.axes2); 
imshow(har)





%changging padding type
function paddingType_Callback(hObject, eventdata, handles)
global padding
val=get(handles.paddingType,'Value');
switch(val)
    case 3
        padding = 255;
    case 4
        padding = 'replicate';
    case 5
        padding = 'symmetric'; 
    case 6
        padding = 'circular';
    otherwise 
        padding=0;
end

function paddingType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%changging Brightness level
function Brightness_Callback(hObject, eventdata, handles)
%implement
global a_gray
val=get(handles.Brightness, 'value');
[rows cols]=size(a_gray);
for i=1:rows
    for j=1:cols
        output(i,j)=round(a_gray(i,j)+val);
        if output(i,j) > 255
           output(i,j)=255;
        elseif output(i,j) < 0
            output(i,j)=0;
        end
    end
end            
axes(handles.axes2);
imshow(output)

function Brightness_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%to clear axses if it is busshed
function clear_Callback(hObject, eventdata, handles)
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
cla(handles.axes3,'reset');
cla(handles.axes4,'reset');
clear;
clc;
function close_Callback(hObject, eventdata, handles)
close

