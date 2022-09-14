#!/bin/bash

echo Entrer l id utilisateur
read var 
date=$(sed '6!d' $var.txt)
actualDate=$(date '+%Y-%m-%d')
if [[ "$date" > "$actualDate" ]] ; then     echo "The DPSE is not valid yet."; fi
date=$(sed '7!d' $var.txt)
if [[ "$date" < "$actualDate" ]] ; then     echo "The DPSE is not valid anymore."; fi
signature=$(sed '8!d' $var.txt)
dscfingerprint=$(sed '9!d' $var.txt)
echo $signature > currentSignature.txt 
echo $dscfingerprint > currentDscfingerprint.txt
head -7 $var.txt >> basicInfo.txt
openssl base64 -d -in currentSignature.txt -out signature.bin
dscfingerprintToSearch=$(cat currentDscfingerprint.txt).pem
[ -f ../central_education_authority/pubrepo/$dscfingerprintToSearch ] && echo "The certificate exists in the central education authority !"
openssl x509 -in ../central_education_authority/pubrepo/$dscfingerprintToSearch -pubkey -noout > pubKey.pem
openssl dgst -sha256 -verify pubKey.pem -signature signature.bin basicInfo.txt

rm signature.bin
rm pubKey.pem
rm currentDscfingerprint.txt
rm currentSignature.txt
rm basicInfo.txt