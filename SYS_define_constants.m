function SYS_define_constants( )
%SYS_DEFINE_CONSTANTS Define a global struct, C, with all constants values
%   This function allows me to centrally locate all constant values a la
%   define statements in C. Makes things easier to modify in the future and
%   make sure changing a constant updates all places where it's used. If
%   the constant values are needed after this function is run once, simply
%   call "global C" in the function where the constants will be used in
%   order to bring C into the scope of the function.

    global C

    %% Current CandLES Version
    C.VER = SYS_version();

    %% Default Environment Values
    C.D_RM_SIZE        = [  5,   4,   3];   % Room Dimensions
    C.D_RM_REF         = [1,1; 1,1; 1,0.5]; % Room Reflectivity
    C.D_ENV_TX_POS     = [2.5,   2, 2.5];   % Original Tx Position
    C.D_ENV_RX_POS     = [2.5,   2,   1];   % Original Rx Position
    
    C.D_NUM_NET_GROUPS = 1;                 % Number of Net Groups
    C.D_DEL_T          = 1e-10;             % Time Resolution
    C.D_DEL_S          = 0.25;              % Spatial Resolution (Reflectors)
    C.D_DEL_P          = 0.5;               % Spatial Resolution (Results Plane)
    C.D_MIN_BOUNCE     = 0;                 % Min # of reflections observed
    C.D_MAX_BOUNCE     = 0;                 % Max # of reflections observed
    C.D_DISP_WAITBAR   = 1;                 % Display Waitbar
    
    C.D_BOX_POS        = [  0,   0,   0];   % Box Position
    C.D_BOX_SIZE       = [0.1, 0.1, 0.1];   % Box Dimensions
    C.D_BOX_REF        = [1,1; 1,1; 1,1];   % Box Reflectivities
    
    C.D_PS_POS         = [  0,   0,   0];   % Point Source Position
    C.D_PS_OR          = [  0,   0];        % Point Source Orientation
    C.D_TX_POS         = [0.1, 0.1,   0];   % New Tx Postion
    C.D_TX_AZ          = 0;                 % New Tx Azimuth
    C.D_TX_EL          = 3*pi/2;            % New Tx Elevation
    C.D_TX_PS          = 1;                 % New Tx Power
    C.D_TX_M           = 1;                 % New Tx Lambertian Order
    C.D_TX_NG          = 1;                 % New Tx Net Group
    C.D_RX_POS         = [0.1, 0.1,   0];   % New Rx Position
    C.D_RX_AZ          = 0;                 % New Rx Azimuth
    C.D_RX_EL          = pi/2;              % New Rx Elevation
    C.D_RX_A           = 1e-4;              % New Rx Area
    C.D_RX_FOV         = pi/4;              % New Rx FOV
    C.D_RX_N           = 1.5;               % New Rx index of refraction
    
    % This is a simple base PSD... Update for LEDs to be used
    % FIXME: Need to do something with this...
    C.D_LAMBDA = 200:1:1100;
    s1=18; m1=450; a1=1; s2=60; m2=555; a2=2.15*a1; s3=25; m3=483; a3=-0.2*a1;
    Sprime = a1/(sqrt(2*pi)*s1)*exp(-(C.D_LAMBDA-m1).^2/(2*s1^2)) + ...
             a2/(sqrt(2*pi)*s2)*exp(-(C.D_LAMBDA-m2).^2/(2*s2^2)) + ...
             a3/(sqrt(2*pi)*s3)*exp(-(C.D_LAMBDA-m3).^2/(2*s3^2));
    C.D_SPRIME = Sprime/sum(Sprime);  %Normalized PSD    
    
    %% Constraints of the environment
    C.MAX_NET_GROUPS   = 10;                % Max # of Net Groups
    C.MIN_TX           = 1;                 % Min # of Txs in Environment
    C.MIN_BOX_DIM      = 0.1;               % Min box dimension
    C.MAX_ROOM_DIM     = 10;                % Max room dimension
    C.MAX_REF          = 1;                 % Max reflectivity value
    
    %% Error Values
    C.NO_ERR         = 0;
    C.ERR_RM_OBJ     = 1;
    C.ERR_MAX_NG     = 2;
    C.ERR_INV_SELECT = -1;
    C.ERR_INV_STRING = -2;
    C.ERR_INV_PARAM  = -3;
    
    %% Create the STR structure for all strings
    SYS_define_strings();
    
end

