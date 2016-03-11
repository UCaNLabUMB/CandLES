function SYS_define_constants( )
%SYS_DEFINE_CONSTANTS Define a global struct, C, with all constants values
%   This function allows me to centrally locate all constant values a la
%   define statements in C. Makes things easier to modify in the future and
%   make sure changing a constant updates all places where it's used. If
%   the constant values are needed after this function is run once, simply
%   call "global C" in the function where the constants will be used in
%   order to bring C into the scope of the function.

    global C

    % Default Environment Values
    C.D_RM_SIZE        = [  5,   4,   3];
    C.D_RM_REF         = [1,1; 1,1; 1,0.5];
    C.D_ENV_TX_POS     = [2.5,   2, 2.5];
    C.D_ENV_RX_POS     = [2.5,   2,   1];
    
    C.D_NUM_NET_GROUPS = 1;
    C.D_DEL_T          = 1e-10;
    C.D_DEL_S          = 0.25;
    C.D_DEL_P          = 0.5;
    C.D_MIN_BOUNCE     = 0;
    C.D_MAX_BOUNCE     = 0;
    C.D_DISP_WAITBAR   = 1;
    
    C.D_BOX_POS        = [  0,   0,   0];       % Box Position
    C.D_BOX_SIZE       = [0.1, 0.1, 0.1];       % Box Dimensions
    C.D_BOX_REF        = [1,1; 1,1; 1,1];       % Box Reflectivities
    
    C.D_PS_POS         = [  0,   0,   0];       % Point Source Position
    C.D_PS_OR          = [  0,   0];            % Point Source Orientation
    C.D_TX_POS         = [0.1, 0.1,   0];
    C.D_TX_AZ          = 0;
    C.D_TX_EL          = 3*pi/2;
    C.D_TX_PS          = 1;
    C.D_TX_M           = 1;
    C.D_TX_NG          = 1;
    C.D_RX_POS         = [0.1, 0.1,   0];
    C.D_RX_AZ          = 0;
    C.D_RX_EL          = pi/2;    
    C.D_RX_A           = 1e-4;
    C.D_RX_FOV         = pi/4;
    C.D_RX_N           = 1.5;
    
    
    % Current CandLES Version
    C.VER = SYS_version();
    
    % Constraints of the environment
    C.MAX_NET_GROUPS   = 5;
    C.MIN_TX           = 1;
    C.MIN_BOX_DIM      = 0.1;
    C.MAX_ROOM_DIM     = 10;
    C.MAX_REF          = 1;
    
    % Error Values
    C.NO_ERR         = 0;
    C.ERR_RM_OBJ     = 1;
    C.ERR_MAX_NG     = 2;
    C.ERR_INV_SELECT = -1;
    C.ERR_INV_STRING = -2;
    C.ERR_INV_PARAM  = -3;

end

