#!/usr/bin/env groovy
pipeline {
    agent {
        label 'nas'
    }
    stages {
        stage('init') {
            steps {
                checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/v2016.2.6']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-gluon/gluon.git']]]
                dir('site') {
                    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: 'refs/tags/ffs-1.3']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/freifunk-stuttgart/site-ffs.git']]]
                }
            }
        }
        stage('update') {
            steps {
                sh 'make -j4 update'
            }
        }
        stage('build') {
            steps {
                sh 'make -j4 BROKEN=0 GLUON_BRANCH=stable GLUON_TARGET=ar71xx-generic'
            }
        }
        stage('manifest') {
            steps {
                sh 'make -j4 manifest GLUON_BRANCH=stable'
            }
        }
        stage('archive') {
            steps {
                archiveArtifacts artifacts: 'output/images/*/*, output/modules/*/*/*/*', fingerprint: true
            }
        }
    }
}
