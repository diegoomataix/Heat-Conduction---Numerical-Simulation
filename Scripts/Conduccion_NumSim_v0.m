%% **********************************************************************************
%                      CONDUCCIÓN DE CALOR, SIMULACIÓN NUMÉRICA
% ------------------------------------------------------------------------------------
% Realizado por Diego Mataix Caballero.
%
%  ADDITIONAL NOTES:
%    
%___________________________________________________________________________
close all; clear all; clc;

%% Datos
Conduccion_NumSim_DATOS

%% Apartado A


%% ======= FUNCIONES ADICIONALES ======= %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% COATINGS & SURFACE FINISHES %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function E = Energy_E(h, v)
    E = h * v;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lambda = wavelength(c, v)
    lambda = c / v;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function E_b = tot_blacbody_emiss_p(stefan_boltz, T)
    E_b = stefan_boltz * T^4    % total blackbody emissive power
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function E_b = planks_law(C_1, C_2, lambda, T)  
    %  spectral emissive power of a blackbody
    E_b = C_1 / ( lambda^5 * exp( C_2 / (lambda*T)) - 1);   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = wiens_displacement(lambda_max_p, T)
    T = 2898 / lambda_max_p;    % 2898 micrometer * K
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I_e = emitted_rad_int(delta, Qdot_e, dA, theta, domega, dlambda)
    I_e = delta * Qdot_e / (dA * cos(theta) * domega * dlambda); 
    % W / ( m^2 * sr * micrometer )
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function M = EcCohete(Isp, DV, M_o, tipo)
%     if nargin < 3
%         tipo = 'Mp';
%     end
%     
%     switch(tipo)
%         case 'Mp'   % M prop
%         M = M_o * (1 - exp(-(DV/Isp)));
%         case 'Mf'   % M final
%         M = M_o * (exp(-DV/Isp));
%         otherwise
%         M = 0;
%         disp('Error')
%     end
% end

