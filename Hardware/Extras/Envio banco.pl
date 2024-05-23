#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Configurações do banco de dados
my $host     = "localhost";
my $database = "seu_banco_de_dados";
my $username = "seu_usuario";
my $password = "sua_senha";

# Arquivo CSV gerado pelo COBOL
my $csv_file = "final.csv";

# Estabelecer conexão com o banco de dados
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host", $username, $password)
    or die "Não foi possível conectar ao banco de dados: $DBI::errstr";

# Abrir o arquivo CSV para leitura
open(my $fh, '<', $csv_file) or die "Não foi possível abrir o arquivo $csv_file: $!";

# Ignorar a primeira linha (cabeçalho)
<$fh>;

# Preparar a declaração SQL para inserção de dados
my $insert_stmt = $dbh->prepare("INSERT INTO tabela_dados (variavel, atual, media, minimo, maximo, previsao) VALUES (?, ?, ?, ?, ?, ?)");

# Ler o arquivo CSV e inserir os dados no banco de dados
while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(';', $line);

    # As variáveis estão agrupadas em conjuntos de cinco colunas por variável, removemos radiação solar
    while (my @data = splice(@fields, 0, 6)) {  # Assegure-se de que cada conjunto agora reflete a estrutura correta
        my ($variavel, $atual, $media, $minimo, $maximo, $previsao) = @data;
        $insert_stmt->execute($variavel, $atual, $media, $minimo, $maximo, $previsao);
    }
}

# Fechar o arquivo CSV e a conexão com o banco de dados
close($fh);
$insert_stmt->finish();
$dbh->disconnect();

print "Dados inseridos com sucesso no banco de dados.\n";
