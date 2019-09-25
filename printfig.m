%        NAME: printfig.m
%      AUTHOR: Jeffry K. Walker
%     CREATED: 24APR2018
%    MODIFIED: 24APR2018
%
% DESCRIPTION:
%    this function will print the current figure in a format suitable for LaTex.
%    The anme will take on the current figure name. The File will be output in
%    a folder of the current directory named 'figures'.
%
% OPTIONS:
%   name    - name to save as
%   fig     - figure name to print
%   folder  - output folder
%-------------------------------------------------------------------------------
function printfig(varargin)
p = inputParser;
addOptional(p, 'name', '')
addOptional(p, 'fig', '')
addOptional(p, 'folder', fullfile(pwd, 'figures'))
addOptional(p, 'keepAlpha',false)
addOptional(p, 'save', false);
parse(p, varargin{:});
ui = p.Results;
%--- get figure handle
if isempty(ui.fig)
   fh = gcf;
else
   try
       fh = findobj( 'Type', 'Figure', 'Name', ui.fig );
   catch
       error('invalid figure name requested')
   end
   %{
   TODO: add handling of multiple figures with the same name
   if numel(fh > 1)
       error('multiple figures with the same name found')
   end
   %}
end
%--- maximize figure
set(fh,'units','normalized','outerposition',[0 0 1 1]);
%--- ensure output location exists
fdir = ui.folder;
if ~isdir(fdir)
   mkdir(fdir);
end
if isempty(ui.name)
   %--- extract figure name
   name = get(fh, 'Name');
   num  = '';
   if isempty(name)
       name = 'Figure';
       num = num2str(get(fh,'Number'));
   end
   fname = [name, num];
else
   fname = ui.name;
end
%remove spaces
fname = strrep(fname,' ','');
if ui.keepAlpha
   print(fh, '-dpng',fullfile(fdir, fname),'-opengl')
else
   print(fh, '-depsc',fullfile(fdir, fname),'-painters')
end
%save original matlab figure
if ui.save
    savefig(gcf, fullfile(fdir, fname))
end

end