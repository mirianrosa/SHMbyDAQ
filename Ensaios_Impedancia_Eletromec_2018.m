% Programa de Aquisição de Dados por Impedância Eletromecânica (Ensaios)
% Autor: Luis Antonio Lopes / Modificado por: Mirian Rosa e Julio Almeida
% -------------------------------------------------------------------------

uiwait(msgbox('Este programa irá executar a rotina de extração de dados através do método de impedância eletromecânica para posterior cálculo de curvas. Clique em OK para prosseguir com a rotina.','Programa de Aquisição de Dados','modal'));

% O circuito consiste em um transdutor piezoelétrico em série com um
% resistor simples, cuja tensão (VR) será medida pelo NI DAQ USB-6211
% enquanto o piezoelétrico está acoplado à estrutura a ser analizada,
% com o objetivo de se descobrir a corrente total do circuito enquanto
% o USB-6211 o excita com diferentes sinais de entrada para, posterior-
% mente, calcular-se as curvas de impedância da estrutura.

% Sinais de excitação:
% - chirp (sinal de frequência que varia de zero a 30KHz e tem duração de 1s)
% - aleatório (sinal gerado pela função "randn" com zero de média e 1 de variância)
% - idinput (sinal pseudoaleatório binário previamente gerado pela função "idinput")
% Resistor proposto: 
% - 500 Ohms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definição de parâmetros

prompt = {'Resistência (valor real, em \Omega):','Número de ensaios:','Número de medidas por ensaio:','Número de pontos do sinal aleatório:','Frequência máxima do sinal chirp:'};
title = 'Parâmetros';
definput = {'518.6','10','3','250000','30000'}; % Padrões definidos, respectivamente, para a resistência, número de ensaios e número de medidas por ensaio.
opts.Interpreter = 'tex'; % Interpretador para o símbolo de Ohms (\Omega).
parametros = inputdlg(prompt,title,[1 45],definput,opts) % Entrada de parâmetros, tendo os padrões já escritos como opção.

r1 = str2double(parametros{1});             % Atribuição dos parâmetros
r1                                          % indicados manualmente para
num_ensaios = str2double(parametros{2});    % variáveis.
num_ensaios
num_medidas = str2double(parametros{3});
num_medidas
num_pontos_sinal = str2double(parametros{4});
num_pontos_sinal
f_chirp = str2double(parametros{5});
f_chirp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configuração DAQ

ao = analogoutput('nidaq','Dev2');   % Analogoutput cria um objeto analogoutput associado com o NIDAQ USB-6211, com sua identificação. Checar se a identificação do DAQ no "Measurement & Automation Explorer" da National Instruments é "Dev2". Caso negativo, renomear.
ch_out = addchannel(ao,0);           % Aloca a porta AO0 do DAQ (alimentação do circuito)
ao.SampleRate = 250000;              % SampleRate do DAQ em 250kHz para garantir que o tempo real de amostragem seja compatível com o tempo programado no sinal chirp.
ao.TriggerType = 'HwDigital';        
ao.HwDigitalTriggerSource = 'PFI4'; 
ao                                 

                                   
ai = analoginput('nidaq','Dev2');    % Analoginput cria um objeto analoginput associado com o NIDAQ USB-6211, com sua identificação.
set(ai,'InputType','Differential');  % Configura o AnalogInput para modo Diferencial (a diferença de um ponto a outro, pois os dois canais utilizados são pontos flutuantes)
ch_in = addchannel(ai,2);            % Aloca a porta AI2 do DAQ (terminais do resistor)
ai.SampleRate = 250000;
ai.SamplesPerTrigger = 250000;
ai.TriggerType = 'Immediate';
ai.ExternalTriggerDriveLine = 'PFI4';
ai

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
% Aquisição de Dados

load ('sinal_excit_idinput_band125.mat')
% Carrega automaticamente o sinal de excitação idinput que precisa estar na mesma 
% pasta e diretório deste código-base.

% No caso de não existir o arquivo, gerar um novo sinal atráves da Command Window
% sinal_pseudrand_binario = idinput(250000,'PRBS',[0,1],[-1 1])
% e salvar a nova variável (in Workspace) com o nome sinal_excit_idinput_band125.mat
% no mesmo diretório deste código-base.
         
for i=1:num_ensaios
    
    
    % Ensaio Sinal Aleatório
    
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    sinal_excit_aleat = randn(num_pontos_sinal,1);
    sinal_excit_aleat = sinal_excit_aleat./(max(abs(sinal_excit_aleat)));

    'Realizando medida sinal aleatório'
    j
    
    putsample(ao,[0])                       % Garante que o AnalogOutput começa no zero

    putdata(ao,[sinal_excit_aleat])         % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                               % É necessário iniciar o AnalogOutput primeiro para
    start(ai)                               % que este aguarde o início do AnalogInput

    [data_aleat,time] = getdata(ai);        % Retorna o resultado

    stop([ai,ao])                           % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                       % Recoloca o AnalogOutput em zero

    data_aleat = data_aleat./r1;            %  Como "data" é a tensão entre os terminais do resistor,
                                            %  então divide-se pela resistência para achar a
                                            %  corrente.
    
                                            
    if (mean(abs(data_aleat))>8e-005)       % Checa se houve sinal de resposta extraído ou se os valores
                                            % lidos são iguais a zero (menor que 0.00008 - praticamente nulo).
                                            
    out_aleat(:,(j+(i-1)*num_medidas))= data_aleat;         % Caso não haja erro, guardar os sinais de entrada e saída nas variáveis a serem utilizadas 
    in_aleat(:,(j+(i-1)*num_medidas))= sinal_excit_aleat;   % pelo programa de cálculo de curvas de impedância.
        
    else
        'Erro: leitura nula'
        j=j-1;
        j
    end
                                      
    end
    
    
    % Ensaio Sinal Chirp
           
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    t_chirp = 0.000004:0.000004:1;                       % Totaliza 250k intervalos de tempo em um segundo.
    sinal_excit_chirp = (chirp(t_chirp,0,1,f_chirp))';   % Gera amostras de sinal de frequência com varredura linear nas instâncias de tempo definidas em t_chirp. A frequência varia de 0 a f_chirp em 1 segundo.
        
    'Realizando medida sinal chirp'
    j
    
    putsample(ao,[0])                  % Garante que o AnalogOutput começa no zero

    putdata(ao,[sinal_excit_chirp])    % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % É necessário iniciar o AnalogOutput primeiro para
    start(ai)                          % que este aguarde o início do AnalogInput

    [data_chirp,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_chirp = data_chirp./r1;       %  Como "data" é a tensão entre os terminais do resistor,
                                       %  então divide-se pela resistência para achar a
                                       %  corrente.
                         
    if (mean(abs(data_chirp))>8e-005)  % Checa se houve sinal de resposta extraído ou se os valores
                                       % lidos são iguais a zero (menor que 0.00008 - praticamente nulo).        
    
                                      
    out_chirp(:,(j+(i-1)*num_medidas))= data_chirp;         % Caso não haja erro, guardar os sinais de entrada e saída nas variáveis a serem utilizadas 
    in_chirp(:,(j+(i-1)*num_medidas))= sinal_excit_chirp;   % pelo programa de cálculo de curvas de impedÂncia.

    else
        'Erro: leitura nula'
        j=j-1;
        j
    end

    end
    
    % Ensaio Sinal Idinput
    
    j=0;
    while (j<num_medidas)
    j=j+1;
    
    'Realizando medida sinal idinput'
    j
    
    putsample(ao,[0])                          % Garante que o AnalogOutput começa no zero

    putdata(ao,[sinal_excit_idinput_band125])  % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                                  % É necessário iniciar o AnalogOutput primeiro para
    start(ai)                                  % que este aguarde o início do AnalogInput

    [data_idinput,time] = getdata(ai);         % Retorna o resultado.

    stop([ai,ao])                              % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                          % Recoloca o AnalogOutput em zero

    data_idinput = data_idinput./r1;           %  Como "data" é a tensão entre os terminais do resistor,
                                               %  então divide-se pela resistência para achar a
                                               %  corrente.
                                      
    if (mean(abs(data_idinput))>8e-005)        % Checa se houve sinal de resposta extraído ou se os valores
                                               % lidos são iguais a zero (menor que 0.00008 - praticamente nulo).
        
    out_idinput(:,(j+(i-1)*num_medidas))= data_idinput;                 % Caso não haja erro, guardar os sinais de entrada e saída 
    in_idinput(:,(j+(i-1)*num_medidas))= sinal_excit_idinput_band125;   % nas variáveis a serem utilizadas pelo programa de cálculo de curvas de impedância.
    
                                                   
   
    else
        'Erro: leitura nula'
        j=j-1;
        j
        
    end
    
    end    
    
    'Fim do ensaio número:'
    i
    pause(2)    % Pausa de 2 segundos para leitura do ensaio atual no terminal enquanto a rotina é executada.
end

'Todos os ensaios foram finalizados.'

uiwait(msgbox('Salve os dados do workspace em um arquivo *.mat','Programa de Aquisição de Dados','modal'));
                                   
