require 'mysql2'
require 'mail'

# Configuração do Banco de Dados
DB_CONFIG = {
  host: 'localhost',
  username: 'seu_usuario',
  password: 'sua_senha',
  database: 'seu_banco_de_dados'
}

# Configuração do Email
MAIL_OPTIONS = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gmail.com',
  user_name:            'metereotech@gmail.com',
  password:             'senha_do_email_de_envio',
  authentication:       'plain',
  enable_starttls_auto: true
}

# Limiares críticos para cada variável
CRITICAL_THRESHOLDS = {
  temperatura: {min: 0, max: 35},
  umidade_solo: {min: 10, max: 80},
  umidade_ar: {min: 20, max: 90},
  luminosidade: {min: 100, max: 10000},
  pressao_atmosferica: {min: 980, max: 1030},
  qualidade_ar: {min: 0, max: 300}
}

# Conectar ao banco de dados
def db_client
  @db_client ||= Mysql2::Client.new(DB_CONFIG)
end

# Verificar condições críticas
def check_critical_conditions
  query = "SELECT variavel, valor FROM dados_meteorologicos WHERE data = CURDATE()"
  results = db_client.query(query)

  results.each do |row|
    variavel = row['variavel'].to_sym
    valor = row['valor'].to_f

    if CRITICAL_THRESHOLDS[variavel] && (valor < CRITICAL_THRESHOLDS[variavel][:min] || valor > CRITICAL_THRESHOLDS[variavel][:max])
      send_alert_email(variavel, valor)
    end
  end
end

# Enviar e-mail de alerta
def send_alert_email(variavel, valor)
  Mail.defaults do
    delivery_method :smtp, MAIL_OPTIONS
  end

  mail = Mail.new do
    from    'metereotech@gmail.com'
    to      'ricardofiorini@gmail.com'
    subject 'Alerta de Condição Crítica'
    body    "A variável #{variavel} atingiu um nível crítico: #{valor}. Verifique imediatamente!"
  end

  mail.deliver!
end

# Loop principal
loop do
  check_critical_conditions
  sleep(300) # Verifica a cada 5 minutos
end
