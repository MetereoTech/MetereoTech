function ligarRele(numero) {
  // Substitua 'SEU_ESP32_IP' pelo IP ou URL do ESP32
  const esp32URL = `http://SEU_ESP32_IP/ligar_rele?numero=${numero}`;

  return fetch(esp32URL)
    .then(response => {
      if (response.ok) {
        console.log(`Relé ${numero} ligado com sucesso.`);
        return { message: `Relé ${numero} ligado com sucesso.` };
      } else {
        console.error(`Falha ao ligar o Relé ${numero}.`);
        return { error: `Falha ao ligar o Relé ${numero}.` };
      }
    })
    .catch(error => {
      console.error(`Erro na solicitação: ${error}`);
      return { error: `Erro na solicitação: ${error}` };
    });
}

// Função para desligar um relé
function desligarRele(numero) {
  // Substitua 'SEU_ESP32_IP' pelo IP ou URL do ESP32
  const esp32URL = `http://SEU_ESP32_IP/desligar_rele?numero=${numero}`;

  return fetch(esp32URL)
    .then(response => {
      if (response.ok) {
        console.log(`Relé ${numero} desligado com sucesso.`);
        return { message: `Relé ${numero} desligado com sucesso.` };
      } else {
        console.error(`Falha ao desligar o Relé ${numero}.`);
        return { error: `Falha ao desligar o Relé ${numero}.` };
      }
    })
    .catch(error => {
      console.error(`Erro na solicitação: ${error}`);
      return { error: `Erro na solicitação: ${error}` };
    });
}


// Função para atualizar os dados do ESP32
function atualizarDados() {
  const dadosCache = localStorage.getItem('dadosESP32Cache');
  if (dadosCache) {
    // Se os dados estiverem em cache, atualize os elementos HTML com eles
    const data = JSON.parse(dadosCache);
    const dataAtuais = JSON.parse(data.dadosAtuais); // Analisa o JSON dos dados atuais
    document.getElementById('temperatura').textContent = dataAtuais[0].temperatura + '°C';
    document.getElementById('umidade').textContent = dataAtuais[0].umidade + '%';
    document.getElementById('luminosidade').textContent = dataAtuais[0].luminosidade;
    document.getElementById('umidadeSolo').textContent = dataAtuais[0].umidade_solo + '%';
  }
 // Fazer uma solicitação AJAX para o seu arquivo PHP que obtém os dados do ESP32
 fetch('site.php')
 .then(response => {
   if (!response.ok) {
     throw new Error(`Erro na solicitação HTTP: ${response.status}`);
   }
   return response.text(); // Alterado para obter o texto da resposta
 })
 .then(data => {
   const jsonData = JSON.parse(data); // Analisa o JSON
   const dataAtuais = JSON.parse(jsonData.dadosAtuais); // Analisa o JSON dos dados atuais

   // Atualizar os elementos HTML com os dados recebidos
   document.getElementById('temperatura').textContent = dataAtuais[0].temperatura + '°C';
   document.getElementById('umidade').textContent = dataAtuais[0].umidade + '%';
   document.getElementById('luminosidade').textContent = dataAtuais[0].luminosidade;
   document.getElementById('umidadeSolo').textContent = dataAtuais[0].umidade_solo + '%';
   localStorage.setItem('dadosESP32Cache', JSON.stringify(jsonData));
 })
 .catch(error => {
   console.error('Erro ao buscar os dados do ESP32:', error);
 });
}

// Função para atualizar os dados dos dias anteriores
function atualizarDadosDiasAnteriores() {
  fetch('site.php')
    .then(response => {
      if (!response.ok) {
        throw new Error(`Erro na solicitação HTTP: ${response.status}`);
      }
      return response.json(); // Alterado para obter o JSON da resposta
    })
    .then(jsonData => {
      console.log('Dados brutos da resposta JSON:', jsonData);

      const ontem = JSON.parse(jsonData.ontem); // Parse a string JSON em um objeto JavaScript
      const anteriores = JSON.parse(jsonData.anteriores);

      console.log('Dados de ontem:', ontem);
      console.log('Dados anteriores:', anteriores);

      document.getElementById('Ontem').textContent = ontem.datas;
      document.getElementById('temperaturaOntem').textContent = ontem.temperatura + '°C';
      document.getElementById('umidadeOntem').textContent = ontem.umidade + '%';
      document.getElementById('luminosidadeOntem').textContent = ontem.luminosidade;
      document.getElementById('umidadeSoloOntem').textContent = ontem.umidade_solo + '%';

      for (let i = 0; i < anteriores.length && i < 4; i++) {
        document.getElementById(`Data${i + 1}`).textContent = anteriores[i].datas;
        document.getElementById(`temperaturaAnterior${i + 1}`).textContent = anteriores[i].temperatura + '°C';
        document.getElementById(`umidadeAnterior${i + 1}`).textContent = anteriores[i].umidade + '%';
        document.getElementById(`luminosidadeAnterior${i + 1}`).textContent = anteriores[i].luminosidade;
        document.getElementById(`umidadeSoloAnterior${i + 1}`).textContent = anteriores[i].umidade_solo + '%';
      }
    })
    .catch(error => {
      console.error('Erro ao buscar os dados dos dias anteriores:', error);
    });
}


atualizarDados();
atualizarDadosDiasAnteriores();
// Chama as funções de atualização de dados periodicamente
setInterval(atualizarDados, 5000); // Atualize os dados do ESP32 a cada 5 segundos
setInterval(atualizarDadosDiasAnteriores, 600000); // Atualize os dados dos dias anteriores a cada 10 minutos