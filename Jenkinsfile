environment {
        APP_BUILD_ID = 0.1
        FULL_PATH_BRANCH = "${sh(script:'git name-rev --name-only HEAD', returnStdout: true)}"
        GIT_BRANCH = FULL_PATH_BRANCH.substring(FULL_PATH_BRANCH.lastIndexOf('/') + 1, FULL_PATH_BRANCH.length())        
    }
    stages {
        stage ('Checkout SCM & Merge master to feature branch') {
            steps{
                # you might need to set up global git config, for example
                # sh 'git config --global user.email "XXX"'
                # sh 'git config --global user.name "XXX"'           
                checkout([$class: 'GitSCM', branches: [[name: 'refs/remotes/origin/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'LocalBranch', localBranch:'**']], submoduleCfg: [], userRemoteConfigs: [[refspec:"+refs/pull/*:refs/remotes/origin/pr/*", refspec:"+refs/heads/*:refs/remotes/origin/*",credentialsId: '123456789', url: 'XXX']]])
            }
        }
        stage('Build') {
            steps{
                echo "Build..."
                script {
                    sh "git branch"
                    app = docker.build("test-app-image:${env.APP_BUILD_ID}", "--network=host -f Dockerfile .")
                }
            }
        }
        stage('Test') {
            steps{
                script {
                    try {
                        sh "docker run --network=host -v ~/Development:/output test-app-image:0.1 /bin/sh entrypoints/pytest_entrypoint.sh"
                    } catch(err) {
                        throw err
                    } finally {
                    }
                }
            }
        }
        stage('RUN') {
            steps{
                echo "RUN..."
                script {
                    try {
                        sh "docker run --network=host -v ~/Development:/output test-app-image:0.1 python3 test123.py"
                    } catch(err) {
                        throw err
                    } finally {
                    }
                }
            }
        }
        stage('CLEAN UP') {
            steps{
                echo "CLEAN UP..."
                script {
                    try {
                        sh "docker rm \$(docker stop \$(docker ps -a -q --filter ancestor=test-app-image:${APP_BUILD_ID} --format='{{.ID}}'))"
                    } catch(err) {
                        throw err
                    } finally {
                    }
                }
            }
        }
        stage('PUSHING_TO_GIT') {
            steps{
                echo "PUSHING_TO_GIT..."
                script {
                    try {
                        sh "export GIT_SSL_NO_VERIFY=1"
                        sh "git branch"
                        sh('chmod +x scripts/release.sh && scripts/release.sh')
                    } catch(err) {
                        throw err
                    } finally {

                    }
                    NEW_RELEASE_BRANCH = "${sh(script:'git rev-parse --abbrev-ref HEAD', returnStdout: true)}"
                }
                withCredentials([
                    gitUsernamePassword(credentialsId: 'gitea_auth', gitToolName: 'Default')
                ]) {

                    sh "git push --set-upstream origin ${NEW_RELEASE_BRANCH}"

                }
            }
        }
    }
}