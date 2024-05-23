#include "DHTesp.h"
#include <Arduino.h>
#include <Wire.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <cfloat>
#include <time.h>
//#include "BluetoothSerial.h"



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
static unsigned int ultimoObtidoMillis = 0;
const unsigned int INTERVALO_OBTENCAO_HORA = 3600000;  // 1 hora em milissegundos

// Replace with your network credentials
const char* ssid     = "OnePlus6";
const char* password = "12345678";

// REPLACE with your Domain name and URL path or IP address with path
const char* serverName = "https://oantichifre.com/esp-post-data.php";

// Keep this API Key value to be compatible with the PHP code provided in the project page. 
String apiKeyValue = "tPmAT5Ab3j7F9";


// Pinos dos relés
const int rele1Pin = 17; //pino para o Relé 1
const int rele2Pin = 16; //pino para o Relé 2
const int rele3Pin = 15; //pino para o Relé 3
const int rele4Pin = 13; //pino para o Relé 4

bool rele1Estado = LOW; // Estado inicial do Relé 1
bool rele2Estado = LOW; // Estado inicial do Relé 2
bool rele3Estado = LOW; // Estado inicial do Relé 3
bool rele4Estado = LOW; // Estado inicial do Relé 4
bool redeDisponivel = false;

// Pino de Serial para o sensor DHT22

#define DHT_PIN 22

//Temperatura Máxima e Mínima

#define TEMP_MAX 27
#define TEMP_MIN 23

//Setup DHT
DHTesp dht;

//Bluetooth
//BluetoothSerial ESP_BT; 
//bool Override = false;
//int incoming;

// Pino do sensor LDR
const int ldrPin = 25;

// Pino conectado ao sensor de umidade do solo
const int soilMoisturePin = 32;

MovingAverageFilter FiltroTemp;
MovingAverageFilter FiltroUmid;
MovingAverageFilter FiltroLDR;
MovingAverageFilter FiltroUmidSolo;

void setup() {
  Serial.begin(115200);
  // WIFI
  WiFi.begin(ssid, password);
  Serial.println("Conectando");
  // Hora
  setupNTP();

  //Bluetooth
  //ESP_BT.begin("ESP32_Control");

  // Inicializa os pinos dos relés como saídas
  pinMode(rele1Pin, OUTPUT);
  pinMode(rele2Pin, OUTPUT);
  pinMode(rele3Pin, OUTPUT);
  pinMode(rele4Pin, OUTPUT);
  
  // Inicializa o sensor DHT22
  dht.setup(DHT_PIN, DHTesp::DHT22);
  
  // Inicializa o pino do sensor LDR como entrada
  pinMode(ldrPin, INPUT);

  // Inicializar o pino do sensor de umidade do solo como entrada
  pinMode(soilMoisturePin, INPUT);

  //inicialização dos filtors de passa-faixa
  TempAndHumidity newValues = dht.getTempAndHumidity();
  float temperatura = newValues.temperature;
  float umidade = newValues.humidity;
  float mediaUmid = FiltroUmid.add(umidade);
  float mediaTemp = FiltroTemp.add(temperatura);
  FiltroTemp.setBandpassThresholds(0,20.00);
  FiltroUmid.setBandpassThresholds(0,10.0);


}


void loop() {
  unsigned long currentMillis = millis();
/*
  if (ESP_BT.available()) 
    {
      incoming = ESP_BT.read(); //Read what we receive 

      // separate button ID from button value -> button ID is 10, 20, 30, etc, value is 1 or 0
      int button = floor(incoming / 10);
      int value = incoming % 10;
      
      switch (button) {
        case 1:  
          digitalWrite(rele1Pin, value);
          break;
        case 2:  
          digitalWrite(rele2Pin, value);
          break;
        case 3:  
          digitalWrite(rele3Pin, value);
          break;
        case 4:  
          digitalWrite(rele4Pin, value);
          break;
        case 5:  
          Override = value;
          break;
      }
    }
*/


  
  // loopDHT22: every 2 seconds
  static unsigned long lastDHT22Millis = 0;
  if (currentMillis - lastDHT22Millis >= 2000) {
    lastDHT22Millis = currentMillis;
    TempAndHumidity newValues = dht.getTempAndHumidity();
   
    if (dht.getStatus() != 0)
    {
    Serial.println("Erro na leitura do DHT22!");
    return;
    }

    float temperatura = newValues.temperature;
    float umidade = newValues.humidity;
    int estadoRele1 = digitalRead(rele1Pin);
    int estadoRele4 = digitalRead(rele4Pin);
    float mediaUmid = FiltroUmid.add(umidade);
    float mediaTemp = FiltroTemp.add(temperatura);

  
      // Controla o rele 1, Aquecedor
    //if(Override == false){
      if (mediaTemp < TEMP_MIN) {
        digitalWrite(rele1Pin, HIGH); // Liga o Relé 1
      } else {
        digitalWrite(rele1Pin, LOW); // Desliga o Relé 1
      }

      // Exemplo: Ligar o Relé 2 se a umidade estiver abaixo de 40%
      if (mediaUmid < 40) {
        digitalWrite(rele4Pin, HIGH); // Liga o Relé 2
      } else {
        digitalWrite(rele4Pin, LOW); // Desliga o Relé 2
      }
    //}
  }

  // loopLuminosidade_USolo: every 0.5 seconds
  static unsigned long lastLuminosidade_USoloMillis = 0;
  if (currentMillis - lastLuminosidade_USoloMillis >= 500) {
      lastLuminosidade_USoloMillis = currentMillis;
      // Le dados dos sensores (temperatura, umidade, luminosidade, estado dos relés)
      bool luminosidade = digitalRead(ldrPin);
      int estadoRele3 = digitalRead(rele3Pin);
      int estadoRele2 = digitalRead(rele2Pin);
      float umidadeSolo = linearizacaoSolo(analogRead(soilMoisturePin));
    
      float mediaLDR = FiltroLDR.add(luminosidade);
      float mediaUmidSolo = FiltroUmidSolo.add(umidadeSolo);
      
      // Exemplo: Ligar uma luz se a luminosidade for menor que um valor específico
      //if(Override == false){
      if (mediaLDR > 0.5) {
        // luminosidade é booleano
        digitalWrite(rele2Pin, HIGH); // Liga a luz 
      } else {
        digitalWrite(rele2Pin, LOW); // Desliga a luz
      }
      
      // Exemplo: Ligar o Relé 4 se a temperatura estiver acima de TEMP_MAX
      if (mediaUmidSolo < 50) {
        digitalWrite(rele3Pin, HIGH); // Liga o Relé 4
      } else {
        digitalWrite(rele3Pin, LOW); // Desliga o Relé 4
      }
    //}
  }

  // loopWIFI: every 4 seconds
  static unsigned long lastWIFIMillis = 0;
  if (currentMillis - lastWIFIMillis >= 10000) {
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
                          + "&temperature=" + String(mediaTemp) 
                          + "&humidity=" + String(mediaUmid) 
                          + "&soilMoisture=" + String(mediaUmidSolo) 
                          + "&luminosity=" + String(mediaLDR)
                          + "&date=" + obterDataAtual();

      // Send HTTP POST request
      int httpResponseCode = https.POST(httpRequestData);
      
      if (httpResponseCode>0) {
         String response = https.getString();
        Serial.print("HTTP Response code: ");
        Serial.println(response);
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


float linearizacaoSolo(float value) {
  // Verifica se o valor de entrada está no intervalo esperado
    if (value < 1000) value = 1000;
    if (value > 2700) value = 2700;

    // Lineariza o valor de forma invertida
    // Agora o cálculo é ajustado para a inversão
    int outputValue = (2700 - value) * 100 / (2700 - 1000);

    return outputValue;
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
