% create_mice_all_randomMotorizedTreadmill.m
% Sarah West
% 11/30/21

% Creates and saves the lists of data you'll use for the given experiement
% (mouse names and days of data collected). 

% Each row of the structure is a different mouse. 


%% Parameters for directories
clear all;

experiment_name='Random Motorized Treadmill';

dir_base='Y:\Sarah\Analysis\Experiments\';
dir_exper=[dir_base experiment_name '\']; 

dir_out=dir_exper; 
mkdir(dir_out);

%% List of days

% If no stacks in a field, put NaN (don't leave empty, code will default to
% 'all').
mice_all(1).name='1087'; 
mice_all(1).days(1).name='112121';
mice_all(1).days(1).stacks='all'; 
mice_all(1).days(2).name='112421';
mice_all(1).days(2).stacks='all'; 
mice_all(1).days(3).name='112621';
mice_all(1).days(3).stacks=2:10; 
mice_all(1).days(4).name='112721';
mice_all(1).days(4).stacks='all'; 
mice_all(1).days(5).name='112821';
mice_all(1).days(5).stacks= [1, 3:10]; 
mice_all(1).days(6).name='120221';
mice_all(1).days(6).stacks= 4:11;
mice_all(1).days(6).spontaneous = 13:18;
mice_all(1).days(7).name='120721';
mice_all(1).days(7).stacks=1:10; 
mice_all(1).days(7).spontaneous= 11:15;
mice_all(1).days(8).name='121321';
mice_all(1).days(8).stacks=[1:6, 8:11]; 
mice_all(1).days(9).name='121721';
mice_all(1).days(9).stacks= [NaN];
mice_all(1).days(9).spontaneous= 12:16;
mice_all(1).days(10).name='010422';
mice_all(1).days(10).stacks= [2:3, 5:11];
mice_all(1).days(10).spontaneous= [12:16];
mice_all(1).days(11).name='010622';
mice_all(1).days(11).stacks= [NaN];
mice_all(1).days(11).spontaneous= [11:15]; % Don't use frames before ~3000 in stack 11
mice_all(1).days(12).name='011122'; 
mice_all(1).days(12).stacks= 1:10;
mice_all(1).days(12).spontaneous= [11, 14:17];


mice_all(2).name='1088';
mice_all(2).days(1).name='112121';
mice_all(2).days(1).stacks='all'; 
mice_all(2).days(2).name='112421';
mice_all(2).days(2).stacks='all'; 
mice_all(2).days(3).name='112621';
mice_all(2).days(3).stacks='all';
mice_all(2).days(4).name='112721';
mice_all(2).days(4).stacks='all'; 
mice_all(2).days(5).name='112821';
mice_all(2).days(5).stacks='all';      
mice_all(2).days(6).name='120321';
mice_all(2).days(6).stacks=2:11;
mice_all(2).days(6).spontaneous =[12:16];
mice_all(2).days(7).name='120721';
mice_all(2).days(7).stacks=3:12;
mice_all(2).days(7).spontaneous =[NaN];
mice_all(2).days(8).name='121621';
mice_all(2).days(8).stacks=6:15;
mice_all(2).days(8).spontaneous =[17:21];
mice_all(2).days(9).name='010522';
mice_all(2).days(9).stacks=[3:10 12];
mice_all(2).days(9).spontaneous =[13:14, 17];
mice_all(2).days(10).name='010622';
mice_all(2).days(10).stacks=6:15;
mice_all(2).days(10).spontaneous =[1:5];

mice_all(3).name='1096';
mice_all(3).days(1).name='112121';
mice_all(3).days(1).stacks=[1:4, 6:9];
mice_all(3).days(2).name='112721';
mice_all(3).days(2).stacks=[1:7, 9:10];
mice_all(3).days(3).name='112821';
mice_all(3).days(3).stacks=1:10;
mice_all(3).days(4).name='120221';
mice_all(3).days(4).stacks=1:10;
mice_all(3).days(4).spontaneous =[11:14];
mice_all(3).days(5).name='120321';
mice_all(3).days(5).stacks=1:10;
mice_all(3).days(5).spontaneous =[NaN];
mice_all(3).days(6).name='120621';
mice_all(3).days(6).stacks=1:10;
mice_all(3).days(6).spontaneous =[NaN];
mice_all(3).days(7).name='121421';
mice_all(3).days(7).stacks=6:14;
mice_all(3).days(7).spontaneous =[1:5];
mice_all(3).days(8).name='121721';
mice_all(3).days(8).stacks=[NaN];
mice_all(3).days(8).spontaneous =[1:5];
mice_all(3).days(9).name='010522';
mice_all(3).days(9).stacks=[7:10 12:14 17];
mice_all(3).days(9).spontaneous =[1:5];
mice_all(3).days(10).name='011122';
mice_all(3).days(10).stacks=6:15;
mice_all(3).days(10).spontaneous =[1:5];

save([dir_out 'mice_all.mat'], 'mice_all');
            
