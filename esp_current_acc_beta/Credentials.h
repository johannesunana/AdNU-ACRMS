#ifndef Credentials_h
#define Credentials_h

IPAddress server_addr(192, 168, 254, 107);
uint16_t server_port = 3308; 

char ssid[] = "HelloKitty";             // your network SSID (name)
char pass[] = "JVA102123";         // your network password

char user[]         = "arduino";              // MySQL user login username
char password[]     = "arduino";          // MySQL user login password

char database[] = "adnu_acrms_3";
char table1[]  = "data_current";
char table2[]  = "data_accelerometer";


#endif    //Credentials_h
