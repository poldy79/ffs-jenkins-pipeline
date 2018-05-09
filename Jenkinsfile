#!/usr/bin/env groovy
def fetchSources() {
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: "${params.gluon}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
    dir('site') {
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: "${params.site}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-stuttgart/site-ffs.git']]]
    }
}

def buildArch(archs) {
    echo "step ${STAGE_NAME}"
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
        if (params.verbose) {
            sh "nice make -j1 V=s BROKEN=${params.broken} GLUON_BRANCH=stable GLUON_TARGET=${arch} BUILD_DATE=${BUILD_DATE}"
        } else {
            sh "nice make -j`nproc` BROKEN=${params.broken} GLUON_BRANCH=stable GLUON_TARGET=${arch} BUILD_DATE=${BUILD_DATE}"
        }
    }
    allArchs << "${STAGE_NAME}"
    stash name: "${STAGE_NAME}", includes: "output/images/*/*, output/modules/*/*/*/*, output/packages/*/*/*/*"
}

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
        booleanParam(name: 'verbose', defaultValue: false, description: '')
        booleanParam(name: 'make_clean', defaultValue: false, description: '' )
        booleanParam(name: 'clean_workspace', defaultValue: false, description: '' )
        choice(name: 'broken', choices: '1\n0', description: '')
        string(defaultValue: "refs/tags/v2017.1.7", name: 'gluon', description: 'gluon release tag')
        string(defaultValue: "*/master", name: 'site', description: 'site release tag, branch or commit')
    }

    options {
        timestamps()
    }

    stages {
        stage('init') {
            agent { label 'master'}
            steps { script {
                allArchs = []
                fetchSources()
                BUILD_DATE = sh(returnStdout: true, script: 'date +%Y-%m-%d').trim()
                echo "${BUILD_DATE} in setup"
            } }
        }
        stage('compile') {
            parallel {
                stage('ar71xx') {
                    agent any
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
                    agent any
                    when { expression {return params.brcm2708_bcm2708 || params.brcm2708_bcm2709 || params.brcm2708_bcm2710 } }
                    steps { script { 
                        def archs = []
                        if (params.brcm2708_bcm2708) { archs << 'brcm2708-bcm2708'}
                        if (params.brcm2708_bcm2709) { archs << 'brcm2708-bcm2709'}
                        if (params.brcm2708_bcm2710) { archs << 'brcm2708-bcm2710'}
                        echo "Archs for ${STAGE_NAME}: ${archs}"
                        buildArch(archs)
                    } }
                }
                stage('ipq806x') {
                    agent any
                    when { expression {return params.ipq806x } }
                    steps { script { 
                        def archs = []
                        buildArch(["ipq806x"])
                    } }
                }
                stage('mpc85xx-generic') {
                    agent any
                    when { expression {return params.mpc85xx_generic } }
                    steps { script { 
                        buildArch(["mpc85xx-generic"])
                    } }
                }
                stage('mvebu') {
                    agent any
                    when { expression {return params.mvebu } }
                    steps { script { 
                        buildArch(["${STAGE_NAME}"])
                    } }
                }
                stage('ramips-mt7621') {
                    agent any
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
                    agent any
                    when { expression {return params.sunxi } }
                    steps { script { 
                        buildArch(["${STAGE_NAME}"])
                    } }
                }
                stage('x86') {
                    agent any
                    when { expression {return params.x86_generic || params.x86_genode || params.x86_64 } }
                    steps { script { 
                        def archs = []
                        if (params.x86_generic) { archs << 'x86-generic' }
                        if (params.x86_genode) { archs << 'x86-genode' }
                        if (params.x86_64) { archs << 'x86-64' }
                        echo "Archs for ${STAGE_NAME}: ${archs}"
                        buildArch(archs)
                    } }
                }
            }
        }
        
        stage('manifest') {
            agent { label 'master'}
            steps { script {
                    fetchSources()
                    echo "step ${STAGE_NAME}"
                    echo "Archs: ${allArchs}"
                    dir('output') { deleteDir() }
                    
                    for (arch in allArchs) {
                        unstash "${arch}"
                    }
                    
                    sh """
                        make manifest GLUON_BRANCH=stable
                        make manifest GLUON_BRANCH=beta
                        make manifest GLUON_BRANCH=nightly
                    """
                    archiveArtifacts artifacts: 'output/images/*/*, output/modules/*/*/*/*, output/packages/*/*/*/*', fingerprint: true
            } }
        }
    }
}

