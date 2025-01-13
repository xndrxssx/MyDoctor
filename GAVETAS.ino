#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// Configurações de rede Wi-Fi
const char* ssid = "HackaTruckIoT";
const char* password = "iothacka";

// Instância do servidor HTTP
ESP8266WebServer server(80);

// Pinos dos LEDs das gavetas
const int ledPins[] = {D0, D1, D2, D3, D4};  // GPIOs dos LEDs de cada gaveta
const int deviceLedPin = D6;  // GPIO para o LED que indica o estado do dispositivo

// Array para armazenar o estado de cada gaveta (LED)
bool gavetasState[sizeof(ledPins) / sizeof(ledPins[0])];

void setup() {
  Serial.begin(115200);

  // Conectar na rede Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando...");
  }
  Serial.println("Conectado!");
  Serial.print("Endereço IP: ");
  Serial.println(WiFi.localIP());

  // Configura os pinos dos LEDs das gavetas como saída
  for (int i = 0; i < sizeof(ledPins) / sizeof(ledPins[0]); i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW); // Começar com todos os LEDs apagados
    gavetasState[i] = false;       // Inicializar estado das gavetas
  }

  // Configura o pino do LED do dispositivo como saída
  pinMode(deviceLedPin, OUTPUT);
  digitalWrite(deviceLedPin, HIGH);  // Liga o LED D6 ao iniciar o dispositivo

  // Iniciar o servidor
  server.begin();

  // Rota para ligar/desligar gavetas específicas
  server.on("/ligarGaveta", HTTP_POST, []() {
    if (!server.hasArg("plain")) {
      server.send(400, "text/plain", "Body ausente");
      return;
    }

    String body = server.arg("plain");
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, body);

    if (error) {
      server.send(400, "text/plain", "Erro de parsing no JSON");
      return;
    }

    // Pegar o array de índices das gavetas que devem ser ligadas
    JsonArray gavetaIndices = doc["gavetas"].as<JsonArray>();

    // Validar se o array de gavetas tem de 1 a 4 elementos
    if (gavetaIndices.size() < 1 || gavetaIndices.size() > 5) {
      server.send(400, "text/plain", "O array de gavetas deve conter entre 1 e 5 índices");
      return;
    }

    // Primeiro, desligar todas as gavetas
    for (int i = 0; i < sizeof(ledPins) / sizeof(ledPins[0]); i++) {
      digitalWrite(ledPins[i], LOW); // Desligar todas as gavetas
      gavetasState[i] = false;       // Atualizar o estado
    }
    
    // Loop através do array de índices e ligar as gavetas especificadas
    for (JsonVariant var : gavetaIndices) {
      int gavetaIndex = var.as<int>();
      if (gavetaIndex >= 0 && gavetaIndex < (sizeof(ledPins) / sizeof(ledPins[0]))) {
        digitalWrite(ledPins[gavetaIndex], HIGH);  // Ligar o LED
      } else {
        server.send(400, "text/plain", "Índice de gaveta inválido");
        return;
      }

      
    }
    delay(30000);
for (JsonVariant var : gavetaIndices) {
      int gavetaIndex = var.as<int>();
      if (gavetaIndex >= 0 && gavetaIndex < (sizeof(ledPins) / sizeof(ledPins[0]))) {
        digitalWrite(ledPins[gavetaIndex], LOW);  // Ligar o LED
      } else {
        server.send(400, "text/plain", "Índice de gaveta inválido");
        return;
      }

      
    }
    // Resposta para o cliente
    server.send(200, "text/plain", "Gavetas ligadas");
  });

  // Rota para ativar/desativar o LED do dispositivo (D6)
  server.on("/ativarGaveta", HTTP_POST, []() {
    if (!server.hasArg("plain")) {
      server.send(400, "text/plain", "Body ausente");
      return;
    }

    String body = server.arg("plain");
    DynamicJsonDocument doc(1024);
    DeserializationError error = deserializeJson(doc, body);

    if (error) {
      server.send(400, "text/plain", "Erro de parsing no JSON");
      return;
    }

    // Verifica se o dispositivo deve ser ligado ou desligado
    bool ligar = doc["ligar"];
    Serial.print("Ativar LED D6: ");
    Serial.println(ligar);
    digitalWrite(deviceLedPin, ligar ? HIGH : LOW);  // Liga ou desliga o LED D6

    // Responde ao cliente se ativado ou desativado
    server.send(200, "text/plain", ligar ? "Gaveteiro conectado!" : "LED D6 desativado");
  });

  server.on("/estadoGaveta", HTTP_GET, [](){
    server.send(200, "text/plain", (digitalRead(deviceLedPin) == HIGH) ? "Gaveteiro ligado!" : "Gaveteiro desligado!");
});
}

void loop() {
  server.handleClient();  // Mantém o servidor HTTP funcionando
}
