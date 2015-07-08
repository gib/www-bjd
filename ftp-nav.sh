#!/bin/bash

HOST=ftp.betsyjoycedesign.com
USER=betsyjoy
PASS=Fiona1!

# Call 1. Uses the ftp command with the -inv switches.
#-i turns off interactive prompting.
#-n Restrains FTP from attempting the auto-login feature.
#-v enables verbose and progress.

ftp -inv $HOST << EOF

user $USER $PASS

cd www

identity/traditions-made-modern/1
identity/artcare/1
identity/julie-dean/1
identity/disability-rights/1
identity/teleosis/1
identity/heather-and-french/1
identity/king-hickory-furniture/1
identity/rockwood/1
identity/innovative-teacher-project/1
identity/caltrans/1

mkdir identity
cd identity

mkdir rockwood
cd rockwood
mkdir 1
cd 1
put default.asp
cd ../..

mkdir innovative-teacher-project
cd innovative-teacher-project
mkdir 1
cd 1
put default.asp
cd ../..

mkdir caltrans
cd caltrans
mkdir 1
cd 1
put default.asp
cd ../..



bye

EOF
