<?php

// Configurações do banco de dados
$hostname = "Localhost";
$username = "id21214546_metereotech";
$password = "Metereotech/123";
$database = "id21214546_metereotech";

// Função para criar uma conexão com o banco de dados
function conectarBanco() {
    global $hostname, $username, $password, $database;
    $conn = new mysqli($hostname, $username, $password, $database);
    if ($conn->connect_error) {
        die("Falha na conexão com o banco de dados: " . $conn->connect_error);
    }
    return $conn;
}

// Função para executar uma consulta SQL e retornar os resultados como JSON
function consultarBanco($conn, $sql) {
    $result = $conn->query($sql);

    if (!$result) {
        die("Erro na consulta SQL: " . $conn->error);
    }

    $data = array();

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    return json_encode($data, JSON_UNESCAPED_SLASHES);
}

// Função para obter os dados de ontem
function obterDadosOntem() {
    $conn = conectarBanco();
    $dadosOntem = array();

    // Consulta SQL para obter os dados do dia de ontem
    $ontem = date('Y-m-d', strtotime('-1 day'));
    $sql = "SELECT * FROM `dados_antigos` WHERE datas = CURRENT_DATE - 1;";
    $result = $conn->query($sql);

    if (!$result) {
        die("Erro na consulta SQL: " . $conn->error);
    }

    // Obtém os resultados em um array associativo
    $row = $result->fetch_assoc();

    // Verifica se encontrou dados para ontem
    if ($row) {
        // Formate os dados de ontem como um objeto JSON
        $dadosOntem["ontem"] = $row;
    } else {
        // Se não houver dados para ontem, defina como um objeto JSON vazio
        $dadosOntem["ontem"] = json_encode(array());
    }

    $conn->close();

    return $dadosOntem;
}


// Função para obter os dados dos dias anteriores
function obterDadosDiasAnteriores() {
    $conn = conectarBanco();

    // Consulta SQL para obter os dados dos dias anteriores (limitando a 4 resultados)
    $ontem = date('Y-m-d', strtotime('-1 day'));
    $sql = "SELECT datas, temperatura, umidade, luminosidade, umidade_solo FROM dados_antigos WHERE datas < '$ontem' ORDER BY datas DESC LIMIT 4";
    $result = $conn->query($sql);

    if (!$result) {
        die("Erro na consulta SQL: " . $conn->error);
    }

    $data = array();

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    $conn->close();

    return json_encode($data, JSON_UNESCAPED_SLASHES);
}


// Função principal
function obterDados() {
    // Consulta SQL para recuperar os dados do banco de dados
    $conn = conectarBanco();
    $sql = "SELECT * FROM dados_atuais ORDER BY id DESC LIMIT 1"; // Obtém o último registro
    $dadosAtuais = consultarBanco($conn, $sql);

    // Chama as funções para obter os dados de ontem e dos dias anteriores
    $dadosOntem = obterDadosOntem();
    $dadosAnteriores = obterDadosDiasAnteriores();

    $conn->close();

    // Certifique-se de que $dadosOntem['ontem'] seja um objeto, não uma string JSON
    $dadosOntem = json_encode($dadosOntem["ontem"], JSON_UNESCAPED_SLASHES);
    
    $response = array(
        "dadosAtuais" => $dadosAtuais,
        "ontem" => $dadosOntem,
        "anteriores" => $dadosAnteriores
    );
    
    echo json_encode($response);
}


// Chama a função principal para obter os dados
obterDados();
?>