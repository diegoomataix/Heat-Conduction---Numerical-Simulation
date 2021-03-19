%% **********************************************************************************
%                      CONDUCCIÓN DE CALOR, SIMULACIÓN NUMÉRICA
% ------------------------------------------------------------------------------------
% Realizado por Diego Mataix Caballero.
%
% ADDITIONAL NOTES:
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
%___________________________________________________________________________
%% Datos
Conduccion_NumSim_DATOS
%___________________________________________________________________________
%% Choose exercise to run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choose = 'd';       % 'a', 'b', 'c', 'd' & 'e' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%___________________________________________________________________________
%% Define global parameters
%%% Define coefficients and some parameters %%%
phi = (3 * Q_ic) / Vol;                             % Volumetric dissipation [W/m^3]
l =      [t_rec dz_pcb t_rec];                      % Dimension Vector [m]
k_vect = [k_Cu k_plano (0.1*k_Cu+0.9*k_plano)];     % Conductivity Vector [W/(m·K)] tercera capa es donde van los IC, cubierta solo al 10% de cobre
k_eff = effective(k_vect, l);                       % Effective Conductivity [W/(m·K)]
L = dx/2;                                           % [m]
A = dy * dz;                                        % [m^2]
c_eff = (c_Cu*dx*t_rec + c_FR4*dz_pcb + c_Cu*t_rec) / (t_rec + dz_pcb + 0.1*t_rec);  % Thermal Capacity [J / K]
C_eff = c_eff * rho_FR4 * dx*dz*dy;

%%% Define the parameters for the sections containing the IC %%%
l_ic =      [t_rec dz_pcb t_rec dz_ic];                     % Dimension Vector [m]
k_vect_ic = [k_Cu k_plano (0.1*k_Cu+0.9*k_plano) k_ic];     % Conductivity Vector [W/(m·K)] tercera capa es donde van los IC, cubierta solo al 10% de cobre
k_eff_ic = effective(k_vect_ic, l_ic);                      % Effective Conductivity [W/(m·K)]
C_eff_ic = (C_eff *dz + C_ic*dz_ic)/ (dz + dz_ic);          % Thermal Capacity [J / K]
%%% Define the emissivity %%%
emiss_vect = [emiss_cara emiss_comp];
p_vect = [dx+dz dx+dz];
emiss = effective(emiss_vect, p_vect);
%%% Mesh %%%
m = 1e1;                                                    % Spatial Subdivisions
M = 14*m;                                                   % Total n of spatial subdivisions
x = linspace(0, dx, M);                                     % Spatial Coordinates [m]
N = 9e5;                                                    % # of time steps
tsim = 4000;                                                % Total simulation time [s]
%___________________________________________________________________________
switch(choose)
%___________________________________________________________________________
    case 'a'
        %% Apartado A
        % Considerando que la tarjeta sólo evacua calor por los bordes,
        % determinar la temperatura máxima que se alcanzaría si toda la disipación
        % estuviese uniformemente repartida en la PCB y los IC no influyeran.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        method = 2;         % 1: Only max Temp         2: Show all Temp profile
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch(method)
            case 1
                DT = 1/8 * ( phi * dx^2 / k_eff );          % Delta T [K]
                T_0 = T_b + DT                              % Max T [K]
                T_0_C = convtemp(T_0, 'K', 'C')             % Max T [C]
            case 2
                b = b_coef(Q_ic_tot, k_eff, dz*dy);         % [K*m]
                for i = 1:M
                     T(i) = temp_parb(T_b, b, (x(i)), phi, k_eff);  % [K]
                end
                T_0 = max(T)                                % Max T [K]
                T_0_C = convtemp(T_0, 'K', 'C')             % Max T [Celsius]

                figure()
                myplot(x,T)
                hold on
                axis([0 dx T_b*0.9 max(T)*1.1])
                ylabel('{\it T} [K]')
                xlabel('{\it x} [m]');
                xline(L, '-.')
                yline(T_b, '--')
                yline(T_0, '--')
                hold off
        end
%___________________________________________________________________________
        %% Apartado B
    case 'b'
        % Considerando que la tarjeta sólo evacua calor por los bordes, determinar
        % la temperatura máxima que se alcanzaría con un modelo unidimensional en el
        % que los IC llegaran hasta los bordes aislados, en el límite kIC→∞, y con la kIC dada.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        method = 1;         % 1: Method @ k -->  k_ic         2: Method @ k --> inf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Límites de cada tramo
        for i = 1:6
            lim(i) = 2*i*m;                                 % [m]
        end

        %%% Define the heat for each type of section: 1: w/o IC, 2 w/ IC %%%
        Q1 = Q_ic_tot;                                      % [W]
        Q2 = Q_ic_tot*(1/3);                                % [W]

        %%% Coefficients for the first section %%%
        a = T_b;                                            % [K]
        b = b_coef(Q_ic_tot, k_eff, dz*dy);                 % [K*m]

        A_ic = (dz+dz_ic)*dy;                               % [m^2]
        phi_ic = Q_ic / (0.02 * 0.1 * 0.0045);              % Volumetric dissipation [W/m^3]

        %%%%%%%%%%%% CALCULATIONS %%%%%%%%%%%%
        %%% SECTION 1: From the PCB border to the start of the 1st IC %%%
        T = zeros(1, M);
        for i = 1: lim(1)
            T(i) = temp_lin(Q1, x(i), k_eff, A, a);
        end
        %%% SECTION 2: From the start of the 1st IC to the end of that IC %%%
        switch(method)
            case 1 %%% k -->  k_ic %%%
                a = T(lim(1));                              % [K]
                b = b_coef(Q1, k_eff_ic, A_ic);             % [K*m]
                for i = lim(1):lim(2)
                    T(i) = temp_parb(a, b, (x(i) - x(lim(1))), phi_ic, k_eff_ic);   % [K]
                end

            case 2 %%% k --> inf %%%
                for i = lim(1)+1:lim(2)
                    T(i) = T(lim(1));                       % [K]
                end
        end
        %%% SECTION 3: From the end of the 1st IC to the start of the 2nd IC
        for i = (lim(2)+1):lim(3)
            T(i) = temp_lin(Q2, (x(i) - x(lim(2))), k_eff, A, T(lim(2)));           % [K]
        end
        %%% SECTION 4: From the start of the 2nd IC to the center of that IC
        switch(method)
            case 1 %%% k -->  k_ic
                a = T(lim(3));                              % [K]
                b = b_coef(Q2, k_eff_ic, A_ic);             % [K*m]
                for i = (lim(3)+1): (M/2)
                    T(i) = temp_parb(a, b, (x(i) - x(lim(3))), phi_ic, k_eff_ic);   % [K]
                end

            case 2 %%% k --> inf
                for i = (lim(3)+1): (M/2)
                    T(i) = T(lim(3));                       % [K]
                end
        end
        %%% TAKE ADVANTAGE OF SYMMETRY %%%
                T(((M/2)+1):M) = T(M/2:-1:1);               % Mirror curve

                T_0 = max(T)                                % Max T [K]
                T_0_C = convtemp(T_0, 'K', 'C')             % Max T [Celsius]

        %%% PLOT TEMPERATURE PROFILE %%%
                figure()
                hold on
                myplot(x,T)
                axis([0 dx T_b*0.9 max(T)*1.1])
                ylabel('{\it T} [K]')
                xlabel('{\it x} [m]');
                xline(L, '-.')
                yline(T_b, '--')
                yline(T_0, '--')
                hold off
%___________________________________________________________________________
        %% Apartado C
        % Considerando que se transmite calor por radiación, con una emisividad media de 0,7
        % por el lado de los componentes, y de 0,5 por la cara opuesta, con una caja electrónica
        % que se puede suponer negra y a 45 ºC, determinar la temperatura máxima linealizando las
        % pérdidas radiativas y con disipación uniforme.
    case 'c'

        p = (2*dy);         % Perimeter [m]
        A = dy * dz;        % Area [m^2]
        T_avg = 375;        % Average Temperature [K] % from 'a' --> 375K; from 'b' --> 363K

        eta = 4*p * stefan_boltz * emiss * T_avg^3;         % Auxiliary function for simplifying the ODE

        lambda = sqrt( eta / ( (k_eff * A) ) )                                  % Eigenvalues of the ODE
        c2 = (T_b - T_box - ( (phi * A) / eta ) / (1+exp(-lambda *dx)) )        % Coef. of the ODE
        c1 = c2*exp(-lambda*dx)                                                 % Coef. of the ODE

        % Temperature profile, the expression is found by solving the ODE
        % and applying the BC.
        for i = 1:M
            T(i) = c1* exp(lambda * x(i) ) + c2*exp(-lambda * x(i) ) + T_box + ( (phi*A)/eta);  % [K]
        end

        T_0 = max(T)                                        % Max T [K]
        T_0_C = convtemp(T_0, 'K', 'C')                     % Max T [Celsius]

        %%% PLOT TEMPERATURE PROFILE %%%
        figure()
        hold on
        myplot(x,T)
        axis([0 dx T_b*0.9 max(T)*1.1])
        ylabel('{\it T} [K]')
        xlabel('{\it x} [m]');
        xline(L, '-.')
        yline(T_b, '--')
        yline(T_0, '--')
        hold off

%___________________________________________________________________________
        %% Apartado D
        % Resolver el caso anterior pero sin linealizar y con la disipación no uniforme.
    case 'd'
        h=0;                % Convective coefficient [W/(m^2·K)] (NO CONVECTION)
        p = (2*dy);         % Radiative perimeter [m]
        
        % Límites de cada tramo
        for i = 1:6
            lim(i) = 2*i*m;                                 % [m]
        end
        
        % Definir los vectores para representar las discontinuidades
        %%% NO IC %%%
        for i = 1:lim(1)
            phi(i) = 0;
            k(i) = k_eff;
            A_vect(i) = A;                                  % [m^2]
            V(i) = dx * dz * dy;                            % [m^3]
            C(i) = c_eff *rho_FR4*V(i);                     % [J / K]
        end
        %%% IC %%%
        for i = lim(1)+1:lim(2)
            phi(i) = Q_ic / (0.02 * 0.1 * 0.0045);
            k(i) = k_eff_ic;
            A_vect(i) = (dz+dz_ic)*dy;                      % [m^2]
            V(i) = dx * (dz+dz_ic) * dy;                    % [m^3]
            C(i) = C_eff_ic;                                % [J / K]
        end
        %%% NO IC %%%
        for i = (lim(2)+1):lim(3)
            phi(i) = 0;
            k(i) = k_eff;
            A_vect(i) = A;                                  % [m^2]
            V(i) = dx * dz * dy;                            % [m^3]
            C(i) = c_eff *rho_FR4*V(i);                     % [J / K]
        end
        %%% IC %%%
        for i = (lim(3)+1): (M/2)
            phi(i) = Q_ic / (0.02 * 0.1 * 0.0045);
            k(i) = k_eff_ic;
            A_vect(i) = (dz+dz_ic)*dy;                      % [m^2]
            V(i) = dx * (dz+dz_ic) * dy;                    % [m^3]
            C(i) = C_eff_ic;                                % [J / K]
        end
        %%%% TAKE ADVANTAGE OF SYMMETRY
        phi(((M/2)+1):M) = phi((M/2):-1:1);                % Mirror vector phi
        k(((M/2)+1):M) = k(M/2:-1:1);                      % Mirror vector k
        A_vect(((M/2)+1):M) = A_vect(M/2:-1:1);            % Mirror vector A_vect
        V(((M/2)+1):M) = V(M/2:-1:1);                      % Mirror vector V
        C(((M/2)+1):M) = C(M/2:-1:1);                      % Mirror vector C
        %         phi(M+1) = phi(M);                                 %
        %         k(M+1) = k(M);                                     %
        %         A_vect(M+1) = A_vect(M);                           %
        %         V(M+1) = V(M);                                     %
        %         C(M+1) = C(M);                                     %
        
        %%Initialising:         % N time % M space
        Dx=dx/M;                % Element width
        X=linspace(0,dx,M+1);   % Node position list (equispaced)
        Dt=tsim/N;              % Time step (you might fix it instead of tsim)
        t=linspace(0,tsim,N)';  % Time vector
        DtrcA = ones(1,M);
        kALapla = ones(N,M+1);
        phDT = ones(N,M+1);
        T=T_b*ones(N,M+1); 	% Temperature-matrix (times from 1 to n, and positions from 1 to M+1)
        
        %%% Check for stability of the explicit finite difference method %%
        for i = 1:M
            Fo_vect(i)=k(i)/(C(i)/V(i))*Dt/(Dx*Dx);         %Fourier's number
            Bi_vect(i)=h*p*Dx/(k(i)*A_vect(i)/Dx);          %Biot's number
        end
        Fo = max(Fo_vect);
        Bi = max(Bi_vect);
        disp(['Stability requires 1-Fo*(2+Bi)<0. It actually is =',num2str(1-Fo*(2+Bi))])
        if 1-Fo*(2+Bi)<0 disp('This is unstable; increase number of time steps'), end
        
        %%% Temperature profile equation by means of finite elements methods %%%
        j=1; T(j,:)=T_b;       % Initial temperature profile T(x,t)=0 (assumed uniform)
        it=M+1; T(:,M+1)=T_b;
        for j=2:N              % Time advance
            %i=1; T(j,i)=T_b;   % Left border (base) maintained at T_b
            for i=2:M-1           % Generic spatial nodes
                %T(j,i)=T(j-1,i)+Fo_vect(i)*(T(j-1,i+1)-2*T(j-1,i)+T(j-1,i-1))...
                %    +Fo_vect(i)*Bi_vect(i)*(T_box-T(j-1,i))+phi(i)*Dt/(C(i)/V(i));
                %                T(j,i)=T(j-1,i)+(Dt/((C(i)/V(i))*A_vect(i)))*(( k(i)*A_vect(i)*...
                %                     (T(j-1,i+1)-T(j-1,i))-k(i)*A_vect(i)*(T(j-1,i)-T(j-1,i-1)) )...
                %                     /Dx^2+phi(i)*A_vect(i)- p*emiss*stefan_boltz*(T(j-1,i)^4 ...
                %                     - T_box^4));
                %                 T(j,i)=T(j-1,i)+(Dt/((C(i)/V(i))*A_vect(i)))*...
                %                     ((( ((k(i+1)+k(i))/2) * ((A_vect(i)+A_vect(i+1))/2) * (T(j-1,i+1)-T(j-1,i))...
                %                     - ((k(i)+k(i-1))/2) * ((A_vect(i)+A_vect(i-1))/2) * (T(j-1,i)-T(j-1,i-1)) )...
                %                     /Dx^2)+(phi(i)*A_vect(i))- (p*(emiss*stefan_boltz*(T(j-1,i)^4 ...
                %                     - T_box^4))) );
                
                DtrcA(i) = (Dt/((C(i)/V(i))*A_vect(i)));
                kALapla(j,i) = (( ((k(i+1)+k(i))/2) * ((A_vect(i)+A_vect(i+1))/2) *...
                    (T(j-1,i+1)-T(j-1,i))- ((k(i)+k(i-1))/2) * ((A_vect(i)+A_vect(i-1))/2) *...
                    (T(j-1,i)-T(j-1,i-1)) )/Dx^2);
%                 kALapla(j,i) = (( ((k(i))) * ((A_vect(i))) *...
%                     (T(j-1,i+1)-T(j-1,i))- ((k(i))) * ((A_vect(i))) *...
%                     (T(j-1,i)-T(j-1,i-1)) )/Dx^2);
                phDT(j,i) = (p*(emiss*stefan_boltz*(T(j-1,i)^4 - T_box^4)));
                
                T(j,i)=T(j-1,i)+(DtrcA(i))*...
                    ((kALapla(j,i))+(phi(i)*A_vect(i))- (phDT(j,i)) );
                
                %                 T(j,i) = T(j-1,i) + (Dt/((C(i)/V(i))*A_vect(i)))*...
                %                     (( (k(i+1)+k(i))/2) * ((A_vect(i)+A_vect(i+1))/2) * (T(j-1,i+1)-T(j-1,i))/(Dx^2)...
                %                     - (((k(i)+k(i-1))/2) * ((A_vect(i)+A_vect(i-1))/2) * (T(j-1,i)-T(j-1,i-1)))/(Dx^2)...
                %                     + (phi(i)*A_vect(i)) - (p*(emiss*stefan_boltz*(T(j-1,i)^4 - T_box^4))) );
            end
            %Boundory condition in node 0:
            T(j,1)=T_b;      %if Troot is fixed
            %Boundory condition in node N:
            T(j,M+1)=T_b;    %if Troot is fixed
        end
        %%% PLOT TEMPERATURE PROFILE %%%
        max(T(N,:))
        subplot(2,1,1);myplot(t,T(:,1:M/10:M+1));xlabel('{\it t} [s]'),ylabel('{\it T} [K]');title('{\it T(t,x)} {\it vs}.{\it t} at several locations')
        subplot(2,1,2);myplot(X,T(1:N/100:N,:));xlabel('{\it X} [m]'),ylabel('{\it T} [K]');title('{\it T(t,x)} {\it vs}.{\it X} at several times')
%___________________________________________________________________________
        %% Apartado E
        % Resolver el problema térmico bidimensional estacionario y comparar el perfil
        % central de temperaturas con el del caso anterior.
    case 'e'
    %%% Define 2D mesh %%%
    Mx = 1;
    My = 1;

    %%% Initialise %%%
    T = T_b*ones(N,Mx+1,My+1)

    %%% Bidimensional temperature profile equation by means of finite elements methods %%%
    for j = 2:N
        for i = 2:Mx
            for k = 2:My
                T(j,i,k) = T(j-1,i,k) + ((Dt*Vxy(i,k))/(C_effxy(i,k)*zxy(i,k)*...
                    (((k_effxy(i+1,k)+k_effxy(i,k))/2)*((zxy(i+1,k)+zxy(i,k))/2)*(T(j-1,i+1,k) - ...
                    T(j-1,i,k))/(Dx^2) - ((k_effxy(i,k)+k_effxy(i-1,k))/2)*(zxy(i,k)+zxy(i-1,k))/2)*...
                    T(j-1,i,k) - T(j-1,i-1,k))/(Dx^2) + ((k_effxy(i,k+1)+k_effxy(i,k))/2)...
                    *((zxy(i,k+1)+zxy(i,k))/2)*(T(j-1,i,k+1)-T(j-1,i,k))/(Dy^2) -...
                    ((k_effxy(i,k)+k_effxy(i,k-1))/2)*((zxy(i,k)+zxy(i,k-1))/2)*(T(j-1,i,k) -...
                    T(j-1,i,k-1))/(Dy^2) + phixy(i,k)*zxy(i,k) - (emiss)*...
                    stefan_boltz*(T(j-1,i,k)^4 - T_box^4));
                %Boundory condition in x-nodes 0 and Nx+1:
                T(j,1,k) = T_b;
                T(j,Nx+1,k) = T_b;
                %Boundory condition in y-nodes 0 and Ny+1:
                T(j,i,1) = T(j,i,2);
                T(j,i,Ny+1) = T(j,i,Ny);
            end
        end
    end

    max(T(N,:,:))
    %%% PLOT TEMPERATURE PROFILE %%%
    figure()
    contourf(X,Y,T(1,i,k))
    figure()
    surf(X,Y,T(:,M,:))
%___________________________________________________________________________
end

%___________________________________________________________________________
%% ======= FUNCIONES ADICIONALES ======= %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effective thermal conductivity k
function k_eff = effective(k_vect, l_vect)
k_eff = sum(k_vect.*l_vect)/sum(l_vect);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parabolic temperature eq
function T = temp_parb(a, b, x, phi, k)
T = a + b * (x) - ( phi/(2*k) ) * (x)^2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'b' parameter in parabolic temperature eq
function b = b_coef(Q, k, A)
b = Q / (k * A);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear termperature eq
function T = temp_lin(Q, x, k, A, a)
DT = Q * x / (k * A);
T = a + DT;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting function
function myplot(x, y)
plot(x,y, '-k','LineWidth',1)
box on
grid on
grid minor
axis tight
set(gca,'FontSize',18)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
