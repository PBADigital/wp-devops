#!/usr/bin/env bash
#
#    Copyright 2018 NewClarity Consulting, LLC
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

declare="${CI_DEPLOY_LOCKED:=}"
declare="${CI_LOG:=}"
declare="${CI_LOGS_DIR:=}"
declare="${CI_CIRCLECI_DIR:=}"
declare="${CI_SOURCED_FILE:=}"

source "sourced.sh"

export CI_LOGS_DIR="${CI_CIRCLECI_DIR}/logs"
mkdir -p "${CI_LOGS_DIR}"

function deploy_onexit() {
    if [ "yes" == "$(deploy_is_locally_locked)" ] ; then
        exit 0
    fi
    bash "$(pwd)/unlock-deploy.sh"
    local _=$(mv "${CI_LOG}" "${CI_LOGS_DIR}/unlock-deploy.log")
}
trap deploy_onexit INT TERM EXIT

announce "Deploying"
bash "$(pwd)/deploy.sh"
if ! [ -f "${CI_LOG}" ] ; then
    touch "${CI_LOGS_DIR}/deploy.log"
else
    mv "${CI_LOG}" "${CI_LOGS_DIR}/deploy.log"
fi
