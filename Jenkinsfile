pipeline {
  agent any
  options {
    buildDiscarder(logRotator(numToKeepStr:'10'))
  }
  stages {
    stage ('Init') {
      steps {
        checkout scm
        sshagent (credentials: ['jenkins-kisio-bot']) {
          sh '''
          git submodule update --init
          # Build test container
          if ! docker network ls | grep 'canaltp'
          then
            docker network create canaltp
          fi
          docker-compose -f docker-compose.test.yml build --pull
          docker-compose -f docker-compose.test.yml up -d
          '''
        }
      }
    }
    stage ('Run tests Python') {
      environment {
        NAVITIA_URL = "${params.NAVITIA_URL}"
        NAVITIA_AUTHORIZATION = "${params.NAVITIA_AUTHORIZATION}"
      }
      steps {
        sh '''
        # Launch tests
        docker-compose -f docker-compose.test.yml exec -e NAVITIA_URL=${NAVITIA_URL} -e NAVITIA_AUTHORIZATION=${NAVITIA_AUTHORIZATION} -T chaos /bin/sh ./docker/tests.sh
        '''
      }
      post {
        always {
          junit allowEmptyResults: false, testResults: 'nosetest_chaos.xml, lettucetests.xml'
          recordIssues(
            tool: pyLint(pattern: 'pylint.log'),
            unstableTotalAll: 999,
            failedTotalAll: 999,
            enabledForFailure: true
          )
          step([$class: 'CoberturaPublisher', autoUpdateHealth: false, autoUpdateStability: false, coberturaReportFile: 'coverage.xml', failUnhealthy: false, failUnstable: false, maxNumberOfBuilds: 0, onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false])
        }
      }
    }
  }
  post {
    always {
      echo 'Clean environment'
      sh '''
        docker-compose -f docker-compose.test.yml exec -T chaos /bin/sh -c "rm -f .coverage && rm -f *.xml && rm -f pylint.log && rm -rf venv"
        docker-compose -f docker-compose.test.yml down --remove-orphans
      '''
    }
  }
}
