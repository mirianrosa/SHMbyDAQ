% Programa de Aquisi��o de Dados por Imped�ncia Eletromec�nica (Ensaios)
% Autor: Luis Antonio Lopes / Modificado por: Mirian Rosa e Julio Almeida
% -------------------------------------------------------------------------

uiwait(msgbox('Este programa ir� executar a rotina de extra��o de dados atrav�s do m�todo de imped�ncia eletromec�nica para posterior c�lculo de curvas. Clique em OK para prosseguir com a rotina.','Programa de Aquisi��o de Dados','modal'));

% O circuito consiste em um transdutor piezoel�trico em s�rie com um
% resistor simples, cuja tens�o (VR) ser� medida pelo NI DAQ USB-6211
% enquanto o piezoel�trico est� acoplado � estrutura a ser analizada,
% com o objetivo de se descobrir a corrente total do circuito enquanto
% o USB-6211 o excita com diferentes sinais de entrada para, posterior-
% mente, calcular-se as curvas de imped�ncia da estrutura.

% Sinais de excita��o:
% - chirp (sinal de frequ�ncia que varia de zero a 30KHz e tem dura��o de 1s)
% - aleat�rio (sinal gerado pela fun��o "randn" com zero de m�dia e 1 de vari�ncia)
% - idinput (sinal pseudoaleat�rio bin�rio previamente gerado pela fun��o "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defini��o de par�metros

prompt = {'Resist�ncia (valor real, em \Omega):','N�mero de ensaios:','N�mero de medidas por ensaio:','N�mero de pontos do sinal aleat�rio:','Frequ�ncia m�xima do sinal chirp:'};
title = 'Par�metros';
definput = {'498.0','10','3','125000','16000'}; % Padr�es definidos, respectivamente, para a resist�ncia, n�mero de ensaios e n�mero de medidas por ensaio.
opts.Interpreter = 'tex'; % Interpretador para o s�mbolo de Ohms (\Omega).
parametros = inputdlg(prompt,title,[1 45],definput,opts) % Entrada de par�metros, com os valores padr�o autocompletados.

r1 = str2num(parametros{1});             % Atribui��o dos par�metros
r1                                       % indicados manualmente para
num_ensaios = str2num(parametros{2});    % as vari�veis.
num_ensaios
num_medidas = str2num(parametros{3});
num_medidas
num_pontos_sinal = str2num(parametros{4});
num_pontos_sinal
f_chirp = str2num(parametros{5});
f_chirp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configura��o DAQ

ao = analogoutput('nidaq','Dev2');          % Analogoutput cria um objeto analogoutput associado com o NIDAQ USB-6211, com sua identifica��o. Checar se a identifica��o do DAQ no "Measurement & Automation Explorer" da National Instruments � "Dev2". Caso negativo, renomear.
addchannel(ao,0,'Sinal de Sa�da');          % Aloca a porta AO0 do DAQ (alimenta��o do circuito).
ao.SampleRate = 125000;                     % Configura SampleRate do DAQ para garantir que o tempo real de amostragem seja compat�vel com o tempo programado no sinal chirp.
ao.TriggerType = 'HwDigital';        
ao.HwDigitalTriggerSource = 'PFI4'; 
ao                                 

                                   
ai = analoginput('nidaq','Dev2');           % Analoginput cria um objeto analoginput associado com o NIDAQ USB-6211, com sua identifica��o.
set(ai,'InputType','Differential');         % Configura o AnalogInput para modo Diferencial (diferen�a de um ponto a outro, pois os dois canais utilizados s�o pontos flutuantes).
addchannel(ai,[2 4],{'Aquisicao Resistor','Medidor Sa�da Real'})   % Aloca, respectivamente, as portas AI2/AI10 (terminais do resistor) e AI4/AI12 (entrada do sinal de excita��o) do DAQ.
ai.SampleRate = 125000;                     % Segundo especifica��es do NI DAQ USB-6211, a taxa de amostragem total (250 KS/s) das portas Analog Input � dividida pelo n�mero de portas utilizadas.
ai.SamplesPerTrigger = 125000;
ai.TriggerType = 'Immediate';
ai.ExternalTriggerDriveLine = 'PFI4';
ai

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
% Aquisi��o de Dados

load ('sinal_excit_idinput_125k.mat')
% Carrega automaticamente o sinal de excita��o idinput que precisa estar na mesma 
% pasta e diret�rio deste c�digo-base.

% No caso de n�o existir o arquivo, gerar um novo sinal atr�ves da Command Window
% sinal_pseudrand_binario = idinput(125000,'PRBS',[0,1],[-1 1])
% e salvar a nova vari�vel (in Workspace) com o nome sinal_excit_idinput_125k.mat
% no mesmo diret�rio deste c�digo-base.

erros = 0; % Vari�vel para contador do n�mero de erros

for i=1:num_ensaios
    
    
    % Ensaio Sinal Aleat�rio
    
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    sinal_excit_aleat = randn(num_pontos_sinal,1);
    sinal_excit_aleat = sinal_excit_aleat./(max(abs(sinal_excit_aleat)));
    sinal_excit_aleat = 2*sinal_excit_aleat;

    'Realizando medida sinal aleat�rio'
    j
    
    putsample(ao,[0])                       % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_aleat])         % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                               % � necess�rio iniciar o AnalogOutput primeiro para
    start(ai)                               % que este aguarde o in�cio do AnalogInput
    
    [data_aleat,time] = getdata(ai);        % Aquisi��o de dados.
                                            % Primeira coluna da matriz � a medida diferencial dos terminais do resistor;
                                            % Segunda coluna da matriz � a medida diferencial do sinal de alimenta��o do circuito.

    stop([ai,ao])                           % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                       % Recoloca o AnalogOutput em zero

    data_aleat(:,1) = data_aleat(:,1)./r1;  % C�lculo da corrente em cada instante de tempo
                                            % dividindo-se o valor medido nos terminais do 
                                            % resistor pelo seu valor de resist�ncia.
    
                                            
    if (mean(abs(data_aleat))>8e-006)       % Checa se houve sinal de resposta extra�do ou se os valores
                                            % lidos s�o iguais a zero (menor que 0.00008 - praticamente nulo).
                                            
    corrente_aleat(:,(j+(i-1)*num_medidas)) = data_aleat(:,1);            % Caso n�o haja erro, guardar os resultados de corrente e sinal de excita��o medidos   
    sinal_excitacao_aleat(:,(j+(i-1)*num_medidas)) = data_aleat(:,2);     % nas vari�veis a serem utilizadas pelo programa de c�lculo de curvas de imped�ncia.

    
    else
        'Erro: leitura nula'
        j=j-1;
        erros = erros + 1;
        j
    end
    
    
    end
    
    
    % Ensaio Sinal Chirp
           
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    t_chirp = 0.000008:0.000008:1;                       % Totaliza 125k intervalos de tempo em um segundo.
    sinal_excit_chirp = (chirp(t_chirp,0,1,f_chirp))';   % Gera amostras de sinal de frequ�ncia com varredura linear nas inst�ncias de tempo definidas em t_chirp. A frequ�ncia varia de 0 a f_chirp em 1 segundo.
        
    'Realizando medida sinal chirp'
    j
    
    putsample(ao,[0])                       % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_chirp])         % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                               % � necess�rio iniciar o AnalogOutput primeiro para
    start(ai)                               % que este aguarde o in�cio do AnalogInput
    
    [data_chirp,time] = getdata(ai);        % Retorna o resultado.
    
    stop([ai,ao])                           % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                       % Recoloca o AnalogOutput em zero

    data_chirp(:,1) = data_chirp(:,1)./r1;  % C�lculo da corrente em cada instante de tempo
                                            % dividindo-se o valor medido nos terminais do 
                                            % resistor pelo seu valor de resist�ncia.
                         
    if (mean(abs(data_chirp))>8e-006)       % Checa se houve sinal de resposta extra�do ou se os valores
                                            % lidos s�o iguais a zero (menor que 0.00008 - praticamente nulo).        
    
                                      
    corrente_chirp(:,(j+(i-1)*num_medidas)) = data_chirp(:,1);           % Caso n�o haja erro, guardar os resultados de corrente e sinal de excita��o medidos 
    sinal_excitacao_chirp(:,(j+(i-1)*num_medidas)) = data_chirp(:,2);    % nas vari�veis a serem utilizadas pelo programa de c�lculo de curvas de imped�ncia.


    else
        'Erro: leitura nula'
        j=j-1;
        erros = erros + 1;
        j
    end
    
    
    end
    
    % Ensaio Sinal Idinput
    
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    'Realizando medida sinal idinput'
    j
    
    putsample(ao,[0])                          % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_pseudrand_binario])     % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                                  % � necess�rio iniciar o AnalogOutput primeiro para
    start(ai)                                  % que este aguarde o in�cio do AnalogInput

    [data_idinput,time] = getdata(ai);         % Retorna o resultado.

    stop([ai,ao])                              % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                          % Recoloca o AnalogOutput em zero

    data_idinput(:,1) = data_idinput(:,1)./r1;  % C�lculo da corrente em cada instante de tempo
                                                % dividindo-se o valor medido nos terminais do 
                                                % resistor pelo seu valor de resist�ncia.
                                      
    if (mean(abs(data_idinput))>8e-006)         % Checa se houve sinal de resposta extra�do ou se os valores
                                                % lidos s�o iguais a zero (menor que 0.00008 - praticamente nulo).
        
    corrente_idinput(:,(j+(i-1)*num_medidas)) = data_idinput(:,1);          % Caso n�o haja erro, guardar os resultados de corrente e sinal de excita��o medidos 
    sinal_excitacao_idinput(:,(j+(i-1)*num_medidas) )= data_idinput(:,2);   % nas vari�veis a serem utilizadas pelo programa de c�lculo de curvas de imped�ncia.
                                                  
   
    else
        'Erro: leitura nula'
        j=j-1;
        erros = erros + 1;
        j
        
    end
    
    
    end    
    
    'Fim do ensaio n�mero:'
    i
    pause(2)                                    % Pausa de 2 segundos para leitura do ensaio atual no terminal enquanto a rotina � executada.
end

'N�mero de erros durante a execu��o:'
erros

'Todos os ensaios foram finalizados.'

uiwait(msgbox('Salve os dados do workspace em um arquivo *.mat','Programa de Aquisi��o de Dados','modal'));