#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509.h>

/**
 * OpenSSL Stubs for Android NDK Build
 * 
 * These stubs satisfy the linker for symbols used by AegisCore's network layer.
 * On mobile, we prioritize the core chess engine and local persistence.
 * If mesh networking is required, we recommend the Hybrid Dart strategy.
 */

extern "C" {

void ERR_clear_error(void) {}
unsigned long ERR_get_error(void) { return 0; }
const char *ERR_reason_error_string(unsigned long e) { return "Stubbed Error"; }

const EVP_MD *EVP_sha256(void) { return nullptr; }

long SSL_CTX_ctrl(SSL_CTX *ctx, int cmd, long larg, void *parg) { return 0; }
void SSL_CTX_free(SSL_CTX *ctx) {}
void *SSL_CTX_get_default_passwd_cb_userdata(SSL_CTX *ctx) { return nullptr; }
void *SSL_CTX_get_ex_data(const SSL_CTX *ctx, int idx) { return nullptr; }
SSL_verify_cb SSL_CTX_get_verify_callback(const SSL_CTX *ctx) { return nullptr; }
int SSL_CTX_get_verify_mode(const SSL_CTX *ctx) { return 0; }
SSL_CTX *SSL_CTX_new(const SSL_METHOD *method) { return nullptr; }
void SSL_CTX_set_default_passwd_cb_userdata(SSL_CTX *ctx, void *data) {}
int SSL_CTX_set_ex_data(SSL_CTX *ctx, int idx, void *data) { return 0; }
unsigned long SSL_CTX_set_options(SSL_CTX *ctx, unsigned long op) { return 0; }
void SSL_CTX_set_verify(SSL_CTX *ctx, int mode, SSL_verify_cb callback) {}

const SSL_METHOD *TLS_client_method(void) { return nullptr; }
const SSL_METHOD *TLS_method(void) { return nullptr; }
const SSL_METHOD *TLS_server_method(void) { return nullptr; }

X509 *X509_STORE_CTX_get_current_cert(const X509_STORE_CTX *ctx) { return nullptr; }
int X509_digest(const X509 *data, const EVP_MD *type, unsigned char *md, unsigned int *len) { return 0; }

}
