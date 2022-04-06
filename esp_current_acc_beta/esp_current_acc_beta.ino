// Integrated 20A current sensor and acceleromter
// Using MySQL_MariaDB_Generic
// ACS712, ADXL345_WE Libraries
// For use with NodeMCU ESP-12E

// MySQL_MariaDB_Generic
#define MYSQL_DEBUG_PORT          Serial
#define _MYSQL_LOGLEVEL_          0

// Libraries and header files
#include <Wire.h>                 // I2C Library
#include <MySQL_Generic.h>        // khoih-prog/MySQL_MariaDB_Generic
#include <ACS712.h>               // RobTillaart/ACS712
#include <ADXL345_WE.h>           // wollewald/ADXL345_WE
#include "Credentials.h"

// I2C address of ADXL345
#define ADXL345_I2CADDR 0x53

// ADC pin for current output
#define VOUT_PIN                  A0

// Initialize libraries
MySQL_Connection conn((Client *)&client);
MySQL_Query *query_mem;
ACS712  ACS(A0, 5.0, 1023, 100);    // ACS712 20A uses 100 mV per A
ADXL345_WE myAcc = ADXL345_WE(ADXL345_I2CADDR);   // ADCL345 inser I2C address

// Variables for ACS712 current analog data and ADXL345 accelerometer data
float mA_float, formFactor_float;
float xa_float, ya_float, za_float;

// MySQL INSERT INTO instruction
#if USING_STORED_PROCEDURE
  char CALL_MA[] = "CALL %s.%s (%d, %s)";
  char CALL_ACC[] = "CALL %s.%s (%d, %s, %s, %s)";
#else
  char INSERT_MA[] = "INSERT INTO %s.%s (device_id, amp_data) VALUES (%d, %s)";
  char INSERT_ACC[] = "INSERT INTO %s.%s (device_id, xa_data, ya_data, za_data) VALUES (%d, %s, %s, %s)";
#endif

char query1[100];
char query2[100];
char mA_char[10];
char xa_char[10];
char ya_char[10];
char za_char[10];
byte device_id = 1;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  
  Serial.begin(115200);
  while (!Serial);
  Wire.begin();             // Initialize I2C
  
  MYSQL_DISPLAY1("\nStarting program on", ARDUINO_BOARD);
  MYSQL_DISPLAY(MYSQL_MARIADB_GENERIC_VERSION);
 
  ACS.autoMidPoint();
  if (!myAcc.init()) {    // Initialize accelerometer with default register values
    Serial.println("ADXL345 not connected!");
  }
  
  // Calibraton factors
  myAcc.setCorrFactors(-254.0, 274.0, -271.0, 256.0, -258.0, 250.0);
  
  // Data rate parameters
  myAcc.setDataRate(ADXL345_DATA_RATE_50);    // 50 Hz data rate

  // Range paremeters
  myAcc.setRange(ADXL345_RANGE_4G);
  
  myAcc.setLowPower(false);   // Low power mode, for output data rate between 12.5 and 400 Hz
  
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
    // Save
    dtostrf(mA_float, 4, 2, mA_char);
    dtostrf(xa_float, 4, 2, xa_char);
    dtostrf(ya_float, 4, 2, ya_char);
    dtostrf(za_float, 4, 2, za_char);
    
    #if USING_STORED_PROCEDURE
      sprintf(query1, CALL_MA, database, proc1, device_id, mA_char);
      sprintf(query2, CALL_ACC, database, proc2, device_id, xa_char, ya_char, za_char);
    #else
      sprintf(query1, INSERT_MA, database, table1, device_id, mA_char);
      sprintf(query2, INSERT_ACC, database, table2, device_id, xa_char, ya_char, za_char);
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
    digitalWrite(LED_BUILTIN, LOW);
    MYSQL_DISPLAY("\nConnect success");

    // Obtain sensor data
    mA_float = ACS.mA_AC();
    formFactor_float = ACS.getFormFactor();
    xyzFloat raw = myAcc.getCorrectedRawValues();    // Returns the corrected raw values from the data registers.
    xyzFloat g = myAcc.getGValues();        // Returns the g values.

    // Assign struct values to individual floats
    xa_float = g.x;
    ya_float = g.y;
    za_float = g.z;

    MYSQL_DISPLAY3("\nmA:", mA_float, ". Form factor: ", formFactor_float);
    MYSQL_DISPLAY5("\nRaw-x = ", raw.x, "  |  Raw-y = ", raw.y, "  |  Raw-z = ", raw.z)
    MYSQL_DISPLAY5("g-x   = ", g.x, "  |  g-y   = ", g.y, "  |  g-z   = ", g.z)
    
    runInsert();
    conn.close();
    digitalWrite(LED_BUILTIN, HIGH);
  }
  else {
    digitalWrite(LED_BUILTIN, HIGH);
    MYSQL_DISPLAY("\nConnect failed trying again");
  }

  MYSQL_DISPLAY("\nSleeping");
  delay(100);         // end of loop

}
