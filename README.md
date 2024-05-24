# Projeto Estação Meteorológica

Este projeto envolve a construção de uma estação meteorológica completa, cobrindo aspectos de contabilidade, documentação, apresentação, hardware, design de case e banco de dados.

## Índice

1. [Contabilidade](#contabilidade)
2. [Documentação](#documentação)
3. [Apresentação](#apresentação)
4. [Hardware](#hardware)
5. [Case 3D](#case-3d)
6. [Banco de Dados](#banco-de-dados)

## Contabilidade

A contabilidade do projeto envolve o registro detalhado de todos os custos associados, incluindo preço de componentes, frete, impostos e outras despesas.

### Categorias de Despesas

- Componentes
- Software
- Desenvolvimento
- Manutenção

### Dados Financeiros

- **Descrição**: Detalhes da transação.
- **Data**: Data da transação.
- **Valor**: Quantia envolvida na transação.
- **Categoria**: Tipo de despesa ou receita (receita ou despesa).
- **Tipo**: Receita ou despesa.

## Documentação

A documentação abrange todos os aspectos técnicos e financeiros do projeto:

- **Banco de Dados**: Estrutura, relações, procedimentos armazenados, visões, materialized views, backups e recuperação.
- **Hardware**: Descrição dos componentes, esquemas elétricos e códigos de teste.
- **Software**: Código-fonte para Arduino e ESP32, configuração do MySQL, scripts de automação e backup.

## Apresentação

A apresentação cobre todos os aspectos da estação meteorológica, incluindo:

### Sensores Utilizados

- **MQ135**: Sensor de qualidade do ar.
- **0-40KPa**: Sensor barométrico de pressão.
- **LDR**: Sensor de luminosidade.
- **DHT22**: Sensor de temperatura e umidade do ar.
- **Sensor capacitivo**: Sensor de umidade do solo.

### Microcontroladores

- **Arduino**: Controla atuadores, como ventiladores e luzes, baseado nas variáveis medidas.
- **ESP32**: Coleta dados dos sensores e envia para um banco de dados MySQL.

### Software Programado

Scripts para coleta, processamento e armazenamento dos dados dos sensores.

## Hardware

### Componentes

- **Arduino**: Controla atuadores e executa ações baseadas nos dados dos sensores.
- **ESP32**: Coleta e envia dados para o banco de dados MySQL.
- **Sensores**: MQ135, 0-40KPa, LDR, DHT22, sensor capacitivo.

### Testes de Hardware

- **Arduino**: Testes de leitura de sensores e controle de atuadores.
- **ESP32**: Testes de comunicação e envio de dados.
- **Sensores**: Testes individuais para cada sensor.

## Case 3D

### Design da Case

A case foi projetada para abrigar todos os componentes com ventilação adequada, compacta e estética.

#### Características

- **Ventilação**: Furos de ventilação estilizados nas laterais.
- **Acesso Rápido**: Portas de acesso para manutenção.
- **Marcação dos Pinos**: Marcações em relevo próximas aos conectores.
- **Parafusos Ocultos**: Sistema de fixação oculto para um visual mais limpo.
- **Fechos Rápidos**: Fechos rápidos e ímãs para facilitar a abertura e fechamento.
- **Aletas de Resfriamento**: Pequenas aletas para dissipação de calor.
- **Alças de Transporte**: Alças embutidas para facilitar o transporte.
- **Cantoneiras Arredondadas**: Para melhorar a estética e reduzir o risco de danos.
- **Formato Aerodinâmico**: Linhas suaves e curvas para um visual moderno.

## Banco de Dados

O banco de dados MySQL é estruturado para armazenar todos os dados coletados pelos sensores, incluindo estatísticas e previsões.

### Estrutura

- **dados_sensores**: Armazena leituras dos sensores.
- **tipos_variaveis**: Descrição das variáveis medidas.
- **estatisticas_sensores**: Armazena estatísticas (média, máximo, mínimo) dos dados dos sensores.
- **previsoes_sensores**: Armazena previsões baseadas nos dados coletados.
- **categorias_financas**: Categorias para dados financeiros.
- **financas**: Registro de todas as transações financeiras.

### Procedimentos Armazenados

- **Simples**: Inserção e atualização de dados.
- **Intermediários**: Cálculo de estatísticas e previsões.
- **Avançados**: Otimização de consultas e integridade de dados.

### Visões e Materialized Views

Para facilitar consultas frequentes e melhorar o desempenho.

### Segurança e Backup

- **Controles de Concurrência**: Níveis de isolamento de transação e bloqueios.
- **Replicação**: Configuração do MySQL InnoDB Cluster para alta disponibilidade.
- **Backup e Recuperação**: Scripts de backup automático e procedimentos de recuperação.

### Triggers

Garantem integridade e segurança, como auditoria de alterações e atualizações automáticas de estatísticas.

## Conclusão
Este projeto da estação meteorológica é um sistema completo que abrange desde a coleta de dados ambientais até a análise financeira detalhada dos custos envolvidos. Utilizando uma combinação de hardware, software, e técnicas avançadas de banco de dados, o projeto proporciona uma solução robusta para monitoramento e análise ambiental. A documentação detalhada e a apresentação abrangente garantem que todos os aspectos do projeto sejam bem compreendidos e facilmente replicáveis.
