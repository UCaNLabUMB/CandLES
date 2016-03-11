function SYS_define_strings( )
%SYS_DEFINE_STRINGS Define a global struct, STR, with all strings
%   This function centrally locate all displayed strings a la define
%   statements in C. Also allows for easier translation to another
%   language, but I doubt that's gonna happen.

    global STR
    
    STR.YES = 'Yes';
    STR.NO  = 'No';
    
    STR.TX    = 'Tx';
    STR.GROUP = 'Group';
    
    STR.MSG_HELP = ['CandLES is a simulation tool for indoor optical ' ...
         'wireless communication systems. The software was developed at '...
         'Boston University as part of the NSF funded Smart Lighting '...
         'Engineering Research Center. '];
    STR.MSG_ABOUT = 'About CandLES';
    
    STR.MSG1  = 'Are you sure you want to exit?';
    STR.MSG2  = 'Invalid .mat file. CandLES Environment does not exist';
    STR.MSG3  = 'Clear the current configuration?';
    STR.MSG4  = 'This feature has not yet been added.';
    STR.MSG5  = 'Keep updates?';
    STR.MSG6  = 'Grid Layout';
    STR.MSG7  = 'Cell Layout 1';
    STR.MSG8  = 'Cell Layout 2';
    STR.MSG9  = 'Tx Layout Settings';
    STR.MSG10 = 'Number of TXs in X dimension:';
    STR.MSG11 = 'Number of TXs in Y dimension:';
    STR.MSG12 = 'Distance between TXs (m):';
    STR.MSG13 = 'Center in X dimension (m):';
    STR.MSG14 = 'Center in Y dimension (m):';
    STR.MSG15 = 'Z Plane (m):';
    STR.MSG16 = 'Warning: Invalid Input';
    STR.MSG17 = 'Inputs must be numeric values';
    STR.MSG18 = 'Number of TXs must be an integer value';
    STR.MSG19 = 'Replace existing TXs?';
    STR.MSG20 = 'CandLES environment must contain a Tx.';
    STR.MSG21 = 'Txs can not be removed in Group view.';
    STR.MSG22 = 'New Tx Group Added Successfully';
    STR.MSG23 = 'Maximum Number of Tx Groups Reached.';
    STR.MSG24 = 'Select Group to Remove';
    STR.MSG25 = 'Group has multiple\n emission patterns.';
    STR.MSG26 = 'Group has no\n transmitters.';
    STR.MSG27 = 'CandLES environment must contain a Rx.';
    STR.MSG28 = 'BOX SELECT';
    STR.MSG29 = 'Close Page?';
    STR.MSG30 = ['Results have not been generated \n' ...
                 '           for this configuration.'];
    STR.MSG31 = 'All Rxs';

end

