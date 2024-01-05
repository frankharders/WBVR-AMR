##!/bin/bash
#
#
# if files were downloaded from a portal or otherwise and a md5sum is constructed by the service supplier files must be check if the download of all the file is completed succesful

# variables used
DOWNLOADcheck="$PWD"/md5sum.log;

SETTING="USER INPUT";
read -p "Enter file name for md5 check: " SETTING;

echo -e "fileName=$SETTING";

if [ -f "$SETTING" ];then

  echo "file is present"

READin="$SETTING";

  # script used
    md5sum -c "$READin" > "$DOWNLOADcheck" 2>&1;
	
	cat "$DOWNLOADcheck" | tail -n1;
	cat "$DOWNLOADcheck" | grep 'FAILED';
	
else

  echo "file could not be found, start script again and use the correct name"

exit 1

fi

# end

