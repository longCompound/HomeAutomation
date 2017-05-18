#ifndef __MY51C_DEVICEDISCOVER_H__
#define __MY51C_DEVICEDISCOVER_H__
//#include "../new_tlib-dm365/include/gs_tlib_def.h"//add by marsal

#define  SEARCH_BROADCAST_PORT  8628
//#define  SEARCH_BROADCAST_PORT  9628

#define	CAM_HDVS

//cmd √¸¡Ó

#ifdef 	CAM_HDVS
#define HDVSGET 0x56         //ªÒ»°…Ë±∏–≈œ¢√¸¡Ó±Í ∂
#define RESPONDHDVSGET 0x57  //ªÿ∏¥ªÒ»°…Ë±∏–≈œ¢µƒ√¸¡Ó±Í ∂
#define RESPONDHDVSGET_3G 0x58  //ªÿ∏¥ªÒ»°…Ë±∏–≈œ¢µƒ√¸¡Ó±Í ∂

#define HDVSSET 0x87         //…Ë÷√…Ë±∏–≈œ¢√¸¡Ó±Í ∂
#define HDVSSET_3G 0x80         //…Ë÷√…Ë±∏–≈œ¢√¸¡Ó±Í ∂3G paras, by marshal
#define HDVSGET_3G 0x81         //…Ë÷√…Ë±∏–≈œ¢√¸¡Ó±Í ∂get 3G paras, by marshal
#define RIGHTHDVSSET 0x89    //ªÿ∏¥’˝»∑…Ë÷√…Ë±∏–≈œ¢√¸¡Ó±Í ∂
#define WRONGHDVSSET 0x93    //ªÿ∏¥¥ÌŒÛ…Ë÷√…Ë±∏–≈œ¢√¸¡Ó±Í ∂
////
#define CMD_GET_FLAG "HdvsGet"	
#define CMD_SET_INFO_FLAG "HdvsSetInfo"	
#define CMD_SET_SUCCESS_FLAG "hdvsset success"
#endif

typedef struct{
    unsigned char bStatus;	        ///< schedule status ( 0:disable 1:¬ºœÒ 2:±®æØ ±¬ºœÒ }
	unsigned char nDay;		        ///< schedule day of week (1:Mon 2:Tue 3:Wed 4:Thr 5:Fri 6:Sat 7:Sun 8:Everyday 9:Working day)
	unsigned char nStartHour;	    ///< Hour from 0 to 23.
	unsigned char nStartMin;	    ///< Minute from 0 to 59.
	unsigned char nStartnSec;	    ///< Second from 0 to 59.
	unsigned char nDurationHour;	///< Hour from 0 to 23.
	unsigned char nDurationMin;	    ///< Minute from 0 to 59.
	unsigned char nDurationSec;	    ///< Second from 0 to 59.
} Schedule;

/* √¸√˚πÊ‘Ú char-->sz, int-->n, unsigned int-->u, char *-->psz */
typedef struct _struWifiInfo_t
{
	int  nEnableWiFiDHCP;        // «∑Ò‘ –ÌWiFiµƒDHCP
	int  nEnableWiFi;            // «∑Ò‘ –ÌWiFi
	int  nWiFiEncryMode;         //WiFiº”√‹ƒ£ Ω
	char szWiFiIP[20];           //WiFiµƒIP
	char szWiFiSSID[128];        //WiFi√˚≥∆
	char szWiFiPwd[64];          //WiFi√‹¬Î

	int  nEnableDeviceDHCP;		 //…Ë±∏DHCP
    char szWiFiMasK[16];         //WiFiµƒ◊”Õ¯—⁄¬Î
    char szWiFiGateWay[16];      //WiFiµƒÕ¯πÿ
    char szWiFiDNS0[16];         //WiFiµƒDNSµÿ÷∑
    char szWiFiDNS1[16];         //
}struWifiInfo;
typedef struct _stru3GInfo_t
{
	char sz3GUser[60];           //user name
	char sz3GPWD[60];        //pwd
	char sz3GAPN[128];          //apn
    	char szDialNum[44];         //WiFiµƒ◊”Õ¯—⁄¬Î
}stru3GInfo;

#pragma pack(1)
typedef struct _tmDeviceInfo_t
{
	int  nCmd;                    //±Í ∂√¸¡Ó◊÷
	char szPacketFlag[24];       //±Í ∂◊÷∑˚
	char szDeviceName[20];       //…Ë±∏√˚≥∆
	char szDeviceType[24];       //…Ë±∏¿‡–Õ
	int  nMaxChannel;            //◊Ó¥ÛÕ®µ¿ ˝
	char szDeviceIP[16];         //…Ë±∏IP
	char szDeviceMasK[16];       //…Ë±∏◊”Õ¯—⁄¬Î
	char szDeviceGateWay[16];    //…Ë±∏Õ¯πÿ
	char szMultiAddr[16];        //…Ë±∏∂‡≤•µÿ÷∑
	char szMacAddr_LAN[8];          //lan …Ë±∏MAC µÿ÷∑
	char szMacAddr_WIFI[8];          //wifi …Ë±∏MAC µÿ÷∑
#ifdef CAM_HDVS	
	int nEnableDeviceDHCP; //dhcp
	char szRevsered0[12];
#else
	char szRevsered0[16];
#endif
	char szDNS0[16];             //…Ë±∏DNSµÿ÷∑
	char szDNS1[16];             //DNSµÿ÷∑ ‘›√ª”√
	int  nMultiPort;             //∂‡≤•∂Àø⁄
	int  nDataPort;              // ˝æ›∂Àø⁄
	int  nWebServerPort;         //WEB ∂Àø⁄

	char szUserName[16];         //”√ªß√˚
	char szPwd[16];              //√‹¬Î
	char szCameraVer[8];         //»Ìº˛∞Ê±æ

	char szWanServerIP[24];      //π„”ÚÕ¯IP
	char szServerPort[8];        //π„”ÚÕ¯∂Àø⁄
	char szCamSerial[64];        //…Ë±∏–Ú¡–∫≈
#if 1
	int  nEnableWiFiDHCP;        // «∑Ò‘ –ÌWiFiµƒDHCP
	int  nEnableWiFi;            // «∑Ò‘ –ÌWiFi
	int  nWiFiEncryMode;         //WiFiº”√‹ƒ£ Ω
	char szWiFiIP[20];           //WiFiµƒIP
	char szWiFiSSID[128];        //WiFi√˚≥∆
#ifdef CAM_HDVS	
	char szWiFiPwd[68];          //WiFi√‹¬Î
#else
	char szWiFiPwd[64];          //WiFi√‹¬Î

	int  nEnableDeviceDHCP;		 //…Ë±∏DHCP
#endif
    char szWiFiMasK[16];         //WiFiµƒ◊”Õ¯—⁄¬Î
    char szWiFiGateWay[16];      //WiFiµƒÕ¯πÿ
    char szWiFiDNS0[16];         //WiFiµƒDNSµÿ÷∑
    char szWiFiDNS1[16];         //
#endif
    unsigned int uOfferSize;    //Ã·π©µƒ ”∆µ∑÷±Ê¬ 
	unsigned int uImageSize;    //µ±«∞ ”∆µ∑÷±Ê¬ 
	unsigned int uMirror;       // ”∆µæµœÒ
	unsigned int uFlip;         // ”∆µ∑≠◊™
	unsigned int uRequestStream;//
	unsigned int uBitrate1;      //≤®Ãÿ¬ 
	unsigned int uFramerate1;    //÷°¬ 
	//µ⁄∂˛¬∑¬Î¡˜
	unsigned int uBitrate2;      //≤®Ãÿ¬ 
	unsigned int uFramerate2;    //÷°¬ 

	unsigned int uImagesource;      //∑÷±Ê¬  (NTSC/PAL)
	unsigned int uChangePWD;        //1: need to change 0: not to change
	char szNewPwd[16];              //the new password
	int  nDeviceNICType;             //0 wired NIC;1 wifi NIC
	unsigned int uEnableAudio;      // «∑Òø™∆Ù“Ù∆µ
	///add by marshal, u588x gpio settings, 2013-02-21
	unsigned char			bgioinenable;					///< GIO input enable, < bit0 Set gpio in alarm enable or disable, bit1 motion and io individual or both triggered. cation!!!
	unsigned char			bgiointype;						///< GIO input type
	unsigned char			bgiooutenable;					///< GIO output enable
	unsigned char			bgioouttype;						///< GIO output type
	unsigned char			bAlarmEnable;						///alarm enable or disable
	unsigned char			cRs485baudrate;						///0-9600 1-4800 2-2400 3-1200
	char szRevsered1[40];
	//end
    unsigned char nAlarmAudioPlay;		///< alarm audio play enable/disable
    unsigned char nAlarmDuration;		///< alarm duration 0~5{10, 30, 60, 300, 600, NON_STOP_TIME}
    unsigned char bAlarmUploadFTP;	    ///< ±®æØ¬ºœÒµƒŒƒº˛…œ¥´µΩftp
    unsigned char bAlarmSaveToSD;	    ///< ±®æØ¬ºœÒµƒŒƒº˛±£¥ÊµΩsdø®
    unsigned char bSetFTPSMTP;	    ///< Œ™1±Ì æ…Ë÷√FTP≤Œ ˝£¨Œ™2±Ì æ…Ë÷√SMTP≤Œ ˝
	char servier_ip[37];            ///< FTP or SMTP server address 
	char username[16];              ///< FTP or SMTP login username
	char password[16];              ///< FTP or SMTP login password
	unsigned int uPort;             ///< FTP or SMTP 

	char szBindAccont[48];          //∞Û∂®”√ªß√˚
	char szDevSAddr[48];            //…Ë±∏∑˛ŒÒ∆˜µÿ÷∑ªÚ”Ú√˚
	unsigned int uDevSPort;         //…Ë±∏∑˛ŒÒ∆˜∂Àø⁄

    char szSMTPReceiver[64];        //Ω” ’” º˛” œ‰
    unsigned char motionenable;		///< motion detection enable
    unsigned char motioncenable;	///< customized sensitivity enable
    unsigned char motionlevel;		///< predefined sensitivity level
    unsigned char motioncvalue;		///< customized sensitivity value
    unsigned char motionblock[4];   ///< motion detection block data
    unsigned char bDeviceRest;      /// …Ë±∏∏¥Œª√¸¡ÓŒ™1±Ì æ∏¥Œª£¨Œ™2±Ì æ÷ÿ∆Ù…Ë±∏
    unsigned char bEnableEmailRcv;      /// ø™∆Ù±®æØ” º˛µƒΩ” ’
    unsigned char bAttachmentType;      /// …Ë÷√” º˛∏Ωº˛µƒ¿‡–Õ 0->avi  1->jpeg  2->≤ª¥¯∏Ωº˛
//
    unsigned char ntp_timezone;      /// …Ë÷√œµÕ≥ ±«¯£¨0-24 œÍœ∏∂®“Âø¥œ¬√Êµƒ◊¢ Õ£¨
                                    //◊Ó∏ﬂŒªø…“‘”√¿¥…Ë÷√œƒ¡Ó ±£¨ƒ¨»œ◊‘∂Ø…Ë÷√œƒ¡Ó ±
    unsigned int  nYear;	        ///< µ±«∞ƒÍ∑›.
    unsigned char nMon;	            ///< Mounth from 1 to 12. –ﬁ∏ƒ ±º‰ ±«Îœ»Ω´‘¬∑›∏≥÷µ∫√£¨
                                    //‘ŸΩ´‘¬∑›◊Ó∏ﬂŒª…Ë÷√Œ™1(nMon|0x80)
    unsigned char nDay;	            ///< Second from 1 to 31.
    unsigned char nHour;	        ///< Hour from 0 to 23.
    unsigned char nMin;	            ///< Minute from 0 to 59.
    unsigned char nSec;	            ///< Second from 0 to 59.

    unsigned char nSdinsert;		        ///< SD card inserted£¨÷µŒ™3±Ì æsdø®ø…’˝≥£ π”√
    unsigned char bSchedulesUploadFTP;	    ///< Schedule¬ºœÒµƒŒƒº˛…œ¥´µΩftp
    unsigned char bSchedulesSaveToSD;	    ///< Schedule¬ºœÒŒƒº˛±£¥ÊµΩsdø®£¨◊Ó∏ﬂŒªŒ™1±Ì æ¬ºœÒ∏≤∏«
    
	Schedule  aSchedules[8];		///< schedule data
}_tmDeviceInfo_t;
#pragma pack()

#endif

#pragma mark - ios client


typedef _tmDeviceInfo_t DeviceInfo_t;

#define UDP_PORT_RECV 8629			//局域网广播用
#define UDP_PORT_SEND 8628



