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

%% Choose example to run
choose = 1;

switch(choose)
    case 1
        %% Apartado A
        %
        phi = (3 * Q_ic) / Vol;                             % Volumetric dissipation [W/m^3]
        
        e =      [t_rec dz t_rec];                          % Dimension Vector [m]
        k_vect = [k_Cu k_plano (0.1*k_Cu+0.9*k_plano)];     % Conductivity Vector [W/(m·K)]
        
        k_eff = sum(k_vect.*e)/sum(e);                      % Effective Conductivity [W/(m·K)]
        DT = 1/8 * ( phi * dy^2 / k_eff );                  % Delta T [K]
        T_0 = T_b + DT                                      % Max T [K]
        
        %% Apartado B
        
    case 2
        
        %% Apartado C
        
    case 3
        
        %% Apartado D
        
    case 4
        
        %% Apartado E
        
    case 5
        
end
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
% total blackbody emissive power
function E_b = tot_blacbody_emiss_p(stefan_boltz, T)
E_b = stefan_boltz * T^4    % total blackbody emissive power
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  spectral emissive power of a blackbody
function E_b = planks_law(C_1, C_2, lambda, T)
E_b = C_1 / ( lambda^5 * exp( C_2 / (lambda*T)) - 1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = wiens_displacement(lambda_max_p, T)
T = 2898 / lambda_max_p;    % 2898 micrometer * K
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I_lambda_e = emitted_rad_int(delta, Qdot_e, dA, theta, domega, dlambda)
I_lambda_e = delta * Qdot_e / (dA * cos(theta) * domega * dlambda);
% W / ( m^2 * sr * micrometer )
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spectral hemispherical emissive power
function E_lambda  = spectral_hemispherical_emiss_p(I_lambda_e)
E_lambda = pi * I_lambda_e;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for a blackbody: 0 < epsilon < 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spectral directional emissivity ( diffuse )
function epsilon_lambda_theta = spectral_dir_emiss(I_lambda_e, I_b_lambda_theta, tipo)
if nargin < 3
    tipo = 'long';
end

switch(tipo) % diapositiva 12
    case 'long'     % calculado con intensidades
        epsilon_lambda_theta = I_lambda_e /  I_b_lambda_theta;
    case 'short'    % igualdad de emissivities
        epsilon_lambda_theta = epsilon_lambda;
    otherwise
        epsilon_lambda_theta = 0;
        disp('Error')
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spectral hemispherical emissivity ( greybody )
function epsilon_lambda = spectral_hemispherical_emiss(E_lambda, E_b_lambda)
epsilon_lambda = E_lambda / E_b_lambda;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% total hemispherical emissivity
function epsilon = tot_hemispherical_emiss(E, E_b)
epsilon_lambda = E / E_b;
end
