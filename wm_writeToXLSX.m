% function writes table data to xlsx.file

function wm_writeToXLSX(table, resultFolder, nameString)

formatOut = 'yymmdd';
% date      = datestr(now,formatOut);

% name of excel-file
file_name = [nameString '.xlsx'];
new_file = fullfile(resultFolder, file_name);

S = [table(:)];
writetable(struct2table(S),new_file);


