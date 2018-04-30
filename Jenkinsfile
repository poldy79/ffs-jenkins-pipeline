#!/usr/bin/env groovy
ources() {
    //checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/v2017.1.7']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: "refs/tags/${params.GLUON}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
    //git branch: 'master', changelog: false, poll: false, url: 'https://github.com/freifunk-gluon/gluon.git'
    dir('site') {
        //checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/ffs-1.3']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-stuttgart/site-ffs.git']]]
        git branch: 'master', changelog: false, poll: false, url: 'https://github.com/freifunk-stuttgart/site-ffs.git'
        //git branch: 'feature/specify-build-date', changelog: false, poll: false, url: 'https://github.com/freifunk-stuttgart/site-ffs.git'
    }
}

def buildArch() {
    echo "step ${STAGE_NAME}"
    echo "BUILD_DATE: ${BUILD_DATE}"
    if (params.clean_workspace) {
        sh 'rm -Rf *'
    }
    fetchSources()
    dir('output') { deleteDir() }

    if (params.make_clean) {
        sh "nice make GLUON_TARGET=${STAGE_NAME} clean"
    }
    sh "nice make update"
    sh "nice make -j${params.processors} ${VERBOSE} BROKEN=${params.broken} GLUON_BRANCH=stable GLUON_TARGET=${STAGE_NAME} BUILD_DATE=${BUILD_DATE}"
    sh "find output/"
    stash name: "${STAGE_NAME}", includes: "output/images/*/*, output/modules/*/*/*/*, output/packages/*/*/*/*"
}

def architectures = ['x86-x64', 'x86-generic', 'ar71xx-generic','brcm2708-bcm2710' ] 

pipeline {
    agent none
    parameters {
        
        booleanParam(name: 'ar71xx_generic', defaultValue: true, description: '')
        booleanParam(name: 'ar71xx_mikrotik', defaultValue: true, description: '')
        booleanParam(name: 'ar71xx_nand', defaultValue: true, description: '')
        booleanParam(name: 'ar71xx_tiny', defaultValue: true, description: '')
        booleanParam(name: 'brcm2708_bcm2708', defaultValue: true, description: '')
        booleanParam(name: 'brcm2708_bcm2709', defaultValue: true, description: '')
        booleanParam(name: 'brcm2708_bcm2710', defaultValue: false, description: '')
        booleanParam(name: 'ipq806x', defaultValue: true, description: '')
        booleanParam(name: 'mpc85xx_generic', defaultValue: true, description: '')
        booleanParam(name: 'mvebu', defaultValue: true, description: '')
        booleanParam(name: 'ramips_mt7621', defaultValue: true, description: '')
        booleanParam(name: 'ramips_mt7628', defaultValue: true, description: '')
        booleanParam(name: 'ramips_rt305x', defaultValue: true, description: '')
        booleanParam(name: 'sunxi', defaultValue: true, description: '')
        booleanParam(name: 'x86_generic', defaultValue: true, description: '')
        booleanParam(name: 'x86_geode', defaultValue: true, description: '')
        booleanParam(name: 'x86_64', defaultValue: true, description: '')
        choice(name: 'verbose', choices: ' \nV=s', description: 'verbose')
        string(defaultValue: "4", description: 'Number of processors', name: 'processors')
        booleanParam(name: 'make_clean', defaultValue: false, description: '' )
        booleanParam(name: 'clean_workspace', defaultValue: false, description: '' )
        choice(name: 'broken', choices: '1\n0', description: '')
        string(defaultValue: "", name: 'BUILD_DATE', description: 'Example: 2018.03.17-23.01')
    }
    options {
        timestamps()
    }


    stages {
        stage('init') {
            agent { label 'master'}
            steps {
                fetchSources()
                script {
                    
                    BUILD_DATE=params.BUILD_DATE
                }
                echo "${BUILD_DATE} in setup"
            }
        }
        stage('compile') {

            parallel {
                stage('ar71xx-generic') {
                    agent { label 'master'}
                    when { expression {return params.ar71xx_generic } }
                    steps { script { buildArch()} }
                }
                stage('ar71xx-nand') {
                    agent { label 'master' }
                    when { expression {return params.ar71xx_nand } }
                    steps { script { buildArch()} }
                }
                stage('ar71xx-tiny') {
                    agent { label 'master' }
                    when { expression {return params.ar71xx_tiny } }
                    steps { script { buildArch()} }
                }
                stage('brcm2708-bcm2708') {
                    agent { label 'master' }
                    when { expression {return params.brcm2708_bcm2708 } }
                    steps { script { buildArch()} }
                }
                stage('brcm2708-bcm2709') {
                    agent { label 'master' }
                    when { expression {return params.brcm2708_bcm2709 } }
                    steps { script { buildArch()} }
                }
                stage('brcm2708-bcm2710') {
                    agent { label 'master'}
                    when { expression {return params.brcm2708_bcm2710 } }
                    steps { script { buildArch()} }
                }
                stage('ipq806x') {
                    agent { label 'master'}
                    when { expression {return params.ipq806x } }
                    steps { script { buildArch()} }
                }
                stage('mpc85xx-generic') {
                    agent { label 'master'}
                    when { expression {return params.mpc85xx_generic } }
                    steps { script { buildArch()} }
                }
                stage('mvebu') {
                    agent { label 'master'}
                    when { expression {return params.mvebu } }
                    steps { script { buildArch()} }
                }
                stage('ramips-mt7621') {
                    agent { label 'master'}
                    when { expression {return params.ramips_mt7621 } }
                    steps { script { buildArch()} }
                }
                stage('ramips-mt7628') {
                    agent { label 'master'}
                    when { expression {return params.ramips_mt7628 } }
                    steps { script { buildArch()} }
                }
                stage('ramips-rt305x') {
                    agent { label 'master'}
                    when { expression {return params.ramips_rt305x } }
                    steps { script { buildArch()} }
                }
                stage('sunxi') {
                    agent { label 'master'}
                    when { expression {return params.sunxi } }
                    steps { script { buildArch()} }
                }
                stage('x86-generic') {
                    agent { label 'master'}
                    when { expression {return params.x86_generic } }
                    steps { script { buildArch()} }
                }
                stage('x86-genode') {
                    agent { label 'master'}
                    when { expression {return params.x86_genode } }
                    steps { script { buildArch()} }
                }
                stage('x86-64') {
                    agent { label 'master'}
                    when { expression {return params.x86_64 } }
                    steps { script { buildArch()} }
                }
            }
        }
        
        stage('manifest') {
            agent { label 'master'}
            steps {
                script {
                    echo "step ${STAGE_NAME}"
                    dir('output') { deleteDir() }
    
                    if (params.ar71xx_generic) { unstash "ar71xx-generic" }
                    if (params.ar71xx_nand) { unstash "ar71xx-nand" }
                    if (params.ar71xx_tiny) { unstash "ar71xx-tiny" }
                    if (params.brcm2708_bcm2708 ) { unstash "brcm2708-bcm2708" }
                    if (params.brcm2708_bcm2709 ) { unstash "brcm2708-bcm2709" }
                    if (params.brcm2708_bcm2710 ) { unstash "brcm2708-bcm2710" }
                    if (params.x86_generic) { unstash "x86-generic" }
                    if (params.x86_genode) { unstash "x86-genode" }
                    if (params.x86_64){ unstash "x86-64" }
                    
                    sh "make manifest GLUON_BRANCH=stable"
                    sh "make manifest GLUON_BRANCH=beta"
                    sh "make manifest GLUON_BRANCH=nightly"
                    
                    archiveArtifacts artifacts: 'output/images/*/*, output/modules/*/*/*/*, output/packages/*/*/*/*', fingerprint: true
                }
            }
        }
    }
}

/*
make -j$CORES GLUON_TARGET=ar71xx-tiny $OPTIONS
make -j$CORES GLUON_TARGET=ar71xx-nand $OPTIONS
make -j$CORES GLUON_TARGET=brcm2708-bcm2708 $OPTIONS
make -j$CORES GLUON_TARGET=brcm2708-bcm2709 $OPTIONS
make -j$CORES GLUON_TARGET=mpc85xx-generic $OPTIONS
make -j$CORES GLUON_TARGET=x86-generic $OPTIONS
make -j$CORES GLUON_TARGET=x86-geode $OPTIONS
make -j$CORES GLUON_TARGET=x86-64 $OPTIONS
make -j$CORES GLUON_TARGET=ar71xx-mikrotik $OPTIONS
make -j$CORES GLUON_TARGET=ipq806x $OPTIONS
make -j$CORES GLUON_TARGET=mvebu $OPTIONS
make -j$CORES GLUON_TARGET=ramips-mt7621 $OPTIONS
make -j$CORES GLUON_TARGET=ramips-mt7628 $OPTIONS
make -j$CORES GLUON_TARGET=ramips-rt305x $OPTIONS
make -j$CORES GLUON_TARGET=sunxi $OPTIONS
 */
