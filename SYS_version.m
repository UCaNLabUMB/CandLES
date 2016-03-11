function [ VER ] = SYS_version()
%SYS_VERSION get CandLES Version
%   Set here rather than in SYS_define_constants so that I can check the
%   version of the current global variable 'C' and redefine C if necessary.
    VER = 3.0;
end

