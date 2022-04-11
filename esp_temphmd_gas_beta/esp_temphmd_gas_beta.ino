// Integrated temperature, humidity, gas sensor
// Using MySQL_MariaDB_Generic, MySQL_MariaDB_Generic
// NodeMCU ESP12

#define MYSQL_DEBUG_PORT      Serial
#define _MYSQL_LOGLEVEL_      0

// ADC input using 74HC4051 multiplexer
const int Z_pin = A0;
const int S0 = D5;
const int S1 = D6;
const int S2 = D7;

// Required libraries and header files
#include <Wire.h>             // I2C Library
#include <MySQL_Generic.h>    // khoih-prog/MySQL_MariaDB_Generic
#include <SHT21.h>            // e-radionicacom/SHT21-Arduino
#include "Credentials.h"

// Initialize libraries
MySQL_Connection conn((Client *)&client);
MySQL_Query *query_mem;
SHT21 sht;

// Float variables for SHT21 temperature and
// humidity data and FCM2630 analog data
float temp_float, hmd_float;
float vout_float, vref_float;
float vout, vref;
float vin = 5.00;     // Vin for ADC

// MySQL INSERT INTO instruction
#if USING_STORED_PROCEDURE
  char CALL_TEMPHMD[] = "CALL %s.%s (%d, %s, %s)";
  char CALL_GAS[] = "CALL %s.%s (%d, %s, %s)";
#else
  char INSERT_TEMPHMD[] = "INSERT INTO %s.%s (device_id, temp_data, hmd_data) VALUES (%d, %s, %s)";
  char INSERT_GAS[] = "INSERT INTO %s.%s (device_id, vout_data, vref_data, vout_status, vref_status, alarm_status) VALUES (%d, %s, %s, %d, %d, %d)";
  byte vout_status, vref_status, alarm_status;
#endif

char query1[100];
char query2[100];
char temp_char[10];
char hmd_char[10];
char vout_char[10];
char vref_char[10];
byte device_id = 1;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);     // onboard LED indicator at ESP-12 chip
  pinMode(S0, OUTPUT);
  pinMode(S1, OUTPUT);
  pinMode(S2, OUTPUT);
  
  digitalWrite(S0, LOW);
  digitalWrite(S1, LOW);
  digitalWrite(S2, LOW);
  digitalWrite(LED_BUILTIN, HIGH);  // Turn off LED, active low on the ESP8266
  
  Serial.begin(115200);
  while (!Serial);
  Wire.begin();                     // Initialize I2C

  MYSQL_DISPLAY1("\nStarting program on", ARDUINO_BOARD);
  MYSQL_DISPLAY(MYSQL_MARIADB_GENERIC_VERSION);
   
  MYSQL_DISPLAY1("Connecting to", ssid);
  
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    MYSQL_DISPLAY0(".");
  }
  
  MYSQL_DISPLAY1("Connected to network. My IP address is:", WiFi.localIP());
  MYSQL_DISPLAY3("Connecting to SQL Server @", server_addr, ", Port =", server_port);
  MYSQL_DISPLAY5("User =", user, ", PW =", password, ", DB =", database);
}

void runInsert() {
  // Initiate the query class instance
  MySQL_Query query_mem = MySQL_Query(&conn);

  if (conn.connected()) {
    // Convert floats to strings before insert
    dtostrf(temp_float, 4, 2, temp_char);
    dtostrf(hmd_float, 4, 2, hmd_char);
    dtostrf(vout, 4, 2, vout_char);
    dtostrf(vref, 4, 2, vref_char);

    // Insert char strings to placeholders in single query string
    #if USING_STORED_PROCEDURE
      sprintf(query1, CALL_TEMPHMD, database, proc1, device_id, temp_char, hmd_char);
      sprintf(query2, CALL_GAS, database, proc2, device_id, vout_char, vref_char);
    #else
      sprintf(query1, INSERT_TEMPHMD, database, table1, device_id, temp_char, hmd_char);
      sprintf(query2, INSERT_GAS, database, table2, device_id, vout_char, vref_char, vout_status, alarm_status);
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
  if (conn.connectNonBlocking(server_addr, server_port, user, password) != RESULT_FAIL) {
    MYSQL_DISPLAY("\nConnect success");
    
    // Obtain sensor data from SHT21
    temp_float = sht.getTemperature();
    hmd_float = sht.getHumidity();
    MYSQL_DISPLAY3("\nTemp: ", temp_float, "\tHumidity: ", hmd_float);

    // Obtain sensor data from FCM2630-C01
    // Channel Y0 from 74HC4051 mux
    digitalWrite(S0, LOW);
    vout_float = analogRead(Z_pin);
    vout = (vout_float * vin) / 1023;
    MYSQL_DISPLAY0("VOut: ");
    MYSQL_DISPLAY0( vout);

    // Channel Y1 from 74HC4051 mux
    digitalWrite(S0, HIGH);
    vref_float = analogRead(Z_pin);
    vref = (vref_float * vin) / 1023;
    MYSQL_DISPLAY1("\tVRef: ", vref);
    
    digitalWrite(S0, LOW);
    digitalWrite(LED_BUILTIN, LOW);
    
    runInsert();
    conn.close();
    digitalWrite(LED_BUILTIN, HIGH);
  } 
  else {
    digitalWrite(LED_BUILTIN, HIGH);
    MYSQL_DISPLAY("\nConnect failed");
  }  
  MYSQL_DISPLAY("\nSleeping");
  delay(10000);         // Restart after 10 seconds
  // End of loop
}
