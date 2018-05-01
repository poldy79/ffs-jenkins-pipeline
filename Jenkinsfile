#!/usr/bin/env groovy
def fetchSources() {
    //checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/v2017.1.7']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: "refs/tags/${params.GLUON}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
    //git branch: 'master', changelog: false, poll: false, url: 'https://github.com/freifunk-gluon/gluon.git'
    dir('site') {
        //checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/ffs-1.3']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-stuttgart/site-ffs.git']]]
        git branch: 'master', changelog: false, poll: false, url: 'https://github.com/freifunk-stuttgart/site-ffs.git'
        //git branch: 'feature/specify-build-date', changelog: false, poll: false, url: 'https://github.com/freifunk-stuttgart/site-ffs.git'
    }
}

def buildArch(archs) {
    echo "step ${STAGE_NAME}"
    echo "BUILD_DATE: ${BUILD_DATE}"
    if (params.clean_workspace) {
        sh 'rm -Rf *'
    }
    fetchSources()
    dir('output') { deleteDir() }

    if (params.make_clean) {
        for (arch in archs) {
            sh "nice make GLUON_TARGET=${arch} clean"
        }
    }
    sh "nice make update"
    for (arch in archs) {
        sh "nice make -j${params.processors} ${VERBOSE} BROKEN=${params.broken} GLUON_BRANCH=stable GLUON_TARGET=${arch} BUILD_DATE=${BUILD_DATE}"
        //allArchs << arch
    }
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
                script {
                    def allArchs = []
                    fetchSources()
                    
                    if (params.BUILD_DATE != "") {
                        BUILD_DATE=params.BUILD_DATE
                    } else {
                        def BUILD_DATE = sh (returnStdout: true, script: 'date +%Y-%m-%d')
                    } 
                }
                echo "${BUILD_DATE} in setup"
            }
        }
        stage('compile') {

            parallel {
                stage('ar71xx') {
                    agent { label 'master'}
                    when { expression {return params.ar71xx_generic || params.ar71xx_mikrotik || params.ar71xx_nand || params.ar71xx_tiny } }
                    steps { script { 
                        def archs = []
                        if (params.ar71xx_generic) { archs << 'ar71xx-generic'}
                        if (params.ar71xx_mikrotik) { archs << 'ar71xx-mikrotik'}
                        if (params.ar71xx_nand) { archs << 'ar71xx-nand'}
                        if (params.ar71xx_tiny) { archs << 'ar71xx-tiny'}
                        buildArch(archs)
                    } }
                }
                stage('brcm2708') {
                    agent { label 'master' }
                    when { expression {return params.brcm2708_bcm2708 || params.brcm2708_bcm2709 || params.brcm2708_bcm2710 } }
                    steps { script { 
                        def archs = []
                        if (params.brcm2708_bcm2708) { archs << 'brcm2708-bcm2708'}
                        if (params.brcm2708_bcm2709) { archs << 'brcm2708-bcm2709'}
                        if (params.brcm2708_bcm2710) { archs << 'brcm2708-bcm2710'}
                        buildArch(archs)
                    } }
                }
                stage('ipq806x') {
                    agent { label 'master'}
                    when { expression {return params.ipq806x } }
                    steps { script { 
                        def archs = []
                        buildArch(["ipq806x"])
                    } }
                }
                stage('mpc85xx-generic') {
                    agent { label 'master'}
                    when { expression {return params.mpc85xx_generic } }
                    steps { script { 
                        def archs = []
                        buildArch(["mpc85xx_generic"])
                    } }
                }
                stage('mvebu') {
                    agent { label 'master'}
                    when { expression {return params.mvebu } }
                    steps { script { 
                        def archs = []
                        buildArch("mvebu")
                    } }
                }
                stage('ramips-mt7621') {
                    agent { label 'master'}
                    when { expression {return params.ramips_mt7621 || params.ramips_mt7628 || params.ramips_rt305x } }
                    steps { script { 
                        def archs = []
                        if (params.ramips_mt7621) { archs << 'ramips-mt7621' }
                        if (params.ramips_mt7628) { archs << 'ramips-mt7628' }
                        if (params.ramips_rt305x) { archs << 'ramips-rt305x' }
                        buildArch(archs)
                    } }
                }
                stage('sunxi') {
                    agent { label 'master'}
                    when { expression {return params.sunxi } }
                    steps { script { buildArch()} }
                }
                stage('x86-generic') {
                    agent { label 'master'}
                    when { expression {return params.x86_generic || params.x86_genode || params.x86_64 } }
                    steps { script { 
                        if (params.x86_generic) { archs << 'x86-generic' }
                        if (params.x86_genode) { archs << 'x86-genode' }
                        if (params.x86_64) { archs << 'x86-64' }
                        buildArch(archs)
                    } }
                }
            }
        }
        
        stage('manifest') {
            agent { label 'master'}
            steps {
                script {
                    echo "step ${STAGE_NAME}"
                    echo "Archs: ${allArchs}"
                    dir('output') { deleteDir() }
                    /* 
                    if (params.ar71xx_generic) { unstash "ar71xx-generic" }
                    if (params.ar71xx_nand) { unstash "ar71xx-nand" }
                    if (params.ar71xx_tiny) { unstash "ar71xx-tiny" }
                    if (params.brcm2708_bcm2708 ) { unstash "brcm2708-bcm2708" }
                    if (params.brcm2708_bcm2709 ) { unstash "brcm2708-bcm2709" }
                    if (params.brcm2708_bcm2710 ) { unstash "brcm2708-bcm2710" }
                    if (params.x86_generic) { unstash "x86-generic" }
                    if (params.x86_genode) { unstash "x86-genode" }
                    if (params.x86_64){ unstash "x86-64" }
                    */
                    for (arch in allArchs) {
                        sh "echo unstage ${arch}"
                    }
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
