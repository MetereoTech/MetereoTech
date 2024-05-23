program MetereoTech;

uses
  MySQL4Pascal; // Exemplo fictício, use a unidade apropriada para seu banco de dados

var
  umidadeSolo, umidadeAr, temperatura, luminosidade, pressaoAtmosferica, radiacaoSolar, qualidadeAr: real;
  data: string;

procedure ProcessarDados(umidadeSolo, umidadeAr, temperatura, luminosidade, pressaoAtmosferica, radiacaoSolar, qualidadeAr: real);
var
  totalRegistros: integer;
  somaUmidadeSolo, somaUmidadeAr, somaTemperatura, somaLuminosidade, somaPressaoAtmosferica, somaRadiacaoSolar, somaQualidadeAr: real;
begin
  // Inicialize os acumuladores e contadores
  totalRegistros := 0;
  somaUmidadeSolo := 0;
  somaUmidadeAr := 0;
  somaTemperatura := 0;
  somaLuminosidade := 0;
  somaPressaoAtmosferica := 0;
  somaRadiacaoSolar := 0;
  somaQualidadeAr := 0;

  // Somar os valores de cada variável
  somaUmidadeSolo := somaUmidadeSolo + umidadeSolo;
  somaUmidadeAr := somaUmidadeAr + umidadeAr;
  somaTemperatura := somaTemperatura + temperatura;
  somaLuminosidade := somaLuminosidade + luminosidade;
  somaPressaoAtmosferica := somaPressaoAtmosferica + pressaoAtmosferica;
  somaRadiacaoSolar := somaRadiacaoSolar + radiacaoSolar;
  somaQualidadeAr := somaQualidadeAr + qualidadeAr;

  // Incrementar o contador de registros
  Inc(totalRegistros);

  // Calcular as médias
  mediaUmidadeSolo := somaUmidadeSolo / totalRegistros;
  mediaUmidadeAr := somaUmidadeAr / totalRegistros;
  mediaTemperatura := somaTemperatura / totalRegistros;
  mediaLuminosidade := somaLuminosidade / totalRegistros;
  mediaPressaoAtmosferica := somaPressaoAtmosferica / totalRegistros;
  mediaRadiacaoSolar := somaRadiacaoSolar / totalRegistros;
  mediaQualidadeAr := somaQualidadeAr / totalRegistros;

  // Definir os mínimos como o valor atual se for o primeiro registro ou atualizar se for menor que o mínimo atual
  if totalRegistros = 1 then
  begin
    minUmidadeSolo := umidadeSolo;
    minUmidadeAr := umidadeAr;
    minTemperatura := temperatura;
    minLuminosidade := luminosidade;
    minPressaoAtmosferica := pressaoAtmosferica;
    minRadiacaoSolar := radiacaoSolar;
    minQualidadeAr := qualidadeAr;
  end
  else
  begin
    if umidadeSolo < minUmidadeSolo then
      minUmidadeSolo := umidadeSolo;
    if umidadeAr < minUmidadeAr then
      minUmidadeAr := umidadeAr;
    if temperatura < minTemperatura then
      minTemperatura := temperatura;
    if luminosidade < minLuminosidade then
      minLuminosidade := luminosidade;
    if pressaoAtmosferica < minPressaoAtmosferica then
      minPressaoAtmosferica := pressaoAtmosferica;
    if radiacaoSolar < minRadiacaoSolar then
      minRadiacaoSolar := radiacaoSolar;
    if qualidadeAr < minQualidadeAr then
      minQualidadeAr := qualidadeAr;
  end;

 begin
  // Atualizar os máximos se o valor atual for maior que o máximo atual
  if umidadeSolo > maxUmidadeSolo then
    maxUmidadeSolo := umidadeSolo;
  if umidadeAr > maxUmidadeAr then
    maxUmidadeAr := umidadeAr;
  if temperatura > maxTemperatura then
    maxTemperatura := temperatura;
  if luminosidade > maxLuminosidade then
    maxLuminosidade := luminosidade;
  if pressaoAtmosferica > maxPressaoAtmosferica then
    maxPressaoAtmosferica := pressaoAtmosferica;
  if radiacaoSolar > maxRadiacaoSolar then
    maxRadiacaoSolar := radiacaoSolar;
  if qualidadeAr > maxQualidadeAr then
    maxQualidadeAr := qualidadeAr;
 end
 

  // Saída dos resultados
  writeln('Resultados para a data: ', data);
  writeln('----------------------------------');
  writeln('Médias:');
  writeln('Umidade do Solo: ', mediaUmidadeSolo:0:2);
  writeln('Umidade do Ar: ', mediaUmidadeAr:0:2);
  writeln('Temperatura: ', mediaTemperatura:0:2);
  writeln('Luminosidade: ', mediaLuminosidade:0:2);
  writeln('Pressão Atmosférica: ', mediaPressaoAtmosferica:0:2);
  writeln('Radiação Solar: ', mediaRadiacaoSolar:0:2);
  writeln('Qualidade do Ar: ', mediaQualidadeAr:0:2);
  writeln('----------------------------------');
  writeln('Mínimos:');
  writeln('Umidade do Solo: ', minUmidadeSolo:0:2);
  writeln('Umidade do Ar: ', minUmidadeAr:0:2);
  writeln('Temperatura: ', minTemperatura:0:2);
  writeln('Luminosidade: ', minLuminosidade:0:2);
  writeln('Pressão Atmosférica: ', minPressaoAtmosferica:0:2);
  writeln('Radiação Solar: ', minRadiacaoSolar:0:2);
  writeln('Qualidade do Ar: ', minQualidadeAr:0:2);
  writeln('----------------------------------');
  writeln('Máximos:');
  writeln('Umidade do Solo: ', maxUmidadeSolo:0:2);
  writeln('Umidade do Ar: ', maxUmidadeAr:0:2);
  writeln('Temperatura: ', maxTemperatura:0:2);
  writeln('Luminosidade: ', maxLuminosidade:0:2);
  writeln('Pressão Atmosférica: ', maxPressaoAtmosferica:0:2);
  writeln('Radiação Solar: ', maxRadiacaoSolar:0:2);
  writeln('Qualidade do Ar: ', maxQualidadeAr:0:2);
  writeln('----------------------------------');

  // Salvando os resultados em um arquivo CSV
  AssignFile(arquivoCSV, 'resultados.csv');
  Rewrite(arquivoCSV);

  writeln(arquivoCSV, 'Variável,Média,Mínimo,Máximo');
  writeln(arquivoCSV, 'Umidade do Solo,', mediaUmidadeSolo:0:2, ',', minUmidadeSolo:0:2, ',', maxUmidadeSolo:0:2);
  writeln(arquivoCSV, 'Umidade do Ar,', mediaUmidadeAr:0:2, ',', minUmidadeAr:0:2, ',', maxUmidadeAr:0:2);
  writeln(arquivoCSV, 'Temperatura,', mediaTemperatura:0:2, ',', minTemperatura:0:2, ',', maxTemperatura:0:2);
  writeln(arquivoCSV, 'Luminosidade,', mediaLuminosidade:0:2, ',', minLuminosidade:0:2, ',', maxLuminosidade:0:2);
  writeln(arquivoCSV, 'Pressão Atmosférica,', mediaPressaoAtmosferica:0:2, ',', minPressaoAtmosferica:0:2, ',', maxPressaoAtmosferica:0:2);
  writeln(arquivoCSV, 'Radiação Solar,', mediaRadiacaoSolar:0:2, ',', minRadiacaoSolar:0:2, ',', maxRadiacaoSolar:0:2);
  writeln(arquivoCSV, 'Qualidade do Ar,', mediaQualidadeAr:0:2, ',', minQualidadeAr:0:2, ',', maxQualidadeAr:0:2);

  // Fechando o arquivo CSV
  CloseFile(arquivoCSV);
end;


end;


begin
  // Estabelecer conexão com o banco de dados na web
  MySQLConnect('localhost', 'usuario', 'senha', 'meubanco');

  // Solicitar ao usuário a data para recuperar os dados
  writeln('Digite a data para recuperar os dados (no formato YYYY-MM-DD):');
  readln(data);

  // Executar consultas SQL para recuperar os dados de cada variável para a data específica
  umidadeSolo := MySQLQuery('SELECT umidade_solo FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  umidadeAr := MySQLQuery('SELECT umidade_ar FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  temperatura := MySQLQuery('SELECT temperatura FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  luminosidade := MySQLQuery('SELECT luminosidade FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  pressaoAtmosferica := MySQLQuery('SELECT pressao_atmosferica FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  radiacaoSolar := MySQLQuery('SELECT radiacao_solar FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');
  qualidadeAr := MySQLQuery('SELECT qualidade_ar FROM dados_meteorologicos WHERE data >= "' + data + ' 00:00:00" AND data < "' + data + ' 23:59:59"');

  // Fechar a conexão com o banco de dados
  MySQLDisconnect;

  // Processar os dados recuperados
  // Aqui você pode chamar a função de processamento de dados e passar os valores recuperados como parâmetros
  ProcessarDados(umidadeSolo, umidadeAr, temperatura, luminosidade, pressaoAtmosferica, radiacaoSolar, qualidadeAr);

end.

// Codigo novo

program MetereoTech;

uses
  SysUtils, MySQL4Pascal, DateUtils; // Inclui SysUtils para manipulação de data/hora e DateUtils para funções de data

var
  umidadeSolo, umidadeAr, temperatura, luminosidade, pressaoAtmosferica, qualidadeAr: real;
  totalRegistros: integer;
  somaUmidadeSolo, somaUmidadeAr, somaTemperatura, somaLuminosidade, somaPressaoAtmosferica, somaQualidadeAr: real;
  minUmidadeSolo, minUmidadeAr, minTemperatura, minLuminosidade, minPressaoAtmosferica, minQualidadeAr: real;
  maxUmidadeSolo, maxUmidadeAr, maxTemperatura, maxLuminosidade, maxPressaoAtmosferica, maxQualidadeAr: real;
  arquivoCSV: TextFile;

procedure InicializarVariaveis;
begin
  totalRegistros := 0;
  somaUmidadeSolo := 0;
  somaUmidadeAr := 0;
  somaTemperatura := 0;
  somaLuminosidade := 0;
  somaPressaoAtmosferica := 0;
  somaQualidadeAr := 0;
  minUmidadeSolo := High(Real);
  minUmidadeAr := High(Real);
  minTemperatura := High(Real);
  minLuminosidade := High(Real);
  minPressaoAtmosferica := High(Real);
  minQualidadeAr := High(Real);
  maxUmidadeSolo := Low(Real);
  maxUmidadeAr := Low(Real);
  maxTemperatura := Low(Real);
  maxLuminosidade := Low(Real);
  maxPressaoAtmosferica := Low(Real);
  maxQualidadeAr := Low(Real);
end;

procedure ProcessarDados;
var
  data: string;
begin
  data := FormatDateTime('yyyy-mm-dd', Now); // Ajusta a data para hoje
  MySQLConnect('localhost', 'usuario', 'senha', 'meubanco');

  try
    umidadeSolo := MySQLQuery('SELECT umidade_solo FROM dados_meteorologicos WHERE data = "' + data + '"');
    umidadeAr := MySQLQuery('SELECT umidade_ar FROM dados_meteorologicos WHERE data = "' + data + '"');
    temperatura := MySQLQuery('SELECT temperatura FROM dados_meteorologicos WHERE data = "' + data + '"');
    luminosidade := MySQLQuery('SELECT luminosidade FROM dados_meteorologicos WHERE data = "' + data + '"');
    pressaoAtmosferica := MySQLQuery('SELECT pressao_atmosferica FROM dados_meteorologicos WHERE data = "' + data + '"');
    qualidadeAr := MySQLQuery('SELECT qualidade_ar FROM dados_meteorologicos WHERE data = "' + data + '"');

    // Acumula valores e incrementa contador
    Inc(totalRegistros);
    somaUmidadeSolo := somaUmidadeSolo + umidadeSolo;
    somaUmidadeAr := somaUmidadeAr + umidadeAr;
    somaTemperatura := somaTemperatura + temperatura;
    somaLuminosidade := somaLuminosidade + luminosidade;
    somaPressaoAtmosferica := somaPressaoAtmosferica + pressaoAtmosferica;
    somaQualidadeAr := somaQualidadeAr + qualidadeAr;
    
    // Calcular as médias
    mediaUmidadeSolo := somaUmidadeSolo / totalRegistros;
    mediaUmidadeAr := somaUmidadeAr / totalRegistros;
    mediaTemperatura := somaTemperatura / totalRegistros;
    mediaLuminosidade := somaLuminosidade / totalRegistros;
    mediaPressaoAtmosferica := somaPressaoAtmosferica / totalRegistros;
    mediaQualidadeAr := somaQualidadeAr / totalRegistros;

    // Atualiza mínimos e máximos
    minUmidadeSolo := Min(minUmidadeSolo, umidadeSolo);
    minUmidadeAr := Min(minUmidadeAr, umidadeAr);
    minTemperatura := Min(minTemperatura, temperatura);
    minLuminosidade := Min(minLuminosidade, luminosidade);
    minPressaoAtmosferica := Min(minPressaoAtmosferica, pressaoAtmosferica);
    minQualidadeAr := Min(minQualidadeAr, qualidadeAr);

    maxUmidadeSolo := Max(maxUmidadeSolo, umidadeSolo);
    maxUmidadeAr := Max(maxUmidadeAr, umidadeAr);
    maxTemperatura := Max(maxTemperatura, temperatura);
    maxLuminosidade := Max(maxLuminosidade, luminosidade);
    maxPressaoAtmosferica := Max(maxPressaoAtmosferica, pressaoAtmosferica);
    maxQualidadeAr := Max(maxQualidadeAr, qualidadeAr);
    
    // Saída dos resultados
    writeln('Resultados para a data: ', data);
    writeln('----------------------------------');
    writeln('Médias:');
    writeln('Umidade do Solo: ', mediaUmidadeSolo:0:2);
    writeln('Umidade do Ar: ', mediaUmidadeAr:0:2);
    writeln('Temperatura: ', mediaTemperatura:0:2);
    writeln('Luminosidade: ', mediaLuminosidade:0:2);
    writeln('Pressão Atmosférica: ', mediaPressaoAtmosferica:0:2);
    writeln('Qualidade do Ar: ', mediaQualidadeAr:0:2);
    writeln('----------------------------------');
    writeln('Mínimos:');
    writeln('Umidade do Solo: ', minUmidadeSolo:0:2);
    writeln('Umidade do Ar: ', minUmidadeAr:0:2);
    writeln('Temperatura: ', minTemperatura:0:2);
    writeln('Luminosidade: ', minLuminosidade:0:2);
    writeln('Pressão Atmosférica: ', minPressaoAtmosferica:0:2);
    writeln('Qualidade do Ar: ', minQualidadeAr:0:2);
    writeln('----------------------------------');
    writeln('Máximos:');
    writeln('Umidade do Solo: ', maxUmidadeSolo:0:2);
    writeln('Umidade do Ar: ', maxUmidadeAr:0:2);
    writeln('Temperatura: ', maxTemperatura:0:2);
    writeln('Luminosidade: ', maxLuminosidade:0:2);
    writeln('Pressão Atmosférica: ', maxPressaoAtmosferica:0:2);
    writeln('Qualidade do Ar: ', maxQualidadeAr:0:2);
    writeln('----------------------------------');

    AssignFile(arquivoCSV, 'resultados.csv');
    if FileExists('resultados.csv') then
      Append(arquivoCSV)
    else
      Rewrite(arquivoCSV);

    // Escreve os resultados calculados no arquivo CSV
    writeln(arquivoCSV, 'Variável,Média,Mínimo,Máximo');
    writeln(arquivoCSV, 'Umidade do Solo,', mediaUmidadeSolo:0:2, ',', minUmidadeSolo:0:2, ',', maxUmidadeSolo:0:2);
    writeln(arquivoCSV, 'Umidade do Ar,', mediaUmidadeAr:0:2, ',', minUmidadeAr:0:2, ',', maxUmidadeAr:0:2);
    writeln(arquivoCSV, 'Temperatura,', mediaTemperatura:0:2, ',', minTemperatura:0:2, ',', maxTemperatura:0:2);
    writeln(arquivoCSV, 'Luminosidade,', mediaLuminosidade:0:2, ',', minLuminosidade:0:2, ',', maxLuminosidade:0:2);
    writeln(arquivoCSV, 'Pressão Atmosférica,', mediaPressaoAtmosferica:0:2, ',', minPressaoAtmosferica:0:2, ',', maxPressaoAtmosferica:0:2);
    writeln(arquivoCSV, 'Qualidade do Ar,', mediaQualidadeAr:0:2, ',', minQualidadeAr:0:2, ',', maxQualidadeAr:0:2);
    CloseFile(arquivoCSV);
  finally
    MySQLDisconnect;
  end;
end;

begin
  InicializarVariaveis;
  while True do
  begin
    ProcessarDados;
  end;
end.

