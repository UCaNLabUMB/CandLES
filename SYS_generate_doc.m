% SYS_GENERATE_DOC Create the documentation files for CandLES

% Get the file names in candles_classes
allFiles = dir( './+candles_classes/*.m' );
allNames = {allFiles().name};
docloc = './DOC/CandLES/';

for i = 1:length(allNames)
    [~,my_name,~] = fileparts(char(allNames(i)));
    htmlstr = help2html(['candles_classes.' my_name],'','-doc');
    fid = fopen([docloc my_name '.html'],'w');
    fprintf(fid,'%s',htmlstr);
    fclose(fid);
end

% FIXME: Need to find a good way to document/publish the GUI code
%
% Get the file names in candles_classes
% allFiles = dir( './CandLES*.m' );
% allNames = {allFiles().name};
% docloc = './DOC/CandLES_GUI/';
% 
% for i = 1:length(allNames)
%     [~,my_name,~] = fileparts(char(allNames(i)));
%     if (~strcmp(my_name,'CandLES_Template'))
%         htmlstr = help2html(char(allNames(i)),'','-doc');
%         fid = fopen([docloc my_name '.html'],'w');
%         fprintf(fid,'%s',htmlstr);
%         fclose(fid);
%     end
% end