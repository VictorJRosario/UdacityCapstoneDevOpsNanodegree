pipeline {
	agent any
	stages {

		stage('Creating Kubernetes Cluster...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						eksctl create cluster \
						--name UdacityCapstoneCluster \
						--version 1.14 \
						--nodegroup-name standard-workers \
						--node-type t2.small \
						--nodes 2 \
						--nodes-min 1 \
						--nodes-max 3 \
						--node-ami auto \
						--region us-east-1 \
						--zones us-east-1a \
						--zones us-east-1b \
						--zones us-east-1c \
					'''
				}
			}
		}

		stage('Creating Configuration File...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						aws eks --region us-east-1 update-kubeconfig --name UdacityCapstoneCluster
					'''
				}
			}
		}

        stage('Linting HTML File...') {
			steps {
				sh 'tidy -q -e *.html'
			}
		}
		
		stage('Building Docker Image...') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Docker-User', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker build -t victorrosario/UdacityCapstone .
					'''
				}
			}
		}

		stage('Pushing Image To Dockerhub...') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Docker-User', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push victorrosario/UdacityCapstone
					'''
				}
			}
		}

		stage('Setting Kubectl Context...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						kubectl config use-context arn:aws:eks:us-east-1:142977788479:cluster/UdacityCapstoneCluster
					'''
				}
			}
		}

		stage('Deploying Blue Controller...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						kubectl apply -f ./BlueController.json
					'''
				}
			}
		}

		stage('Deploying Green Controller...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						kubectl apply -f ./GreenController.json
					'''
				}
			}
		}

		stage('Creating Service & Redirecting Blue...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						kubectl apply -f ./BlueServ.json
					'''
				}
			}
		}

		stage('Waiting User Approval...') {
            steps {
                input "Confirm Redirection..."
            }
        }

		stage('Creating Service & Redirecting Green...') {
			steps {
				withAWS(region:'us-east-1', credentials:'AWS-Creds') {
					sh '''
						kubectl apply -f ./green-service.json
					'''
				}
			}
		}

	}
}
