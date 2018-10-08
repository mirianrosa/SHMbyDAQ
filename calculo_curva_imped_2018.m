% Programa de C�lculo das Curvas de Imped�ncia
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa ir� executar o c�lculo das curvas de imped�ncia a partir dos dados extra�dos anteriomente. Clique em OK para prosseguir com a rotina.','Programa de C�lculo de Curvas','modal'));

% Os dados extra�dos do circuito analisador pelo NI DAQ USB-6211 ser�o sub-
% metido a rotina de c�lculo da curva de imped�ncia.

% Sinais de excita��o:
% - chirp (sinal de frequ�ncia que varia de zero a 30KHz e tem dura��o de 1s)
% - aleat�rio (sinal gerado pela fun��o "randn" com zero de m�dia e 1 de vari�ncia)
% - idinput (sinal pseudoaleat�rio bin�rio previamente gerado pela fun��o "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% C�lculo das Curvas

'Par�metros do ensaio cuja curva ser� extra�da:'
num_ensaios
num_medidas
num_pontos_sinal
f_chirp


for i=1:num_ensaios
        
    % Curva Imped�ncia - Sinal aleat�rio
        
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_aleat(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_aleat(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));

    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);
    
    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
    curva_imped_mod1_aleat(i,:)=Z_final2;
   
    
    % Curva Imped�ncia - Sinal Chirp
    
    Z_media2=Z_media2';
    
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_chirp(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_chirp(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
    curva_imped_mod1_chirp(i,:)=Z_final2;
   
    
    % Curva Imped�ncia - Sinal Idinput
    
    Z_media2=Z_media2';
    
    for j=1:num_medidas
    
    [DFT_corrente2(:,j),w] = freqz(out_idinput(:,(j+(i-1)*num_medidas)));       %Transformada discreta de fourier
    [DFT_tensao2(:,j),w] = freqz(in_idinput(:,(j+(i-1)*num_medidas)));

    REAL_corrente2(:,j)=abs(DFT_corrente2(:,j));                %Parte real da DFT
    REAL_tensao2(:,j)=abs(DFT_tensao2(:,j));
    
    Z_media2(:,j)= REAL_tensao2(:,j)./ REAL_corrente2(:,j);

    end

    Z_media2=Z_media2';
    
    Z_final2=mean(Z_media2);   %Imped�ncia real do circuito
    
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
