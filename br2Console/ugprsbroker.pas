unit ugprsbroker;

interface
uses
  System.SysConst;

const GPRSMax=15000;
      ClientMax=254;
      ClientKontactMax=20;
      VersionBroker='1.19.08.25';
      NumVersionBroker: WORD = (21 shl 9)+(3 shl 5)+24;
type
      dword = LongWord;

      PInfoGPRS=^TInfoGPRS;
      TInfoGPRS=record
             id_gprs: dword;
             hw: dword;
             lasttime: dword;
             //сокет подключенного клиента - пока не знаем какого типа
             //sock: TTCPServerClient;
             teklen: dword;
             srezdt1: dword; // ñðåç GetTickCount;
             busy: boolean;
             busycl: byte;
             somecl_wait: byte;
             tmpbuf: array[0..1151] of byte;
           end;

implementation

end.
