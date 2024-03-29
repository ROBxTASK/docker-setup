from fabric import task
from patchwork.transfers import rsync
import os

WORKING_DIR = '/srv/docker-setup_fab/'

@task
def update_files(c):
    print(c)
    c.run('mkdir -p ' + WORKING_DIR)
    real_path = os.path.realpath(__file__)
    dir_path = os.path.dirname(real_path)
    rsync(c, source=dir_path + "/.", target=WORKING_DIR, rsync_opts='--progress', exclude=[
                                                    #'services/env_vars-staging', 
                                                    '.vscode',
                                                    'jenkins_ci/jenkins_home/*',
                                                    'jenkins_ci/ssh_config'
                                                    'jenkins_ci/jenkins.war'
                                                    '.vscode/*',
                                                    'fab*',
                                                    '.git',
                                                    '.gitignore',
                                                    '*.pyc',
                                                    '.idea',
                                                    #'infra/keycloak/keycloak_secrets',
                                                    #'services/platform-config'
                                                    '__pycache__',
                                                    ])


@task
def run_jenkins(c):
    update_files(c)
    with c.cd(WORKING_DIR + 'jenkins_ci/'):
        c.run('docker network create jenkins_default || true')
        c.run('docker-compose --project-name jenkins_ci up --build -d --force-recreate')

@task
def run_staging_infra(c):
    update_files(c)

    with c.cd(WORKING_DIR + "staging/"):
        c.run('./run-staging.sh database')
        c.run('./run-staging.sh infra')
        c.run('./run-staging.sh keycloak')
        c.run('./run-staging.sh solr')
        c.run('./run-staging.sh mongo')

@task
def run_staging_services(c):
    update_files(c)
    with c.cd(WORKING_DIR + "staging/"):
        c.run('./run-staging.sh services')


@task
def run_nginx(c):
    update_files(c)
    with c.cd(WORKING_DIR + 'nginx'):
        c.run('docker-compose --project-name nginx up --build -d --force-recreate')


@task
def log_nginx(c):
    with c.cd(WORKING_DIR + 'nginx'):
        c.run('docker-compose logs -f --tail 100')


@task
def log_jenkins(c):
    with c.cd(WORKING_DIR + 'jenkins_ci/'):
        c.run('docker-compose logs -f --tail 100')
