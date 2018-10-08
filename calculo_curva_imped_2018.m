% Programa de Cálculo das Curvas de Impedância
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa irá executar o cálculo das curvas de impedância a partir dos dados extraídos anteriomente. Clique em OK para prosseguir com a rotina.','Programa de Cálculo de Curvas','modal'));

% Os dados extraídos do circuito analisador pelo NI DAQ USB-6211 serão sub-
% metido a rotina de cálculo da curva de impedância.

% Sinais de excitação:
% - chirp (sinal de frequência que varia de zero a 30KHz e tem duração de 1s)
% - aleatório (sinal gerado pela função "randn" com zero de média e 1 de variância)
% - idinput (sinal pseudoaleatório binário previamente gerado pela função "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cálculo das Curvas

'Parâmetros do ensaio cuja curva será extraída:'
num_ensaios
num_medidas
num_pontos_sinal
f_chirp


for i=1:num_ensaios
        
    % Curva Impedância - Sinal aleatório
        
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_aleat(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_aleat(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));

    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);
    
    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Impedância real do circuito
    
    curva_imped_mod1_aleat(i,:)=Z_final2;
   
    
    % Curva Impedância - Sinal Chirp
    
    Z_media2=Z_media2';
    
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_chirp(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_chirp(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Impedância real do circuito
    
    curva_imped_mod1_chirp(i,:)=Z_final2;
   
    
    % Curva Impedância - Sinal Idinput
    
    Z_media2=Z_media2';
    
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_idinput(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_idinput(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Impedância real do circuito
    
    curva_imped_mod1_idinput(i,:)=Z_final2;
        
    Z_media2=Z_media2';
    
    
end

curva_imped_mod1_aleat=curva_imped_mod1_aleat';
curva_imped_mod1_chirp=curva_imped_mod1_chirp';
curva_imped_mod1_idinput=curva_imped_mod1_idinput';
 
x=0:1:511;
plot(x,curva_imped_mod1_idinput(:,1))

plot(x,curva_imped_mod1_chirp(:,1))

plot(x,curva_imped_mod1_aleat(:,1))
