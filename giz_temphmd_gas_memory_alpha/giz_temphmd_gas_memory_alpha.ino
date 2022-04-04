// Integrated temperature, humidity, gas sensor
// Using Smoothed, MySQL_MariaDB_Generic, WiFiESP Libraries
// For use with gizDuino LIN-UNO/gizduino UNO-SE
// With ESP-12E WiFi shield

// MySQL_MariaDB_Generic
#define MYSQL_DEBUG_PORT      Serial
#define _MYSQL_LOGLEVEL_      0

// Libraries and header files
#include <Wire.h>             // I2C Library
#include <SHT21.h>            // e-radionicacom/SHT21-Arduino
#include <WiFiEsp.h>          // bportaluri/WiFiEsp
#include <SoftwareSerial.h>   // built-in library
#include "Credentials.h"

// Specific header files from khoih-prog/MySQL_MariaDB_Generic Library
#include <MySQL_Generic.hpp>
#include <MySQL_Generic_Connection_Impl.h>
#include <MySQL_Generic_Query_Impl.h>
#include <MySQL_Generic_Encrypt_Sha1_Impl.h>
#include <MySQL_Generic_Packet_Impl.h>

// ADC pins for FCM2630 sensor
#define VOUT_PIN A0
#define VREF_PIN A1

// Initialize libraries
SoftwareSerial Serial1(2, 3); // RX, TX
WiFiEspClient client;
MySQL_Connection conn((Client *)&client);
MySQL_Query *query_mem;
SHT21 sht;

// Variables for SHT21 temp/humidity data and FCM2630 analog data
float temp_float, hmd_float;
float vout_float, vref_float;

// MySQL INSERT INTO instruction
#if USING_STORED_PROCEDURE
  char CALL_TEMPHMD[] = "CALL %s.%s (%d, %s, %s)";
  char CALL_GAS[] = "CALL %s.%s (%d, %s, %s)";
#else
  char INSERT_TEMPHMD[] = "INSERT INTO %s.%s (device_id, temp_data, hmd_data) VALUES (%d, %s, %s)";
  char INSERT_GAS[] = "INSERT INTO %s.%s (device_id, vout_data, vref_data, vout_status, vref_status, alarm_status) VALUES (%d, %s, %s, %d, %d, %d)";
  byte vout_status, vref_status, alarm_status;
#endif
char query1[55];
char query2[50];
char temp_char[5];
char hmd_char[5];
char vout_char[5];
char vref_char[5];
byte device_id = 1;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  Wire.begin();             // Initialize I2C

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

void runInsert() {
  // Initiate the query class instance
  MySQL_Query query_mem = MySQL_Query(&conn);

  if (conn.connected()) {
    // Save
    MYSQL_DISPLAY("Start 1");
    dtostrf(temp_float, 4, 2, temp_char);
    dtostrf(hmd_float, 4, 2, hmd_char);
    dtostrf(vout_float, 4, 2, vout_char);
    dtostrf(vref_float, 4, 2, vref_char);
    
    #if USING_STORED_PROCEDURE
      sprintf(query1, CALL_TEMPHMD, database, proc1, device_id, temp_char, hmd_char);
      sprintf(query2, CALL_GAS, database, proc2, device_id, vout_char, vref_char);
    #else
      sprintf(query1, INSERT_TEMPHMD, database, table1, device_id, temp_char, hmd_char);
      sprintf(query2, INSERT_GAS, database, table2, device_id, vout_char, vref_char, vout_status, vref_status, alarm_status);
    #endif
    
    MYSQL_DISPLAY1("Query1", query1);
    MYSQL_DISPLAY1("Query2", query2);

    // Execute the query
    // KH, check if valid before fetching
    if ( !query_mem.execute(query1) ) {
      MYSQL_DISPLAY("Query 1: Insert error");
    }
    else {
      MYSQL_DISPLAY("Query 1: Data Inserted.");
    }
    if ( !query_mem.execute(query2) ) {
      MYSQL_DISPLAY("Query 2: Insert error");
    }
    else {
      MYSQL_DISPLAY("Query 2: Data Inserted.");
    }
  }
  else {
    MYSQL_DISPLAY("Server disconnected can't insert.");
  }
}

void loop() {
  MYSQL_DISPLAY("Connecting to server");
  temp_float = sht.getTemperature();
  hmd_float = sht.getHumidity();

  vout_float = analogRead(VOUT_PIN)/1024;
  vref_float = analogRead(VREF_PIN)/1024;

  if (conn.connect(server_addr, server_port, user, password) != RESULT_FAIL) {
    digitalWrite(LED_BUILTIN, HIGH);
    MYSQL_DISPLAY("\nConnect success");
//    MYSQL_DISPLAY3("\nTemp: ", temp_float, "\tHumidity: ", hmd_float);
//    MYSQL_DISPLAY3("Vout: ", vout_float, "\tVRef: ", vref_float);
    runInsert();
    conn.close();
    digitalWrite(LED_BUILTIN, LOW);
    delay(50);
  } 
  else {
    MYSQL_DISPLAY("\nConnect failed");
  }  
  MYSQL_DISPLAY("\nSleeping");
  delay(1000);         // end of loop
}
