# gitlab.com
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./certigo.cer -label certigo -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./certigo-rsa.cer -label certigo-rsa -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./gitlab.com.cer -label gitlab_com -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -validate -db %1/ssl/ibmtm1.kdb -label gitlab_com -stashed
