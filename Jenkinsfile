#!/usr/bin/env groovy

/*
With the provided script, the firmware can be build with jenkins. Setup
a Pipeline job and configure the pipeline definition to "Pipeline script
from SCM". Supply as SCM git and as repository
https://github.com/freifunk-stuttgart/site-ffs.git. All other options
can be left at their default. If neccessary configure the branch
specifier. The job parameters will be filled when the job is started the
first time. If you do not want to build all architectures, cancel the
buold and trigger a parameterized build where you can now choose the
architectures to be build.

The init and manifest stage will be executed on the master, all other
stages are executed on any node. This job can use eight build slaves to
build the firmware. 

On each slave, nproc is used to run make with all available cpu cores. 

Per default, all broken targets will be build also. You can choose to
run make clean before building each architecture. You can check
clean_workspace to build entirely from scratch. 

Note that bcrm2708_2710 is not supported with v2017.1.7, but on gluon
master branch. It will be supported in a later release. 

If you want to use a different gluon version, you can modify the gluon
parameter, if you want to use a custom site-ffs version, you can modify
the site parameter
*/

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
    sh "find output/images"
    sh "find output/packages"
    stash name: "${STAGE_NAME}", includes: "output/images/*/*, output/packages/*/*/*/*"
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
        booleanParam(name: 'sunxi', defaultValue: false, description: '')
        booleanParam(name: 'x86_generic', defaultValue: true, description: '')
        booleanParam(name: 'x86_geode', defaultValue: true, description: '')
        booleanParam(name: 'x86_64', defaultValue: true, description: '')
        booleanParam(name: 'verbose', defaultValue: false, description: 'build with -j1 and V=s for debugging build errors')
        booleanParam(name: 'make_clean', defaultValue: false, description: 'execute make clean before building each architecture' )
        booleanParam(name: 'clean_workspace', defaultValue: false, description: 'delete all files in workspace before building' )
        choice(name: 'broken', choices: '1\n0', description: 'wether to build broken targets or not')
        string(defaultValue: "refs/tags/v2017.1.7", name: 'gluon', description: 'gluon release tag')
        string(defaultValue: "*/master", name: 'site', description: 'site release tag, branch or commit')
        string(defaultValue: "", name: 'deploy_to', description: 'target for rsync\nExample: www@netinfo:/home/www/html/firmware/gluon/archive/@leonard')
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
        
        stage('manifest and deploy') {
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
                    archiveArtifacts artifacts: 'output/images/*/*, output/packages/*/*/*/*', fingerprint: true
                    if (deploy_to != "") {
                        sh "rsync -avxP output/images/factory ${params.deploy_to}/${BUILD_DATE}_${BUILD_TAG}/"
                        sh "rsync -avxP output/images/sysupgrade ${params.deploy_to}/${BUILD_DATE}_${BUILD_TAG}/"
                        sh "rsync -avxP output/packages ${params.deploy_to}/${BUILD_DATE}_${BUILD_TAG}/"
                    }
            } }
        }
    }
}

