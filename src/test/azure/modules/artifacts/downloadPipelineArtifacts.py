import os
import logging
import shutil
import requests
import configparser
import zipfile
import argparse
from requests.auth import HTTPBasicAuth


# Author: Gabriel Starczewsk
# This script has been tested fine against python 3.5 and 3.7

def create_tmp_dirs_in_current_path(folders):
    """
        Create a temp directory for storing downloaded fies. Remove entire tree if already exists.
    :return:
    """
    for folder in folders:
        try:
            path = os.getcwd()
            try:
                shutil.rmtree("%s/%s" % (path, folder))
            except:
                logging.debug("Temp directory %s not deleted" % folder)

            os.mkdir("%s/%s" % (path, folder))
            logging.info("Temp directory %s recreated" % folder)
        except IOError as e:
            logging.exception("Cannot create tmp directory % sdue to %s" % (folder, e))


def fetch_last_build_ids_for_pipeline(base_url, pipeline_id, builds_number, auth_obj, include_failed):
    """
    returns ids of up to builds_number previous successful builds
    :param base_url: azure devops url
    :param pipeline_id: definition_id of pipeline
    :param builds_number: how manu previous builds are looked for artifacts (jmeter reports)
    :param auth_obj: basic auth object
    :return: list of ids of the successful builds
    """
    url = r"%s?definitions=%s&top=%s" % (base_url, pipeline_id, builds_number)
    payload = {}
    if not include_failed:
        payload = {'api-version': '5.1', 'resultFilter': 'succeeded'}
    ids = []
    try:
        r = requests.get(url, payload, auth=auth_obj)
        if 'value' in r.json():
            values = r.json()['value']
            ids = list(map(lambda v: v['id'], values))[:builds_number]
    except Exception as e:
        logging.info("Request failed with %s" % e)

    logging.info("Successful last %s build IDs found %s" % (builds_number, ids))
    return ids


def download_artifacts_for_build_ids(base_url, ids, artifact, auth_obj):
    """
    Downloads jmeter reports from the given builds number if they exist
    :param base_url: azure devops url
    :param ids: ids of builds
    :param artifact: artifact name
    :param auth_obj: auth object
    :return: null
    """
    payload = {'api-version': '5.1', 'artifactName': artifact}
    logging.info("Attempting to fetch artifact %s from each build if exists" % artifact)
    for _id in ids:
        try:
            r = requests.get("%s/%s/artifacts" % (base_url, _id), payload, auth=auth_obj)
            msg = ""
            if r.status_code == 404:
                msg = " -> jmeter artifact %s does not exist in this build" % artifact
            elif r.status_code == 200:
                msg = " -> artifact downloaded"
            logging.info("HTTP CODE: %s for build ID: %s %s" % (r.status_code, _id, msg))
            try:
                if 'resource' in r.json():
                    download_url = r.json()['resource']['downloadUrl']
                    r = requests.get(download_url, auth=auth_obj)

                    with open("tmp/%s.zip" % (_id), "wb") as f:
                        f.write(r.content)
            except IOError as e:
                pass
            except Exception as e:
                logging.exception("Could not fetch the file for the build %s due to %s" % (_id, e))
        except Exception as e:
            logging.exception("Artifacts %s does not exist in build %s. Skipping" % (artifact, _id))

    logging.info("Downloaded the following artifacts from last %s successful builds: " % previous_builds_number)
    logging.info(os.listdir("%s/%s" % (os.getcwd(), 'tmp')))


def extract_zipped_artifacts(download_folder, csv_folder, artifact):
    """
        Unzips jmeter results to a flat folder
    :param download_folder:
    :param csv_folder:
    :param artifact:
    :return:
    """
    for entry in os.scandir(download_folder):
        if entry.name.endswith(".zip") and entry.is_file():
            logging.info("Attempting to unzip: %s/%s" % (download_folder, entry.name))
            with zipfile.ZipFile("%s/%s" % (download_folder, entry.name), "r") as zip_ref:
                extract_folder = "%s/%s" % (download_folder, str.replace(entry.name, '.zip', ''))
                zip_ref.extractall(extract_folder)
                for entry2 in os.scandir("%s/%s" % (extract_folder, artifact)):
                    logging.info("%s/%s/%s" % (extract_folder, artifact, entry2.name))
                    if entry2.name.endswith(".csv") and entry2.is_file():
                        shutil.copy("%s/%s/%s" % (extract_folder, artifact, entry2.name),
                                    "%s/%s" % (csv_folder, str.replace(entry.name, '.zip', '.csv')))


# if exeduted directly as script
if __name__ == '__main__':
    # argparse

    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='''
        Azure Artifacts Downloader
            Downloads a number of artifacts to a given folder.
            Requires valid Azure credentials (PAT), artifact name and DevOps URL. 
    ''')

    # default values are taken from azure.properties file

    config = configparser.ConfigParser()
    config.read('../../azure.properties')
    devops = config['devops']
    test = config['test']
    trends = config['trends']

    parser.add_argument('-d', '--definition_id', action="store", type=int, dest="definition_id",
                        help='Provide ID of your azure pipeline, so called definition_id', default=test['definition_id'])
    parser.add_argument('-p', '--previous_builds_number', action="store", type=int,
                        default=trends['previous_builds_number'], dest="previous_builds_number",
                        help='How many builds to include in the trend report')
    parser.add_argument('-a', '--artifact', action="store", dest="artifact",
                        help='Jmeter results CSV artifact name e.g. results.csv', default=trends['artifact'])
    parser.add_argument('-b', '--base_url', action="store", dest="api_base_url",
                        help='URL of your DevOps organization e.g. https://obss-internal.visualstudio.com/mcdum',
                        default=devops['devops_url'])
    parser.add_argument('-u', '--user', action="store", dest="user", help='user for basic authentication with PAT',
                        default=devops['user'])
    parser.add_argument('-s', '--pat', action="store", dest="pat", help='Azure PAT with appropriate access to artifacts'
                        )
    parser.add_argument('-t', '--tmp_folder', action="store", dest="tmp_folder",
                        help='name of a temp folder to download zipped artifacts', default=trends['tmp_folder'])
    parser.add_argument('-c', '--csv_folder', action="store", dest="csv_folder",
                        help='name of a csv folder to extract zipped artifacts', default=trends['csv_folder'])
    parser.add_argument('-i', '--include_failed', action="store", dest="include_failed",
                        help='Include failed jobs in trends?', type=bool, default=trends['includeFailedJobs'])

    args = parser.parse_args()

    definition_id = args.definition_id
    previous_builds_number = args.previous_builds_number
    artifact = args.artifact
    base_url = "%s/_apis/build/builds" % args.api_base_url
    user = args.user
    passwd = args.pat
    tmp_folder = args.tmp_folder
    csv_folder = args.csv_folder
    include_failed = args.include_failed
    auth_obj = HTTPBasicAuth(user, passwd)
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')


    # flow
    create_tmp_dirs_in_current_path([tmp_folder, csv_folder])
    ids = fetch_last_build_ids_for_pipeline(base_url, definition_id, previous_builds_number, auth_obj, include_failed)
    download_artifacts_for_build_ids(base_url, ids, artifact, auth_obj)
    extract_zipped_artifacts(tmp_folder, csv_folder, artifact)
