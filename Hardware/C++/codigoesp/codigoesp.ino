#include <Arduino.h>
#include <Wire.h>
#include <DHT12.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <cfloat>
#include <time.h>

// Filtro Média Móvel
class MovingAverageFilter {
public:
    MovingAverageFilter(int size = 10)
        : size(size), position(0), sum(0), full(false), lowerBandThreshold(-FLT_MAX), upperBandThreshold(FLT_MAX) {
        buffer = new float[size];
        for (int i = 0; i < size; i++) {
            buffer[i] = 0;
        }
    }

    ~MovingAverageFilter() {
        delete[] buffer;
    }

    float add(float value) {
        float currentAverage = (full) ? sum / size : sum / (position + 1);

        // Bandpass filter
        float difference = abs(value - currentAverage);
        if (difference < lowerBandThreshold || difference > upperBandThreshold) {
            value = currentAverage; // This could be set to another strategy if needed
        }

        if (full) {
            sum -= buffer[position];
        }
        
        sum += value;
        buffer[position] = value;

        position++;
        if (position >= size) {
            position = 0;
            full = true;
        }

        return currentAverage;
    }

    // Método adicionado para obter o valor médio atual
    float getAverage() const {
        return (full) ? sum / size : sum / (position + 1);
    }

    void setBandpassThresholds(float lowerThreshold, float upperThreshold) {
        lowerBandThreshold = lowerThreshold;
        upperBandThreshold = upperThreshold;
    }

    void disableBandpassFilter() {
        lowerBandThreshold = -FLT_MAX;
        upperBandThreshold = FLT_MAX;
    }

private:
    float* buffer;
    int size;
    int position;
    float sum;
    bool full;

    float lowerBandThreshold;
    float upperBandThreshold;
};


// Configuração de hora
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = -10800;    // Offset em segundos para sua zona de tempo local
const int   daylightOffset_sec = 0; // Ajuste para horário de verão, se necessário
static String ultimaHoraAtual = "";
static time_t ultimoTempoObtido = 0;
static unsigned long ultimoObtidoMillis = 0;
const unsigned long INTERVALO_OBTENCAO_HORA = 3600000;  // 1 hora em milissegundos

// Replace with your network credentials
const char* ssid     = "Wavica";
const char* password = "wag859702";

// REPLACE with your Domain name and URL path or IP address with path
const char* serverName = "https://meteorotech.000webhostapp.com/esp-post-data.php";

// Keep this API Key value to be compatible with the PHP code provided in the project page. 
// If you change the apiKeyValue value, the PHP file /post-esp-data.php also needs to have the same key 
String apiKeyValue = "tPmAT5Ab3j7F9";


// Pinos dos relés
const int rele1Pin = 12; //pino para o Relé 1
const int rele2Pin = 13; //pino para o Relé 2
const int rele3Pin = 14; //pino para o Relé 3
const int rele4Pin = 15; //pino para o Relé 4

bool rele1Estado = LOW; // Estado inicial do Relé 1
bool rele2Estado = LOW; // Estado inicial do Relé 2
bool rele3Estado = LOW; // Estado inicial do Relé 3
bool rele4Estado = LOW; // Estado inicial do Relé 4
bool redeDisponivel = false;

// Pino de I2C para o sensor DHT12

#define SDA_PIN 21
#define SCL_PIN 22

//Temperatura Máxima e Mínima

#define TEMP_MAX 27
#define TEMP_MIN 23

// Instantiate Wire for generic use at 400kHz
TwoWire I2Cone = TwoWire(0);
// Instantiate Wire for generic use at 100kHz
TwoWire I2Ctwo = TwoWire(1);

// Pino do sensor LDR
const int ldrPin = 25;

// Pino conectado ao sensor de umidade do solo
const int soilMoisturePin = 32;

MovingAverageFilter FiltroTemp;
MovingAverageFilter FiltroUmid;
MovingAverageFilter FiltroLDR;
MovingAverageFilter FiltroUmidSolo;
DHT12 dht12(&I2Ctwo, SDA_PIN, SCL_PIN);
//Preferences preferences;

void setup() {
  I2Cone.begin(21,22,9600); // Testar com I2Ctwo
  Serial.begin(115200);
  // WIFI
  WiFi.begin(ssid, password);
  Serial.println("Conectando");
  // Hora
  setupNTP();

  // Inicializa os pinos dos relés como saídas
  pinMode(rele1Pin, OUTPUT);
  pinMode(rele2Pin, OUTPUT);
  pinMode(rele3Pin, OUTPUT);
  pinMode(rele4Pin, OUTPUT);
  
  // Inicializa o sensor DHT12
  dht12.begin();
  
  // Inicializa o pino do sensor LDR como entrada
  pinMode(ldrPin, INPUT);

  // Inicializar o pino do sensor de umidade do solo como entrada
  pinMode(soilMoisturePin, INPUT);

  //inicialização dos filtors de passa-faixa
  FiltroTemp.setBandpassThresholds(1.00,1.00);
  FiltroUmid.setBandpassThresholds(0.5,0.5);
}


void loop() {
  unsigned long currentMillis = millis();

  // loopDHT12: every 2 seconds
  static unsigned long lastDHT12Millis = 0;
  /*if (currentMillis - lastDHT12Millis >= 4000) {
    lastDHT12Millis = currentMillis;
    float temperatura = lerTemperatura();
    float mediaTemp = FiltroTemp.add(temperatura);
    int estadoRele1 = digitalRead(rele1Pin);
    int estadoRele2 = digitalRead(rele2Pin);
    float umidade = lerUmidade();
    float mediaUmid = FiltroUmid.add(umidade);

    // Check if any reads failed and exit early (to try again).
    if (isnan(temperatura) || isnan(umidade)) 
    {
    Serial.println("Failed to read from DHT12 sensor!");
    }
    
      // Controla o rele 1, Aquecedor
    if (mediaTemp < TEMP_MIN) {
      digitalWrite(rele1Pin, HIGH); // Liga o Relé 1
      Serial.println(" Rele Aquecedor: Ligado ");
      Serial.print("Temperatura: ");
      Serial.print(mediaTemp);
    } else {
      digitalWrite(rele1Pin, LOW); // Desliga o Relé 1
      Serial.println(" Rele Aquecedor: Desligado");
      Serial.print("Temperatura: ");
      Serial.print(mediaTemp);
    }

    // Exemplo: Ligar o Relé 2 se a umidade estiver abaixo de 40%
    if (mediaUmid < 40) {
      digitalWrite(rele2Pin, HIGH); // Liga o Relé 2
      Serial.println(" Rele Umidade: Ligado ");
      Serial.print("Umidade: ");
      Serial.print(mediaTemp);
    } else {
      digitalWrite(rele2Pin, LOW); // Desliga o Relé 2
      Serial.println(" Rele Umidade: Desligado ");
      Serial.print("Umidade: ");
      Serial.print(mediaTemp);
    }
  }*/

  // loopLuminosidade_USolo: every 1 seconds
  static unsigned long lastLuminosidade_USoloMillis = 0;
  if (currentMillis - lastLuminosidade_USoloMillis >= 1000) {
    lastLuminosidade_USoloMillis = currentMillis;
    // Le dados dos sensores (temperatura, umidade, luminosidade, estado dos relés)
    bool luminosidade = lerLuminosidade();
    int estadoRele3 = digitalRead(rele3Pin);
    int estadoRele4 = digitalRead(rele4Pin);
    float umidadeSolo = linearizacaoSolo(lerUmidadeSolo());
  
    float mediaLDR = FiltroLDR.add(luminosidade);
    float mediaUmidSolo = FiltroUmidSolo.add(umidadeSolo);
    
    // Exemplo: Ligar uma luz se a luminosidade for menor que um valor específico
    if (mediaLDR > 0.5) {
      // luminosidade é booleano
      digitalWrite(rele3Pin, HIGH); // Liga a luz 
      Serial.println(" Rele Luz: Ligado");
    } else {
      digitalWrite(rele3Pin, LOW); // Desliga a luz
      Serial.println(" Rele Luz: Desligado");
    }
    
    // Exemplo: Ligar o Relé 4 se a temperatura estiver acima de TEMP_MAX
    if (mediaUmidSolo > 1800) {
      digitalWrite(rele4Pin, HIGH); // Liga o Relé 4
      Serial.println(" Rele Bomba: Ligado");
    } else {
      digitalWrite(rele4Pin, LOW); // Desliga o Relé 4
      Serial.println(" Rele Bomba: Desligado");
    }
  }

  // loopWIFI: every 4 seconds
  static unsigned long lastWIFIMillis = 0;
  if (currentMillis - lastWIFIMillis >= 4000) {
    lastWIFIMillis = currentMillis;
    float mediaTemp = FiltroTemp.getAverage();
    float mediaUmid = FiltroUmid.getAverage();
    float mediaUmidSolo = FiltroUmidSolo.getAverage();
    float mediaLDR = FiltroLDR.getAverage();
      //Check WiFi connection status
    if(WiFi.status()== WL_CONNECTED){
      WiFiClientSecure *client = new WiFiClientSecure;
      client->setInsecure(); //don't use SSL certificate
      HTTPClient https;
      
      // Your Domain name with URL path or IP address with path
      https.begin(*client, serverName);
      
      // Specify content-type header
      https.addHeader("Content-Type", "application/x-www-form-urlencoded");
      
      // Prepare your HTTP POST request data
    String httpRequestData = "api_key=" + apiKeyValue 
                          + "&temperature=" + String(0) 
                          + "&humidity=" + String(0) 
                          + "&soilMoisture=" + String(mediaUmidSolo) 
                          + "&luminosity=" + String(mediaLDR)
                          + "&date=" + obterDataAtual();
      Serial.print("httpRequestData: ");
      Serial.println(httpRequestData);
      
      // You can comment the httpRequestData variable above
      // then, use the httpRequestData variable below (for testing purposes without the BME280 sensor)
      //String httpRequestData = "api_key=tPmAT5Ab3j7F9&sensor=BME280&location=Office&value1=24.75&value2=49.54&value3=1005.14";

      // Send HTTP POST request
      int httpResponseCode = https.POST(httpRequestData);
      
      // If you need an HTTP request with a content type: text/plain
      //https.addHeader("Content-Type", "text/plain");
      //int httpResponseCode = https.POST("Hello, World!");
      
      // If you need an HTTP request with a content type: application/json, use the following:
      //https.addHeader("Content-Type", "application/json");
      //int httpResponseCode = https.POST("{\"value1\":\"19\",\"value2\":\"67\",\"value3\":\"78\"}");
      
      if (httpResponseCode>0) {
        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);
      }
      else {
        Serial.print("Error code: ");
        Serial.println(httpResponseCode);
      }
      // Free resources
      https.end();
    }
    else {
      Serial.println("WiFi Disconnected");
    }
  }
}

float lerTemperatura() {
  // Le a temperatura do DHT12
  float temperatura = dht12.readTemperature();
  return temperatura;
  }

float lerUmidade() {
  // Le a umidade do DHT12
  float umidade = dht12.readHumidity();
  return umidade;
  }

bool lerLuminosidade() {
  // Le a luminosidade do sensor LDR
  bool luminosidade = digitalRead(ldrPin);
  return luminosidade;
  }

float lerUmidadeSolo() {
  // Le a umidade do solo
  int umidadeSolo = analogRead(soilMoisturePin);
  return umidadeSolo;
}
float linearizacaoSolo(float value) {
    // Define the input range values
    const float input_min = 1000.0;
    const float input_max = 2700.0;

    // Define the output range values
    const float output_min = 0.0;
    const float output_max = 100.0;

    // Ensure the value is clamped to the input range
    if (value < input_min) value = input_min;
    if (value > input_max) value = input_max;

    // Linearly map the input value to the output range
    float output_value = output_min + ((float)(value - input_min) / (input_max - input_min)) * (output_max - output_min);

    return output_value;
}


void setupNTP() {
    configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
}

String obterDataAtual() {
    unsigned long currentMillis = millis();
    if (currentMillis - ultimoObtidoMillis >= INTERVALO_OBTENCAO_HORA || ultimoObtidoMillis == 0) {
        struct tm timeinfo;
        if (!getLocalTime(&timeinfo)) {
            return "Failed to obtain time";
        }
        ultimoTempoObtido = mktime(&timeinfo);
        ultimoObtidoMillis = currentMillis;
    } else {
        unsigned long offsetSec = (currentMillis - ultimoObtidoMillis) / 1000;
        ultimoTempoObtido += offsetSec;
        ultimoObtidoMillis += offsetSec * 1000;
    }
    
    struct tm timeinfo;
    localtime_r(&ultimoTempoObtido, &timeinfo);
    char buffer[26];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
    return String(buffer);
}
