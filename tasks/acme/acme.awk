#!/usr/bin/env awk -f tasks/acme/acme.awk --

BEGIN {
    VERSION = "0.1"
    ENVIRONMENT = "production"
    DOMAIN = "localhost"
    VERBOSE = 0

    parseParameters(ARGV, ARGC)

    # createAccountKey(DOMAIN)
    newAccount(ENVIRONMENT, DOMAIN)
    accountUrl = getResponseHeader("location")
    newOrderResponse = newOrder(ENVIRONMENT, DOMAIN, getKid(accountUrl))
    orderUrl = getResponseHeader("location")
    finalizeUrl = getFinalizeUrl(newOrderResponse)

    authResponse = getAuthorization(ENVIRONMENT, DOMAIN, getAuthUrl(newOrderResponse), getKid(accountUrl))
    challengeUrl = getChallengeUrl(authResponse)
    challengeToken = getChallengeToken(authResponse)
    authKey = challengeToken"."getThumbprint(getAccountExponent(DOMAIN), getAccountModulus(DOMAIN))

    challengeResponse = doChallenge(ENVIRONMENT, DOMAIN, challengeUrl, getKid(accountUrl))
    # verbose("CHALLENGE", challengeResponse)
    orderResponse = getOrder(ENVIRONMENT, DOMAIN, orderUrl, getKid(accountUrl))
    # verbose("ORDER-RESPONSE", orderResponse)
    # invalid pending ready
    orderStatus = getOrderStatus(orderResponse)
    createCertificateRequest(DOMAIN)

    endOrderResponse = finishOrder(ENVIRONMENT, DOMAIN, finalizeUrl, getKid(accountUrl))
    orderStatus = getOrderStatus(endOrderResponse)
    certificateUrl = getCertificateUrl(endOrderResponse)
    fetchCertificate(ENVIRONMENT, DOMAIN, certificateUrl, getKid(accountUrl))
}

# @param array parameters
# @param int total
function parseParameters(parameters, total, count) {
    hasParameter = hasExit = 0
    for (count=1; count < total; ++count) {
        if ("--stage" == parameters[count]) { ENVIRONMENT = "staging"; hasParameter = 1; continue }
        if ("--verbose" == parameters[count]) { VERBOSE = 1; continue }
        if ("--help" == parameters[count]) { printHelp(); hasExit = 1; continue }
        if ("--based" == parameters[count]) { print base64Url(parameters[count + 1]); hasExit = 1; continue }
        if ("--domain" == parameters[count]) { DOMAIN = parameters[count + 1]; hasParameter = 1; continue }
        if ("--directory" == parameters[count]) { print getDirectoryUrl(ENVIRONMENT); hasExit= 1; continue }
        if ("--encode-hex" == parameters[count]) { print encodeHex(parameters[count + 1]); hasExit = 1; continue }
        if ("--nonce" == parameters[count]) { print newNonce(ENVIRONMENT); hasExit = 1; continue }
        if ("--version" == parameters[count]) { print VERSION; hasExit = 1; continue }
    }
    if (hasExit) exit
    if (hasParameter) return
    printHelp()
    exit
}

function printHelp() {
    print sprintf(\
        "  ____________________________________________\n"\
        " /                                            \\\n"\
        "/  ACME Let's Encrypt Client In Portable Awk  /\n"\
        "\\____________________________________________/\n"\
        "\nUSAGE: awk -f acme.awk -- [OPTIONS]\n"\
        "\t--help              Print this help\n"\
        "\t--stage             Set environment to staging\n"\
        "\t--based string      Encode string as base64Url\n"\
        "\t--directory         Print the directory URL\n"\
        "\t--domain string     Set domain for certificate\n"\
        "\t--encode-hex string Encode hex string\n"\
        "\t--nonce             Fetch anti-replay nonce\n"\
        "\t--version           Print version\n"\
        "\t--verbose           Print verbose messages\n"\
    )
}

function verbose(message, parameters) {
    if (VERBOSE) print sprintf("\t%s\t%s", message, parameters)
}

function doRequest(url, body, environment, nonce, auth, command, protected, payload, signature, jws, code, response) {
    # nonce = "0004ENA2VTUuGSZD9WxGYWVpwSI0SdbQEhSt9m1qPG1cLCM"
    verbose("NONCE", "\t"nonce)
    verbose("NONCE-LENGTH", length(nonce))
    # verbose("AUTH", auth)
    protected = getProtected(auth, nonce, url)
    # verbose("PROTECTED", protected)
    payload = base64Url(body)
    verbose("ENCODED-PAYLOAD", payload)
    signature = getSignature(protected, payload)
    # verbose("SIGNATURE", signature)
    jws = "{ \"protected\": \""protected"\", \"payload\": \""payload"\", \"signature\": \""signature"\" }"
    # verbose("JWS", jws)
    verbose("JWS-LENGTH", length(jws))

    command = "curl --silent --dump-header .headers --show-error --write-out ' %{http_code}' -H 'Content-Type: application/jose+json' --url "url" --data '"jws"'"

    while (command | getline > 0) response = response $0
    close(command)

    code = getResponseCode(response)
    verbose("RESPONSE-CODE", code)
    verbose("LOCATION", getResponseHeader("location"))
    if (200 == code || 201 == code) return response
    getDetail(response)

    return response
}

function getChallengeUrl(response, url) {

    # https://acme-staging-v02.api.letsencrypt.org/acme/chall-v3/164735504/7MuG2g
    command = "printf '%s' '"response"' | sed 's#.*\"type\"[^\"]*\"http-01\",[^\"]*\"status\"[^\"]*\"[^\"]*\",[^\"]*\"url\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) url = url $0
    close(command)
    verbose("CHALLENGE-URL", url)

    return url
}

function getCertificateUrl(response, url) {

    command = "printf '%s' '"response"' | sed 's#.*\"certificate\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) url = url $0
    close(command)
    verbose("CERTIFICATE-URL", url)

    return url
}

function getOrderStatus(response, status) {

    command = "printf '%s' '"response"' | sed 's#.*\"status\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) status = status $0
    close(command)
    verbose("ORDER-STATUS", status)

    return status
}

function getChallengeToken(response, token) {

    command = "printf '%s' '"response"' | sed 's#.*\"token\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) token = token $0
    close(command)
    verbose("CHALLENGE-TOKEN", token)

    return token
}

function getFinalizeUrl(response, url) {

    command = "printf '%s' '"response"' | sed 's#.*\"finalize\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) url = url $0
    close(command)
    verbose("FINALIZE-URL", url)

    return url
}

function getAuthUrl(response, url) {

    command = "printf '%s' '"response"' | sed 's#.*\"authorizations\"[^\"]*\"\\([^\"]*\\).*#\\1#'"

    while (command | getline > 0) url = url $0
    close(command)
    verbose("AUTHORIZE-URL", url)

    return url
}

function getDetail(response, detail) {

    command = "printf '%s' '"response"' | sed 's#.*\"detail\"[^\"]*\"\\(.*\\)\",.*#\\1#'"

    while (command | getline > 0) detail = detail $0
    close(command)
    verbose("RESPONSE-DETAIL", detail)

    return detail
}

function getJwk(domain, exponent, modulus, jwk) {
    exponent = getAccountExponent(domain)
    verbose("EXPONENT", exponent)
    modulus = getAccountModulus(domain)
    # verbose("MODULUS", modulus)
    jwk = "\"jwk\": { \"e\": \""exponent"\", \"kty\": \"RSA\", \"n\": \""modulus"\" }"

    return jwk
}

function getKid(accountUrl) {
    return "\"kid\": \""accountUrl"\""
}

function getResponseHeader(key, header) {

    while ((getline < ".headers") > 0) {

        if (sprintf("%s:", key) != $1) continue
        gsub(/[ \t\r\n]*/, "", $2)
        header = header $2
    }
    close(".headers")

    return header
}

function getResponseCode(response) {
    return substr(response, length(response) -2, 3)
}

function getPayload(body, command, payload) {

    command = "printf '"body"' | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) payload = payload $0
    close(command)

    return payload
}

function getProtected(auth, nonce, url, command, protected) {
    # verbose("HEADER", "{ \"alg\": \"RS256\", "auth", \"nonce\": \""nonce"\", \"url\": \""url"\" }")
    command = "printf '{ \"alg\": \"RS256\", "auth", \"nonce\": \""nonce"\", \"url\": \""url"\" }' | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) protected = protected $0
    close(command)

    return protected
}

function getSignature(protected, payload, command, signature) {

    command = "printf \"%s\" \""protected"."payload"\" | openssl dgst -sha256 -sign "DOMAIN"/account.key | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) signature = signature $0
    close(command)

    return signature
}

# Create account key
# @param string domain
function createAccountKey(domain) {
    system("mkdir -p "domain)
    system("chmod -f 600 "domain"/account.key")
    system("openssl genrsa 4096 > "domain"/account.key")
    system("chmod -f 400 "domain"/account.key")
    system("openssl rsa -in "domain"/account.key -out "domain"/account.pub -pubout")
}

# Create account public key exponent https://tools.ietf.org/html/rfc7518#section-6.3.1.2
# @param string domain
# @return string Encoded exponent
function getAccountExponent(domain, command, exponent) {

    # command = "openssl rsa -pubin -in "domain"/account.pub -text -noout | grep Exponent | awk '{ printf \"%0.32x\",$2}' | sed 's/^\\(00\\)*//g'"

    # while (command | getline > 0) exponent = exponent $0
    # close(command)
    # exponent = encodeHex(exponent)

    return "AQAB"
}

# Create account public key modulus https://tools.ietf.org/html/rfc7518#section-6.3.1.1
# @param string domain
# @return string Encoded modulus
function getAccountModulus(domain, command, modulus) {

    command = "openssl rsa -pubin -in "domain"/account.pub -modulus -noout | sed 's#^Modulus=##'"

    while (command | getline > 0) modulus = modulus $0
    close(command)

    return encodeHex(modulus)
}

# Generate thumbprint https://tools.ietf.org/html/rfc7638
# @return string
function getThumbprint(exponent, modulus, thumbprint, command) {

    command = "printf '{\"e\":\""exponent"\",\"kty\":\"RSA\",\"n\":\""modulus"\"}' | openssl dgst -sha256 -binary | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) thumbprint = thumbprint $0
    close(command)
    verbose("THUMBPRINT", thumbprint)

    return thumbprint
}

# Encode to base64Url https://tools.ietf.org/html/rfc4648#section-5
# @param content string
# @return string
function base64Url(content, command, encoded) {

    command = "printf '%s' '"content"' | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) encoded = encoded $0
    close(command)

    return encoded
}

function encodeHex(hex, char, pair, format, command, encoded) {

    for (char=1; char <= length(hex); ++char) {
        pair = substr(hex, char, 1)substr(hex, ++char, 1)
        if (length(pair) < 2) continue
        format = format "\\x"pair
    }
    command = "printf \""format"%s\" | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) encoded = encoded $0
    close(command)

    return encoded
}

# Request order
function getOrder(environment, domain, url, auth, payload, nonce, response) {

    payload = ""
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Get authorization
function getAuthorization(environment, domain, url, auth, payload, nonce, response) {

    payload = ""
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Respond to challenge
function doChallenge(environment, domain, url, auth, payload, nonce, response) {

    payload = "{}"
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Validate Order
function validateOrder() {
}

# Create domain private key
# @param domain string
function createDomainKey(domain) {
    system("mkdir -p "domain)
    system("printf '' > "domain"/domain.key")
    system("chmod -f 600 "domain"/domain.key")
    system("openssl genrsa 4096 > "domain"/domain.key")
    system("chmod -f 400 "domain"/domain.key")
}

# Certificate Signing Request
function createCertificateRequest(domain) {

    # createDomainKey(domain)
    system("openssl req -new -sha256 -key "domain"/domain.key -subj /CN="domain" -reqexts SAN -config openssl.conf > "domain"/domain.csr")

    return encodeCertificate(domain)
}

function encodeCertificate(domain, command, encoded) {

    command = "openssl req -in "domain"/domain.csr -inform PEM -outform DER | base64 | tr '/+' '_-' | tr -d '='"

    while (command | getline > 0) encoded = encoded $0
    close(command)
    verbose("ENCODED-CSR", encoded)

    return encoded
}

# Finalize Order
function finishOrder(environment, domain, url, auth, payload, nonce, response) {

    payload = "{ \"csr\": \""createCertificateRequest(domain)"\" }"
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Download Certificate
function fetchCertificate(environment, domain, url, auth, payload, nonce, response) {

    payload = ""
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    system("echo "response" | awk '/-----BEGIN CERTIFICATE-----/,0' > "domain"/domain.crt")
}

# Create new order https://tools.ietf.org/html/rfc8555#section-7.4
function newOrder(environment, domain, auth, url, payload, nonce, response) {
    url = getUrl("newOrder", environment)
    verbose("REQUEST-ORDER", url)
    payload = "{ \"identifiers\": [ { \"type\": \"dns\", \"value\": \""domain"\" } ] }"
    nonce = getResponseHeader("replay-nonce")
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Create new account https://tools.ietf.org/html/rfc8555#section-7.3
function newAccount(environment, domain, auth, url, payload, nonce, response) {
    url = getUrl("newAccount", environment)
    verbose("REQUEST-ACCOUNT", url)
    payload = "{\"termsOfServiceAgreed\":true}"
    auth = getJwk(domain)
    nonce = newNonce(environment)
    response = doRequest(url, payload, environment, nonce, auth)

    return response
}

# Fetch anti-replay nonce https://tools.ietf.org/html/rfc8555#section-7.2
# @return string Anti-replay NONCE
function newNonce(environment, url, command) {
    url = getUrl("newNonce", environment)
    command = "curl -s -I "url

    while (command | getline > 0) {
        if ("replay-nonce:" != $1) continue
        close(command)
        gsub(/[ \t\r\n]*/, "", $2)

        return $2
    }
    close(command)
    print sprintf("Failed to get nonce by URL \'%s\'", url)
}

# Fetch URL from directory by key
# @param key string JSON property
# @return string JSON property value
function getUrl(key, environment, command) {
    command = "curl -s "getDirectoryUrl(environment)

    while(command | getline > 0) {

        if (sprintf("\"%s\":", key) != $1) continue
        close(command)

        return substr($2, 2, length($2)-3)
    }
    close(command)

    print sprintf("Failed to get URL by key \'%s\'", key)
}

# Get LetsEncrypt API directory https://letsencrypt.org/docs/
# @return string
function getDirectoryUrl(environment) {
    if ("production" == environment) return "https://acme-v02.api.letsencrypt.org/directory"

    return "https://acme-staging-v02.api.letsencrypt.org/directory"
}
