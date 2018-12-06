% Programa de Cálculo das Curvas de Impedância
% Autor: Luis Antonio Lopes / Modificado por: Julio Almeida e Mirian Rosa
% -----------------------------------------------------------------------

uiwait(msgbox('Este programa irá executar o cálculo das curvas de impedância a partir dos dados extraídos anteriomente. Clique em OK para prosseguir com a rotina.','Programa de Cálculo de Curvas','modal'));

% Os dados extraídos do circuito analisador pelo NI DAQ USB-6211 serão sub-
% metidos a rotina de cálculo da curva de impedância.

% Sinais de excitação:
% - chirp (sinal de frequência que varia de zero a 16KHz e tem duração de 1s)
% - aleatório (sinal gerado pela função "randn" com zero de média e 2 de variância)
% - idinput (sinal pseudoaleatório binário previamente gerado pela função "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cálculo das Curvas

'Parâmetros do ensaio cuja curva será extraída:'
r1
num_ensaios
num_medidas
num_pontos_sinal
f_chirp

for i=1:num_ensaios
        
    % Curva Impedância - Sinal aleatório
        
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_aleat(:,(j+(i-1)*num_medidas)));  % Transformada Discreta de Fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_aleat(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));

    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);
    
    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);    % Impedância real do circuito
    
    curva_imped_aleat(i,:)=Z_final;
   
    
    % Curva Impedância - Sinal Chirp
    
    Z_media=Z_media';
    
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_chirp(:,(j+(i-1)*num_medidas)));  % Transformada discreta de fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_chirp(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));
    
    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);

    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);    % Impedância real do circuito
    
    curva_imped_chirp(i,:)=Z_final;
   
    
    % Curva Impedância - Sinal Idinput
    
    Z_media=Z_media';
    
    for j=1:num_medidas
    
    [DFT_corrente(:,j),w] = freqz(corrente_idinput(:,(j+(i-1)*num_medidas)));% Transformada discreta de fourier
    [DFT_tensao(:,j),w] = freqz(sinal_excitacao_idinput(:,(j+(i-1)*num_medidas)));

    REAL_corrente(:,j)=abs(DFT_corrente(:,j));                         % Parte real da DFT
    REAL_tensao(:,j)=abs(DFT_tensao(:,j));
    
    Z_media(:,j)= REAL_tensao(:,j)./ REAL_corrente(:,j);

    end

    Z_media=Z_media';
    
    Z_final=mean(Z_media);     % Impedância real do circuito
    
    curva_imped_idinput(i,:)=Z_final;
        
    Z_media=Z_media';
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configuração dos Gráficos

curva_imped_aleat=curva_imped_aleat';
curva_imped_chirp=curva_imped_chirp';
curva_imped_idinput=curva_imped_idinput';

curva_aleat = mean(curva_imped_aleat,2);
curva_chirp = mean(curva_imped_chirp,2);
curva_idinput = mean(curva_imped_idinput,2);

 
x=0:1:511;                  % Transformação do eixo X de 512 pontos, provindos da função freqz, para o eixo de intervalos de Frequência (Hertz).
eixo = 62500/511;
eixofreq = x(1,:)*eixo;

opts.Interpreter = 'tex';   % Interpretador para o símbolo de Ohms (\Omega) nos gráficos.

% Gráfico Sinal Aleatório

figure()
plot(eixofreq,curva_aleat)
% grid minor
TITLE('Sinal Aleatório')
xlabel('Frequência (Hz)')
ylabel('Impedância (\Omega)')
xlim([0 16000])

% Gráfico Sinal Chirp

figure()
plot(eixofreq,curva_chirp)
% grid minor
TITLE('Sinal Chirp')
xlabel('Frequência (Hz)')
ylabel('Impedância (\Omega)')
xlim([0 16000])

% Gráfico Sinal Idinput

figure()
plot(eixofreq,curva_idinput)
% grid minor
TITLE('Sinal Aleatório-Binário (Idinput)')
xlabel('Frequência (Hz)')
ylabel('Impedância (\Omega)')
xlim([0 16000])

% Gráfico Comparativo dos Três Sinais de Excitação

figure()
plot(eixofreq,curva_aleat,eixofreq,curva_chirp,eixofreq,curva_idinput);
legend('Sinal Aleatório','Sinal Chirp','Sinal Idinput','Location','Best')
TITLE('Gráfico Comparativo dos Três Sinais de Excitação')
xlabel('Frequência (Hz)')
ylabel('Impedância (\Omega)')
xlim([0 16000])