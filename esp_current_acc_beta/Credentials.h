#ifndef Credentials_h
#define Credentials_h

#define USING_STORED_PROCEDURE    true

IPAddress server_addr(192, 168, 254, 100);
uint16_t server_port = 3308; 

char ssid[] = "HelloKitty";             // your network SSID (name)
char pass[] = "JVA102123";         // your network password

char user[]         = "arduino";              // MySQL user login username
char password[]     = "arduino";          // MySQL user login password

char database[] = "adnu_acrms_3";

#if USING_STORED_PROCEDURE
  char proc1[] = "add_amp_data";
  char proc2[] = "add_acc_data";
#else
  char table1[]  = "data_amp";
  char table2[]  = "data_acc";
#endif 

#endif    //Credentials_h
