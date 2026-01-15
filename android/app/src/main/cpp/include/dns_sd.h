#ifndef DNS_SD_H
#define DNS_SD_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _DNSServiceRef_t *DNSServiceRef;
typedef uint32_t DNSServiceFlags;
typedef int32_t DNSServiceErrorType;

#define DNSSD_API
typedef void (DNSSD_API *DNSServiceRegisterReply)(DNSServiceRef, DNSServiceFlags, DNSServiceErrorType, const char*, const char*, const char*, void*);
typedef void (DNSSD_API *DNSServiceBrowseReply)(DNSServiceRef, DNSServiceFlags, uint32_t, DNSServiceErrorType, const char*, const char*, const char*, void*);
typedef void (DNSSD_API *DNSServiceResolveReply)(DNSServiceRef, DNSServiceFlags, uint32_t, DNSServiceErrorType, const char*, const char*, uint16_t, uint16_t, const unsigned char*, void*);

#define kDNSServiceFlagsAdd 0x1
#define kDNSServiceErr_NoError 0

inline DNSServiceErrorType DNSServiceRegister(DNSServiceRef*, DNSServiceFlags, uint32_t, const char*, const char*, const char*, const char*, uint16_t, uint16_t, const void*, DNSServiceRegisterReply, void*) { return 0; }
inline DNSServiceErrorType DNSServiceBrowse(DNSServiceRef*, DNSServiceFlags, uint32_t, const char*, const char*, DNSServiceBrowseReply, void*) { return 0; }
inline DNSServiceErrorType DNSServiceResolve(DNSServiceRef*, DNSServiceFlags, uint32_t, const char*, const char*, const char*, DNSServiceResolveReply, void*) { return 0; }
inline void DNSServiceRefDeallocate(DNSServiceRef) {}
inline int DNSServiceRefSockFD(DNSServiceRef) { return -1; }
inline DNSServiceErrorType DNSServiceProcessResult(DNSServiceRef) { return 0; }

#ifdef __cplusplus
}
#endif

#endif
