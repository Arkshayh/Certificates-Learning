# Exo 1
## Actor : Belgian Education Authority

The actor create an EC private key 
```bash
# cwd : be_education_authority\private
openssl ecparam -name prime256v1 -genkey -noout -out be_ea_key.pem
```
Create a be_ea_key.pem that contains the private key


The actor create the certificate with the private key
```bash
# cwd : be_eduction_authority\private

openssl req -new -x509 -key ../private/be_ea_key.pem -out be_ea_cert.pem -days 3650

after this command respond with :
* BE
* Hainaut 
* Charleroi
* Belgium Education Authority
* (enter)
* Belgian Education Authority DSC01
* (enter)
```
Create the certificate of the belgium authority with the private key that contains the public key.



The actor give the certificate to the central Authority
```bash
cp be_ea_cert.pem ../../central_education_authority/tmp
```
Copy paste the certificate in the secg4-homework3\central_education_authority\tmp folder



# Exo 2
## Actor : Central repository

Publish the DSC to his central repository 
```bash
#cwd : secg4-homework3\central_education_authority\tmp

fingerprint=$(openssl x509 -in be_ea_cert.pem -noout -fingerprint -sha1 | tr -d ':' | tr -d ' ' | sed s/SHA1Fingerprint=//g) 

mv be_ea_cert.pem $fingerprint.pem

mv dscfingerprint.pem ../pubrepo/

//dscfingerprint.pem = new name of the file.pem

```
We get the dscfingerprint and remove the useless caracters to rename the certificate and move it in the public repository


# Exo 3
## Actor : He2b School

Generate an unsigned DPSE
```bash
#cwd : secg4-certificates\secg4-homework3\he2b_school\tmp

echo $'Cotton\nIan\n55019\nBE\nHaute Ecole Bruxelles-Brabant\n2021-09-15\n2022-09-14' > 55019.txt

//replace 55019 by your matricule
```
We create the DPSE and rename it.

# Exo 4
## Actor : Belgian Education Authority

We sign the document
```bash
#cwd : secg4-homework3

cp he2b_school/tmp/55019.txt be_education_authority/tmp/

#cwd : secg4-homework3\be_education_authority\tmp

openssl dgst -sha1 -sign ../private/be_ea_key.pem -out 55019.signatureNot64.txt 55019.txt
openssl enc -base64 -in 55019.signatureNot64.txt -out 55019.signature.txt
```

We copy paste the unsigned DPSE then we sign it with the private key into a temporary file 55019.signatureNot64.txt because it's encoded in base64
Then we encode it in  base64 in write it in another text file 55019.signature.txt

We compute the dscfingerprint
```bash
#cwd secg4-homework3\be_education_authority\tmp
fingerprint=$(openssl x509 -in ../private/be_ea_cert.pem -noout -fingerprint -sha1 | tr -d ':' | tr -d ' ' | sed s/SHA1Fingerprint=//g) 
echo $fingerprint > 55019.dscfingerprint.txt
```
Create a text file 55019.dscfingerprint.txt that contains the fingerprint of the associated certificate


# Exo 5
## Actor : Belgian Education Authority

Copy the signature and fingerprint files to the school's tmp/ folder
- The HE2B School received the signature of its DPSE document and the DSC fingerprint. The
files are in the tmp/ folder.
- Assemble the signed DPSE document and store it in the school's dpse storage, with the name 12345.dpse.txt


```bash
# cwd : secg4-certificates\secg4-homework3
cp be_education_authority/tmp/55019.signature.txt he2b_school/tmp/  
cp be_education_authority/tmp/55019.dscfingerprint.txt he2b_school/tmp/

# cwd : secg4-certificates\secg4-homework3\he2b_school\tmp
 cat 55019.signature.txt >> 55019.txt
 cat 55019.dscfingerprint.txt >> 55019.txt
 mv 55019.txt ../dpse/55019.dpse.txt
```
We just copy the content of the files 55019.signature.txt and 55019.dscfingerprint.txt in the file 55019.txt then we move it in the dpse folder and rename it. 




# Exo 6

Verify if the dpse is valide part1
 ```bash
 #cwd = secg4-homework3\he2b_school\dpse
 signaturePart1=$(sed '8!d' 55019.dpse.txt)
 signaturePart2=$(sed '9!d' 55019.dpse.txt)
 signature=${signaturePart1}${signaturePart2}
 dscfingerprint=$(sed '10!d' 55019.dpse.txt)
 echo $signature > ../tmp/currentSignature.txt 
 echo $dscfingerprint > ../tmp/currentDscfingerprint.txt
 head -7 55019.dpse.txt >> ../tmp/basicInfo.txt


 #The signature/dscfingerprint are already in the tmp file but we don't use them because they are normally deleted between each Exercice 
 ```
 We get the signature of the dpse then write it in a file, it will be useful to check if the dpse is valid

Verify if the dpse is valide part2
```bash
#cwd = secg4-homework3\he2b_school\tmp
openssl base64 -d -in currentSignature.txt -out signature.bin
dscfingerprintToSearch=$(cat currentDscfingerprint.txt).pem

 [ -f ../../central_education_authority/pubrepo/$dscfingerprintToSearch ] && echo "The certificate exists in the central education authority !"
 #If the certificate exist this message above should appear
```
We convert the signature in binary and check if the certificate exist in the central repository

Verify if the dpse is valid part3
```bash
#cwd = secg4-homework3\he2b_school\tmp
openssl x509 -in ../../central_education_authority/pubrepo/$dscfingerprintToSearch -pubkey -noout > pubKey.pem

openssl dgst -sha1 -verify pubKey.pem -signature signature.bin basicInfo.txt
#If the signature is valid the message : "Verified OK" must appear
```
We get the public key from the certificate of the central education authority then we use it to check if the signature is valid. 

# Exo 7

Check of the different tests of Absil
```bash
#cwd = secg4-homework3\test_files_from_ABS\dpse_tests

198822 INVALID, because the DPSE is outdated

243296 VALID.

289670 INVALID, signature does not match.

315878 INVALID, because the DPSE is outdated and the signature does not match.

578158 VALID.
```

Check of the different tests of PHA 
```bash
#cwd = secg4-homework3\test_files_from_PHA\dpse_tests

190403 INVALID, because the DPSE is outdated and the signature does not match.

311221 INVALID, because the DPSE is outdated.

731986 INVALID, because the signature does not match.

816187 VALID.

988818 VALID.
``` 

Bash script to test DPSE :
```bash
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
```