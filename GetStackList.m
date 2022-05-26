% GetStackList.m
% Sarah West
% 10/11/21

% Makes a list of stack file names within a day folder to use. 

% Inputs: 
% mouse- a character array; is the name/number of the mouse.
% day- a character array; is the name/date of the day
% parameters - is all the other parameters you're using in your pipeline,
% including the input file name format and directory and the number of digits used in the stack number name. 
function [stackList]=GetStackList(mousei, dayi, parameters)
    
    % Convert parameter names to something easier to use.
    dir_dataset_name = parameters.dir_dataset_name; 
    input_data_name = parameters.input_data_name;
    dir_exper = parameters.dir_exper; 
    mice_all = parameters.mice_all; 
    digitNumber = parameters.digitNumber;
    mouse = mice_all(mousei).name;
    day = mice_all(mousei).days(dayi).name;
    
    % Find if there's a stack list entry for that day. If not, set
    % to 'all' as a default. 
    if isfield(mice_all(mousei).days(dayi), 'stacks')==0
       mice_all(mousei).days(dayi).stacks='all'; 
    elseif isempty(mice_all(mousei).days(dayi).stacks)==1
       mice_all(mousei).days(dayi).stacks='all'; 
    end
    
    % Create a combined input name.
    combined_input_name = [dir_dataset_name input_data_name];
    
    % Find the correct stack list entry of mice_all. 
    useStacks=mice_all(mousei).days(dayi).stacks; 
            
    % If stackList is a character string (to see if 'all')
    if ischar(useStacks)

       % If it is a character string, check to see if it's the string
       % 'all'. 
       if strcmp(useStacks, 'all')

           % Create a file name string for searching. 
           searching_name=CreateFileStrings(combined_input_name, mouse, day, [], [], true); 

           % If it is the character string 'all', list stacks from
           % the day directory. 
           list=dir(searching_name);
           
           % Get the stack number for naming output files using the 
           % input_data_name (allows for flexible outside-package file names). 

           % Find the index of the stack number within the input data name.  
           stackindex=find(contains(combined_input_name,'stack number'));

           % Find the letters in the filename before the stack
           % number. 
           pre_stack_name = CreateFileStrings(combined_input_name(1:stackindex-1), mouse, day, [], [], false); 
           
           % Find the number of letters in the filename before
           % the stack number. 
           length_pre=length(pre_stack_name); 
           
           % Initialize empty character array list of stack numbers and file names.
           stackList.numberList=[];
           stackList.filenames=[]; 
           
           % For each stack in the list, 
           for stacki = 1:size(list,1)
                  
               % Take range of the name in the file list that corresponds to the stack number, according to number of
               % letters that came before the stack number and the
               % number of digits assigned to the stack number. 
               combined_name = [list(stacki).folder '\' list(stacki).name];
               stack_number=combined_name(length_pre+1 : length_pre+digitNumber); 
               
               % Get the filename of the stack. 
               filename=[list(stacki).name];
               
               % Assign these to the stackList variable.
               stackList.numberList = [stackList.numberList; stack_number]; 
               stackList.filenames = [stackList.filenames; filename]; 
           end
           
       else  % If a character string, but not 'all', throw an error.
           error('Stacks indicated for use can only be a vector of numbers or ''all'' (the default).'); 

       end

    % If useStacks is not a character string, assume it's a vector of integer stacknumbers.  
    else
        % Get a list of numbers for each stack. 
        stackList.numberList=ListStacks(useStacks, digitNumber); 
        
        % Initialize empty character array list of stack file names.
        stackList.filenames=[]; 
        
        % For each member of numberList, get the filename.
        for i = 1:size(stackList.numberList,1)
            
            % Get the stack nubmer
            stack_number = stackList.numberList(i, :); 
            
            % Get the whole file name. 
            stackname=CreateFileStrings(input_data_name, [], [], stack_number, [], false); 
            
            % Add the file name to the list of stack file names.
            stackList.filenames = [stackList.filenames; stackname]; 

        end 
    end 
end