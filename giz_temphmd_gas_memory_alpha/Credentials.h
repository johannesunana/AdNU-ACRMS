#ifndef Credentials_h
#define Credentials_h

#define USING_STORED_PROCEDURE    true

IPAddress server_addr(192, 168, 254, 107);
uint16_t server_port = 3308;

char ssid[] = "HelloKitty";             // your network SSID (name)
char pass[] = "JVA102123";         // your network password

char user[]         = "arduino";              // MySQL user login username
char password[]     = "arduino";          // MySQL user login password

char database[] = "adnu_acrms_3";

#if USING_STORED_PROCEDURE
  char proc1[] = "add_temp_hmd_data";
  char proc2[] = "add_gas_data";
#else
  char table1[]  = "data_temp_hmd";
  char table2[]  = "data_gas";
#endif

#endif    //Credentials_h
