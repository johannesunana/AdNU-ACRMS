// Integrated temperature, humidity, gas sensor
// Using Smoothed, MySQL_MariaDB_Generic, WiFiESP Libraries
// For use with gizDuino LIN-UNO/gizduino UNO-SE
// With ESP-12E WiFi shield

// Libraries
#include <SHT21.h>            // e-radionicacom/SHT21-Arduino
#include <Smoothed.h>         // MattFryer/Smoothed
#include <WiFiEsp.h>          // bportaluri/WiFiEsp
#include <SoftwareSerial.h>   // built-in library

// Login credentials for WiFiEsp and MySQL
#include "Credentials.h"

// Selected library files from khoih-prog/MySQL_MariaDB_Generic
#include <MySQL_Generic.hpp>
#include <MySQL_Generic_Connection_Impl.h>
#include <MySQL_Generic_Query_Impl.h>
#include <MySQL_Generic_Encrypt_Sha1_Impl.h>
#include <MySQL_Generic_Packet_Impl.h>

// For MySQL Library
#define MYSQL_DEBUG_PORT      Serial
#define _MYSQL_LOGLEVEL_      3

// ADC pins for FCM2630 sensor
#define VOUT_PIN A0
#define VREF_PIN A1

// Initialize libraries
SoftwareSerial Serial1(2, 3); // RX, TX
SHT21 sht;
Smoothed <float> SensorVOut;
Smoothed <float> SensorVRef;
WiFiEspClient client;

IPAddress server_addr(192, 168, 254, 107);
uint16_t server_port = 3308;

// Variables for SHT21 temp/humidity data and FCM2630 analog data
float temp_float, hmd_float;
//float vOut_float, vRef_float;
//float smoothedSensorVOutValueAvg, smoothedSensorVRefValueAvg;
//byte vOut_status, vRef_status, alarm_status;
byte device_id = 1;

// MySQL INSERT INTO instruction
char INSERT_DATA[] = "INSERT INTO %s.%s (device_id, temp_data, hmd_data) VALUES (%d, %s, %s)";
char query_1[100];
char query_2[100];
char temp_char[10];
char hmd_char[10];

MySQL_Connection conn((Client *)&client);
MySQL_Query *query_mem;


void runInsert() {
  // Initiate the query class instance
  MySQL_Query query_mem = MySQL_Query(&conn);

  if (conn.connected()) {
    // Save
    dtostrf(temp_float, 4, 1, temp_char);
    dtostrf(hmd_float, 4, 1, hmd_char);
    sprintf(query_1, INSERT_DATA, database, table_1, device_id, temp_char, hmd_char);
    
    // Execute the query
    // KH, check if valid before fetching
    if ( !query_mem.execute(query_1) ) {
      MYSQL_DISPLAY(query_1);
      MYSQL_DISPLAY("Insert error");
    }
    else {
      MYSQL_DISPLAY("Data Inserted.");
    }
  }
  else {
    MYSQL_DISPLAY("Server disconnected can't insert.");
  }
}


//void gasReading(float vOut_in, float vRef_in) {
//    if ((vOut_in > 4.95) || (vOut_in < 0.05)) {
//        vOut_status = 1;        // malfunction
//    }
//    else {
//        vOut_status = 0;        // normal
//    }
//    if ((vRef_in > 3.70) || (vRef_in < 2.50)) {
//        vRef_status = 1;       // malfunction
//    }
//    else {
//        vOut_status = 0;      // normal
//    }
//    if ((vRef_status == 1) || (vOut_status == 1)) {
//        alarm_status = 2;        // malfunction
//    }
//    else {
//        if (vOut_in < vRef_in) {
//            alarm_status = 1;   // alarm
//        }
//        else {
//            alarm_status = 0;   // normal
//        }
//    }
//}


void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  Wire.begin();             // Initialize I2C
  SensorVOut.begin(SMOOTHED_AVERAGE, 10);
  SensorVRef.begin(SMOOTHED_AVERAGE, 10);

  //WiFiEspClient
  Serial.begin(115200);     // initialize serial for debugging
  Serial1.begin(9600);      // initialize serial for ESP module
  WiFi.init(&Serial1);      // initialize ESP module


  if (WiFi.status() == WL_NO_SHIELD) {    // check for the presence of the shield
      while (true);   // don't continue
    }
    MYSQL_DISPLAY1("Connecting to", ssid);
    
    WiFi.begin(ssid, pass);
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      MYSQL_DISPLAY0(".");
    }
    MYSQL_DISPLAY1("Connected to network. My IP address is:", WiFi.localIP());

}

void loop() {

  MYSQL_DISPLAY("Connecting to server");
  if (conn.connect(server_addr, server_port, user, password) != RESULT_FAIL) {
    delay(500);
    digitalWrite(LED_BUILTIN, HIGH);
    MYSQL_DISPLAY("\nConnect success");
    temp_float = sht.getTemperature();
    hmd_float = sht.getHumidity();

//    vOut_float = analogRead(VOUT_PIN);
//    vRef_float = analogRead(VREF_PIN);
//    
//    SensorVOut.add(vOut_float);
//    SensorVRef.add(vRef_float);
//  
//    smoothedSensorVOutValueAvg = SensorVOut.get() * (5.0 / 1023.0);
//    smoothedSensorVRefValueAvg = SensorVRef.get() * (5.0 / 1023.0);
//    
  // Print out the values
    Serial.print("\nTemp: ");      // print readings
    Serial.print(temp_float);
    Serial.print("\tHumidity: ");
    Serial.println(hmd_float);
//
//    Serial.print("\t\tVout: ");
//    Serial.print(vOut_float/1024);
//    Serial.print(smoothedSensorVOutValueAvg);
//    Serial.print("\tVRef: ");
//    Serial.println(vRef_float/1024);
//    Serial.println(smoothedSensorVRefValueAvg);
    
    runInsert();
//    gasReading(smoothedSensorVOutValueAvg, smoothedSensorVRefValueAvg);
    
    conn.close();                     // close the connection
    delay(1000);
    digitalWrite(LED_BUILTIN, LOW);
  } 

  else {
    MYSQL_DISPLAY("\nConnect failed trying again");
  }
  
  MYSQL_DISPLAY("\nSleeping");
  delay(10000);         // end of loop
}
