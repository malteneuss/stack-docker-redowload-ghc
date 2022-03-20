stack build
#MYPATH=$(stack path --local-install-root)/bin/workler
#MYPATH=.stack-work/install/x86_64-linux/220ce821d931b8f69c1d1b99cfa95c49732ea31d0057d7ec641147bf9199ece0/8.10.7/bin/workler
MYPATH=dist/workler
BINARY_PATH=${MYPATH} docker-compose build