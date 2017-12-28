#!/bin/bash
CORES=`nproc`
NICE="nice"

if [ "$verbose_build" = true ] ; then
    V=s
fi

if [ "$verbose_build" = false ] ; then
    V=""
fi

if [ "$scratchbuild" = true ] ; then
	echo Scratchbuild
	rm -Rf gluon
    update=true
    clean=false
fi

if [ ! -d gluon ]; then
	git clone $gluon_repo gluon
    update=true
    clean=false
fi

cd gluon
rm -Rf output
git remote set-url origin $gluon_repo
git fetch
git checkout $gluon_version

export GLUON=`git log --pretty=format:'%h' -n 1`

if [ ! -d site ]; then
	git clone https://github.com/freifunk-stuttgart/site-ffs.git site
fi
cd site
git remote set-url origin https://github.com/freifunk-stuttgart/site-ffs.git site
git pull --no-edit
git checkout $site_version
export SITE=`git log --pretty=format:'%h' -n 1`
cd ..

DATE=`date '+%Y.%m.%d-%H.%M'`

if  [ -e ../DATE ]
then
    DATE=`cat ../DATE`
    rm -f ../DATE
fi

GLUONVERSION=`git log --pretty=format:'%h' -n 1`
SITEVERSION=`git -C site log --pretty=format:'%h' -n 1`
export GLUONRELEASE=0.8+$DATE-g.$GLUONVERSION-s.$SITEVERSION
echo $GLUONRELEASE

if [ "$update" = true ] ; then make -j$CORES update ; fi

if [ "$ar71xx_generic" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=ar71xx-generic V=$V ; fi
if [ "$ar71xx_nand" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=ar71xx-nand V=$V ; fi 
if [ "$brcm2708_bcm2708" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=brcm2708-bcm2708 V=$V ; fi 
if [ "$brcm2708_bcm2709" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=brcm2708-bcm2709 V=$V ; fi 
if [ "$mpc85xx_generic" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=mpc85xx-generic V=$V ; fi 
if [ "$ramips_rt305x" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=ramips-rt305x V=$V ; fi 
if [ "$x86_generic" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=x86-generic V=$V ; fi 
if [ "$x86_kvm_guest" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=x86-kvm_guest V=$V ; fi 
if [ "$x86_xen_domu" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=x86-xen_domu V=$V ; fi 
if [ "$x86_64" = true ] ; then $NICE make -j$CORES BROKEN=$BROKEN GLUON_BRANCH=$GLUON_BRANCH GLUON_TARGET=x86-64 V=$V ; fi 

if [ "$manifest" = true ] ; then
	make manifest GLUON_BRANCH=stable
	make manifest GLUON_BRANCH=beta
	make manifest GLUON_BRANCH=nightly
fi


