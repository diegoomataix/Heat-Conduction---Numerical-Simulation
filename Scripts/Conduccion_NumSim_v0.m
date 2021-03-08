%% **********************************************************************************
%                      CONDUCCIÓN DE CALOR, SIMULACIÓN NUMÉRICA
% ------------------------------------------------------------------------------------
% Realizado por Diego Mataix Caballero.
%
%  ADDITIONAL NOTES:
% PCB de FR-4 =: 140 x 100 x 1.5 (dx * dy * dz)
% Recubrimiento de Cu de 50e-6 m 
%       - en cara 1 : continuo
%       - en cara 2 : 90% FR-4, 10% Cu
% 3 IC, cada uno disipa 5W, con k_ic = 5 [W/(mK)], con c_ic = 20 [J/K]
%       - distribuidos uniformemente en la PCB, 20 mm de separacion
% PCB tiene contact termico perfecto con paredes permanentemente a 25C, los
% otros dos bordes están térmicamente aislados.
%___________________________________________________________________________
close all; clear all; clc;

%% Datos
Conduccion_NumSim_DATOS

%% Choose exercise to run
choose = 'b';

switch(choose)
    case 'a'
%% Apartado A
% Considerando que la tarjeta sólo evacua calor por los bordes, 
% determinar la temperatura máxima que se alcanzaría si toda la disipación 
% estuviese uniformemente repartida en la PCB y los IC no influyeran. 
        phi = (3 * Q_ic) / Vol;                             % Volumetric dissipation [W/m^3]
        
        e =      [t_rec dz_pcb t_rec];                      % Dimension Vector [m]
        k_vect = [k_Cu k_plano (0.1*k_Cu+0.9*k_plano)];     % Conductivity Vector [W/(m·K)] tercera capa es donde van los IC, cubierta solo al 10% de cobre
        
        k_eff = sum(k_vect.*e)/sum(e)                       % Effective Conductivity [W/(m·K)]
        DT = 1/8 * ( phi * dx^2 / k_eff );                  % Delta T [K]
        T_0 = T_b + DT                                      % Max T [K]
        T_0_C = convtemp(T_0, 'K', 'C')                     % Max T [C]
        
%% Apartado B
    case 'b'
        Vol_ic = dx_ic * dy * dz_ic;
        
        e =      [t_rec dz_pcb t_rec];                      % Dimension Vector [m]
        k_vect = [k_Cu k_plano (0.1*k_Cu+0.9*k_plano)];     % Conductivity Vector [W/(m·K)] tercera capa es donde van los IC, cubierta solo al 10% de cobre
        k_eff = sum(k_vect.*e)/sum(e);                      % Effective Conductivity [W/(m·K)]
        
        M = 7;                                              % Number of segments
        Dx = [dx/7 2*dx/7 3*dx/7 4*dx/7 5*dx/7 6*dx/7 dx];  % linspace(0, dx, dx/dist_ic);
       
        for i = 1:length(Dx)
            % definir phis
            phi(2*i) = (Q_ic) / (dist_ic * (dz + dz_ic) * dy);  % Volumetric dissipation [W/m^3]
            phi(2*i-1) = 0;                                     % Volumetric dissipation [W/m^3]
            phi(8:end)= [];                                     % Delete extra columns            
            
            % definir k efectivas
            
            % definir coeficientes
            
            b(i) = ( phi(i) / (k_eff) ) * ( (1/A) + Dx(i) );
            a(i) = T_b - b(i)*Dx(i) + ( phi(i) / (2*k_eff) ) *  Dx(i)^2;
            
            % definir temperaturas
            T(i) = a(i) + b(i) * Dx(i) - ( phi(i) / (2*k_eff) ) *  Dx(i)^2   %
        end
        
        % BC
%         T(2) = T(2) + 1/8 * ( phi(2) * Dx(2)^2 / k_eff );
%         T(4) = T(4) + 1/8 * ( phi(2) * Dx(4)^2 / k_eff ) ;
%         T(6) = T(6) + 1/8 * ( phi(2) * Dx(6)^2 / k_eff );
%             
%             
         T(1) = T_b;
         T(M) = T_b;
        
        plot(T)
        
        
% Considerando que la tarjeta sólo evacua calor por los bordes, determinar 
% la temperatura máxima que se alcanzaría con un modelo unidimensional en el 
% que los IC llegaran hasta los bordes aislados, en el límite kIC→∞, y con la kIC dada. 


   
        
%% Apartado C
        
    case 'c'
        
%% Apartado D
        
    case 'd'
        
%% Apartado E
        
    case 'e'
        
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
