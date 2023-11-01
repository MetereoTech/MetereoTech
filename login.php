<?php
session_start();

// Configurações do banco de dados
$hostname = "Localhost";
$username = "id21214546_metereotech";
$password = "Metereotech/123";
$database = "id21214546_metereotech";

// Cria uma conexão com o banco de dados
$mysqli = new mysqli($hostname, $username, $password, $database);

// Verifica a conexão
if ($mysqli->connect_error) {
    die("Erro na conexão com o banco de dados: " . $mysqli->connect_error);
}

// Verifica se o formulário foi submetido
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST["email"];
    $senha = $_POST["password"];

    // Consulta SQL usando uma consulta preparada
    $sql = "SELECT * FROM usuario WHERE email = ? AND senha = ?";
    $stmt = $mysqli->prepare($sql);

    if ($stmt === false) {
        echo json_encode(array("status" => false, "message" => "Erro na preparação da consulta: " . $mysqli->error));
        exit();
    }

    $stmt->bind_param("ss", $email, $senha);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result === false) {
        echo json_encode(array("status" => false, "message" => "Erro na execução da consulta: " . $stmt->error));
        exit();
    }

    if ($result->num_rows == 1) {
        // O login foi bem-sucedido, inicie a sessão
        $_SESSION['authenticated'] = true;
        echo json_encode(array("status" => true, "message" => "Login bem-sucedido."));
    } else {
        // Login falhou
        echo json_encode(array("status" => false, "message" => "Credenciais inválidas. Tente novamente."));
    }

    $stmt->close();
}

// Fecha a conexão com o banco de dados
$mysqli->close();
?>
