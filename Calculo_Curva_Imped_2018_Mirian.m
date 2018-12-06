% Programa de C�lculo das Curvas de Imped�ncia
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa ir� executar o c�lculo das curvas de imped�ncia a partir dos dados extra�dos anteriomente. Clique em OK para prosseguir com a rotina.','Programa de C�lculo de Curvas','modal'));

% Os dados extra�dos do circuito analisador pelo NI DAQ USB-6211 ser�o sub-
% metidos a rotina de c�lculo da curva de imped�ncia.

% Sinais de excita��o:
% - chirp (sinal de frequ�ncia que varia de zero a 16KHz e tem dura��o de 1s)
% - aleat�rio (sinal gerado pela fun��o "randn" com zero de m�dia e 2 de vari�ncia)
% - idinput (sinal pseudoaleat�rio bin�rio previamente gerado pela fun��o "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% C�lculo das Curvas

'Par�metros do ensaio cuja curva ser� extra�da:'
r1
num_ensaios
num_medidas
num_pontos_sinal
f_chirp

for i=1:num_ensaios
        
    % Curva Imped�ncia - Sinal aleat�rio
        
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_aleat(:,(j+(i-1)*num_medidas)));  % Transformada Discreta de Fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_aleat(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));

    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);
    
    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);    % Imped�ncia real do circuito
    
    curva_imped_aleat(i,:)=Z_final;
   
    
    % Curva Imped�ncia - Sinal Chirp
    
    Z_media=Z_media';
    
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_chirp(:,(j+(i-1)*num_medidas)));  % Transformada discreta de fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_chirp(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));
    
    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);

    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);    % Imped�ncia real do circuito
    
    curva_imped_chirp(i,:)=Z_final;
   
    
    % Curva Imped�ncia - Sinal Idinput
    
    Z_media=Z_media';
    
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_idinput(:,(j+(i-1)*num_medidas)));% Transformada discreta de fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_idinput(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));
    
    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);

    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);     % Imped�ncia real do circuito
    
    curva_imped_idinput(i,:)=Z_final;
        
    Z_media=Z_media';
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configura��o dos Gr�ficos

curva_imped_aleat=curva_imped_aleat';
curva_imped_chirp=curva_imped_chirp';
curva_imped_idinput=curva_imped_idinput';

curva_aleat = mean(curva_imped_aleat,2);
curva_chirp = mean(curva_imped_chirp,2);
curva_idinput = mean(curva_imped_idinput,2);

 
x=0:1:511;                  % Transforma��o do eixo X de 512 pontos, provindos da fun��o freqz, para o eixo de intervalos de Frequ�ncia (Hertz).
eixo = 62500/511;
eixofreq = x(1,:)*eixo;

opts.Interpreter = 'tex';   % Interpretador para o s�mbolo de Ohms (\Omega) nos gr�ficos.

% Gr�fico Sinal Aleat�rio

figure()
plot(eixofreq,curva_aleat)
% grid minor
TITLE('Sinal Aleat�rio')
xlabel('Frequ�ncia (Hz)')
ylabel('Imped�ncia (\Omega)')
xlim([0 16000])

% Gr�fico Sinal Chirp

figure()
plot(eixofreq,curva_chirp)
% grid minor
TITLE('Sinal Chirp')
xlabel('Frequ�ncia (Hz)')
ylabel('Imped�ncia (\Omega)')
xlim([0 16000])

% Gr�fico Sinal Idinput

figure()
plot(eixofreq,curva_idinput)
% grid minor
TITLE('Sinal Aleat�rio-Bin�rio (Idinput)')
xlabel('Frequ�ncia (Hz)')
ylabel('Imped�ncia (\Omega)')
xlim([0 16000])

% Gr�fico Comparativo dos Tr�s Sinais de Excita��o

figure()
plot(eixofreq,curva_aleat,eixofreq,curva_chirp,eixofreq,curva_idinput);
legend('Sinal Aleat�rio','Sinal Chirp','Sinal Idinput','Location','Best')
TITLE('Gr�fico Comparativo dos Tr�s Sinais de Excita��o')
xlabel('Frequ�ncia (Hz)')
ylabel('Imped�ncia (\Omega)')
xlim([0 16000])