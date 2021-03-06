






% Ensaio SHM-EMI
% --------------

mensagem = helpdlg('Este programa ir� executar a rotina de extra��o de curvas de imped�ncia atrav�s do m�todo de imped�ncia eletromec�ncia. Aperte qualquer tecla na tela de comando para prosseguir com a rotina', 'Programa de ensaio SHM-EMI')

pause;
% Circuito: resistor simples
% Resistor utilizado na disserta��o de Mestrado: 470 ohms
% Sinal excita��o: chirp (zero a 30KHz e dura��o de 1s)
%                  aleat�rio (fun��o "randn" com zero de m�dia e 1 de vari�ncia)
%                  idinput

parametros = inputdlg({'Resist�ncia (ohms - default 470)','N�mero de ensaios (default 10)','N�mero medidas por ensaio (default 3)','N�mero de pontos sinal aleat�rio (default 250000)','Frequ�ncia m�xima sinal chirp (default 30000)'},'PAR�METROS') % Inserir valor dos par�metros

         
r1=str2num(parametros{1});           % Valor resist�ncia (proposta: 470)
pause
num_ensaios = parametros{2};         % N�mero de ensaios (proposta: 10)
num_ensaios = str2num(num_ensaios);
medidas = parametros{3};             % N�mero medidas por ensaio (proposta: 3)
medidas = str2num(medidas);
num_pontos_sinal = parametros{4};    % N�mero de pontos sinal aleat�rio (proposta: 250000)
num_pontos_sinal = str2num(num_pontos_sinal);
f_chirp = parametros{5};             % Frequ�ncia m�xima sinal chirp (proposta: 30000)
f_chirp = str2num(f_chirp);


filename = uigetfile('*.mat','CARREGAR SINAL IDINPUT');

load (filename)  %   Carregar o sinal de excita��o idinput gerado
                                      %   pela fun��o
                                      %   "idinput(250000,'PRBS',[0,1],[-1
                                      %   1])" [0,1] - 125 kHz / [0,0.36] -
                                      %   45 kHz

                                      
pause

% Configura��o DAQ

ao = analogoutput('nidaq','Dev2');   % SampleRate do DAQ em 250kHz.
ch_out = addchannel(ao,0);           % Garante que o tempo real de amostragem
ao.SampleRate = 250000;              % � compat�vel com o tempo programado
ao.TriggerType = 'HwDigital';        % no sinal chirp
ao.HwDigitalTriggerSource = 'PFI4';
ao                                 

                                   
ai = analoginput('nidaq','Dev2');
set(ai,'InputType','Differential'); % Configura o AnalogInput para modo Diferencial.
ch_in = addchannel(ai,2);
ai.SampleRate = 250000;
ai.SamplesPerTrigger = 250000;
ai.TriggerType = 'Immediate';
ai.ExternalTriggerDriveLine = 'PFI4';
ai
   

                   

for i=1:num_ensaios
    
    
    % Ensaio sinal aleat�rio
    
    j=0;
    while (j<medidas)
    j=j+1;
    
    sinal_excit_aleat = randn(num_pontos_sinal,1);
    sinal_excit_aleat = sinal_excit_aleat./(max(abs(sinal_excit_aleat)));

    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_aleat])    % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_aleat,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_aleat = data_aleat./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                      %  ent�o divide-se pela resist�ncia para achar a
                                      %  corrente.
    
    if (mean(abs(data_aleat))>8e-005)    % Checar se houve erro da medida
        
    out_aleat(:,(j+(i-1)*3))= data_aleat;
    in_aleat(:,(j+(i-1)*3))= sinal_excit_aleat;
        
    else
        j=j-1;
    end
                                      
    'Realizar nova medida'
    
    pause

    end
    
    
    % Ensaio sinal chirp
           
    j=0;
    while (j<medidas)
    j=j+1;
                                                         % Total de 250k amostras
    t_chirp = 0.000004:0.000004:1;                       % In�cio @ DC, 
    sinal_excit_chirp = (chirp(t_chirp,0,1,f_chirp))';   % De zero Hz at� 30kHz em t=1 sec

    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_chirp])    % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_chirp,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_chirp = data_chirp./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                      %  ent�o divide-se pela resist�ncia para achar a
                                      %  corrente.
                         
    if (mean(abs(data_chirp))>8e-005)    % Checar se houve erro da medida
        
    out_chirp(:,(j+(i-1)*3))= data_chirp;
    in_chirp(:,(j+(i-1)*3))= sinal_excit_chirp;

    else
        j=j-1;
    end
    
    'Realizar nova medida'
    
    pause

    end
    
    % Ensaio sinal idinput
    
    j=0;
    while (j<medidas)
    j=j+1;
    
    putsample(ao,[0])                  % Garante que o AnalogOutput come�a no zero

    putdata(ao,[sinal_excit_idinput_band125])  % Carrega o sinal teste no buffer do AnalogOutput

    start(ao)                          % � necess�rio iniciar o AnalogOutput primeiros para
    start(ai)                          % que este aguarde o in�cio do AnalogInput

    [data_idinput,time] = getdata(ai);   % Retorna o resultado.

    stop([ai,ao])                      % Finaliza o AnalogOutput e o AnalogInput

    putsample(ao,[0])                  % Recoloca o AnalogOutput em zero

    data_idinput = data_idinput./r1;      %  Como "data" � a tens�o entre os terminais do resistor,
                                          %  ent�o divide-se pela resist�ncia para achar a
                                          %  corrente.
                                      
    if (mean(abs(data_idinput))>8e-005)    % Checar se houve erro da medida
        
    out_idinput(:,(j+(i-1)*3))= data_idinput;
    in_idinput(:,(j+(i-1)*3))= sinal_excit_idinput_band125;

    else
        j=j-1;
    end
    
    'Realizar nova medida'
    
    pause

    end
    
       
    i
    
    'Fim das medidas. Modificar dano da barra.'
    
    pause

end

mensagem = helpdlg('Salve os dados do workspace em um arquivo *.mat', 'Programa de ensaio SHM-EMI')

pause
                                   
                                   
