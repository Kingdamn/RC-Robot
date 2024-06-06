#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include "SoftwareSerial.h"
#include "DFRobotDFPlayerMini.h"
#include <SoftwareSerial.h>
#include <TinyGPS++.h>

static const int RXPin = 16, TXPin = 17 ;
static const uint32_t GPSBaud = 9600;
TinyGPSPlus gps;
SoftwareSerial GPS(RXPin, TXPin);

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#define WIFI_SSID "P balap"
#define WIFI_PASSWORD "anjayyy3"

#define DATABASE_SECRET ""
#define API_KEY ""
#define DATABASE_URL ""

int led1 = 21;
int led2 = 2;
int led3 = 0;
int led4 = 4;

int IN1 = 27;
int IN2 = 14;
int IN3 = 12;
int IN4 = 13;

int DF_TX = 25;
int DF_RX = 26;

SoftwareSerial softwareSerial(DF_RX, DF_TX);

DFRobotDFPlayerMini player;


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;
int sValue, sValue2, sValue3, sValue4, sValue5;

void setup() {

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  Serial.begin(115200);
  softwareSerial.begin(9600);
  GPS.begin(GPSBaud);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;
  config.signer.tokens.legacy_token = DATABASE_SECRET;
  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

//  fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);

  //  /* Sign up */
  //  if (Firebase.signUp(&config, &auth, "", "")) {
  //    Serial.println("ok");
  //    signupOK = true;
  //  }
  //  else {
  //    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  //  }
  //  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
  pinMode(led3, OUTPUT);
  pinMode(led4, OUTPUT);

  if (player.begin(softwareSerial)) {
    Serial.println("OK");
    player.volume(20);
  } else
  {
    Serial.println("CEK KABEL DF");
  }
}

void loop() {
  while (GPS.available() > 0) {
    gps.encode(GPS.read());
    if (gps.location.isUpdated()) {
      Serial.print("Latitude= ");
      Serial.print(gps.location.lat(), 6);
      Serial.print(" Longitude= ");
      Serial.println(gps.location.lng(), 6);

      String address =  "https://maps.google.com/?q=" + String( gps.location.lat()) + "," + String (gps.location.lng());
      Serial.println(address);
      Serial.printf("Set string... %s\n", Firebase.setString(fbdo, F("/test/string"), address) ? "ok" : fbdo.errorReason().c_str());
    }
  }

  if (Firebase.ready())
  {
    if (Firebase.RTDB.getInt(&fbdo, "/MAJU"))
    {
      if (fbdo.dataType() == "int")
      {
        sValue = fbdo.intData();
        int a = sValue;
        //Serial.println(a);
        if (a == 1)
        {
          digitalWrite(led1, HIGH);
          digitalWrite(IN1, HIGH);
          digitalWrite(IN2, LOW);
          Serial.println("MAJU");

        } else
        {
          digitalWrite(led1, LOW);
          digitalWrite(IN1, LOW);
          digitalWrite(IN2, LOW);
        }
      }
    } else
    {
      Serial.println(fbdo.errorReason());
    }


    if (Firebase.RTDB.getInt(&fbdo, "/MUNDUR"))
    {
      if (fbdo.dataType() == "int")
      {
        sValue2 = fbdo.intData();
        int b = sValue2;
        //Serial.println(b);
        if (b == 1)
        {
          digitalWrite(led2, HIGH);
          digitalWrite(IN1, LOW);
          digitalWrite(IN2, HIGH);
          Serial.println("MUNDUR");
        } else
        {
          digitalWrite(led2, LOW);
          digitalWrite(IN1, LOW);
          digitalWrite(IN2, LOW);
        }
      }
    } else
    {
      Serial.println(fbdo.errorReason());
    }

    if (Firebase.RTDB.getInt(&fbdo, "/KIRI"))
    {
      if (fbdo.dataType() == "int")
      {
        sValue3 = fbdo.intData();
        int c = sValue3;
        //Serial.println(c);
        if (c == 1)
        {
          digitalWrite(led3, HIGH);
          digitalWrite(IN3, LOW);
          digitalWrite(IN4, HIGH);
          Serial.println("KIRI");
        } else
        {
          digitalWrite(led3, LOW);
          digitalWrite(IN3, LOW);
          digitalWrite(IN4, LOW);
        }
      }
    } else
    {
      Serial.println(fbdo.errorReason());
    }

        if (Firebase.RTDB.getInt(&fbdo, "/KANAN"))
    {
      if (fbdo.dataType() == "int")
      {
        sValue4 = fbdo.intData();
        int d = sValue4;
        //Serial.println(d);
        if (d == 1)
        {
          digitalWrite(led4, HIGH);
          digitalWrite(IN3, HIGH);
          digitalWrite(IN4, LOW);
          Serial.println("KANAN");
        } else
        {
          digitalWrite(led4, LOW);
          digitalWrite(IN3, LOW);
          digitalWrite(IN4, LOW);
        }
      }
    } else
    {
      Serial.println(fbdo.errorReason());
    }

    if (Firebase.RTDB.getInt(&fbdo, "/KLAKSON"))
    {
      if (fbdo.dataType() == "int")
      {
        sValue5 = fbdo.intData();
        int e = sValue5;
        //Serial.println(e);
        if (e == 1)
        {
          player.play(1);
          Serial.println("KLAKSON");
        } else
        {
         pause; 
        }
      }
    } else
    {
      Serial.println(fbdo.errorReason());
    }

    FirebaseJson json;
    json.set("lat", gps.location.lat());
    json.set("lng", gps.location.lng());
    json.set("Address", "https://maps.google.com/?q=" + String( gps.location.lat()) + "," + String (gps.location.lng()));
    Serial.printf("Set json... %s\n", Firebase.set(fbdo,("/GPS"), json) ? "ok" : fbdo.errorReason().c_str());
  }
}
