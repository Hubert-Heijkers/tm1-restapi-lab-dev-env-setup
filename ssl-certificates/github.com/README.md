# github.com
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./digicert.cer -label digicert -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./digicert-sha2.cer -label digicert-sha2 -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -add -db %1/ssl/ibmtm1.kdb -file ./github.com.cer -label github_com -stashed -format ascii -trust enable
./gsk8capicmd_64.exe -cert -validate -db %1/ssl/ibmtm1.kdb -label github_com -stashed
