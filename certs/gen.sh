# delete threexsiting Root certificate if it already exists so that we can create a new one
sudo security delete-certificate -c ChidiAuthority 

# -x509 is the type of certificate we want to generate
# -newkey rsa:4096  key-length is 4096
# -sha256 the hash algorithm
# Generate Certificate Authority's Private Key and Self-Signed Public Key certificate
openssl req -x509 \
  -newkey rsa:4096 \
  -nodes \
  -days 365 \
  -keyout localhost_ca_key.pem \
  -out localhost_ca_cert.pem \
  -subj /C=CA/ST=SK/L=Saskatoon/O=TestOrganizationName/CN=ChidiAuthority/ \
  -sha256

# Adding the Root Certificate to macOS Keychain Access App. link https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" localhost_ca_cert.pem

# ncomment if you want to see text format of the certificate
# echo "CA self-signed certificate"
# openssl x509 -in localhost_ca_cert.pem -noout -text

# Generate web server's Private Key and Certificate Signing Request (CSR)
openssl req \
  -newkey rsa:4096 \
  -nodes \
  -keyout server_key.pem \
  -out server_csr.pem \
  -subj /C=CA/ST=SK/L=Saskatoon/O=TestOrganizationName/CN=test-app-name-client_ca/ \
  -sha256

# Use the CA's private key to sign the web server's CSR and get back the self signed certificate
openssl x509 -req \
  -CAkey localhost_ca_key.pem \
  -in server_csr.pem \
  -days 60 \
  -CA localhost_ca_cert.pem \
  -CAcreateserial \
  -out server_cert.pem \
  -extfile server-ext.cnf \
  -sha256

# uncomment if you want to see text format of the certificate
# echo  "Server's signed certificate"
# openssl x509 -in server_cert.pem -noout -text

# To verify that the server certificate is valid
openssl verify -CAfile localhost_ca_cert.pem server_cert.pem

# remove all Certificate Signing Request because we already have signed certificate for the web server and/or client (if we are using implementing Mutual TLS which we are not for this project)
rm *_csr.pem