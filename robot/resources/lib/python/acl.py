#!/usr/bin/python3.8

from enum import Enum, auto
import json
import os
import re
import uuid

import base64
import base58
from cli_helpers import _cmd_run
from common import ASSETS_DIR, NEOFS_ENDPOINT
from robot.api.deco import keyword
from robot.api import logger


"""
Robot Keywords and helper functions for work with NeoFS ACL.
"""


ROBOT_AUTO_KEYWORDS = False

# path to neofs-cli executable
NEOFS_CLI_EXEC = os.getenv('NEOFS_CLI_EXEC', 'neofs-cli')
EACL_LIFETIME = 100500

class AutoName(Enum):
    def _generate_next_value_(name, start, count, last_values):
        return name

class Role(AutoName):
    USER = auto()
    SYSTEM = auto()
    OTHERS = auto()


@keyword('Get eACL')
def get_eacl(wif: str, cid: str):
    cmd = (
        f'{NEOFS_CLI_EXEC} --rpc-endpoint {NEOFS_ENDPOINT} --wallet {wif} '
        f'container get-eacl --cid {cid}'
    )
    logger.info(f"cmd: {cmd}")
    try:
        output = _cmd_run(cmd)
        if re.search(r'extended ACL table is not set for this container', output):
            return None
        return output
    except RuntimeError as exc:
        logger.info("Extended ACL table is not set for this container")
        logger.info(f"Got exception while getting eacl: {exc}")
        return None


@keyword('Set eACL')
def set_eacl(wif: str, cid: str, eacl_table_path: str):
    cmd = (
        f'{NEOFS_CLI_EXEC} --rpc-endpoint {NEOFS_ENDPOINT} --wallet {wif} '
        f'container set-eacl --cid {cid} --table {eacl_table_path} --await'
    )
    logger.info(f"cmd: {cmd}")
    _cmd_run(cmd)


def _encode_cid_for_eacl(cid: str) -> str:
    cid_base58 = base58.b58decode(cid)
    return base64.b64encode(cid_base58).decode("utf-8")


@keyword('Form BearerToken File')
def form_bearertoken_file(wif: str, cid: str, eacl_records: list) -> str:
    """
    This function fetches eACL for given <cid> on behalf of <wif>,
    then extends it with filters taken from <eacl_records>, signs
    with bearer token and writes to file
    """
    enc_cid = _encode_cid_for_eacl(cid)
    file_path = f"{os.getcwd()}/{ASSETS_DIR}/{str(uuid.uuid4())}"

    eacl = get_eacl(wif, cid)
    json_eacl = dict()
    if eacl:
        eacl = eacl.replace('eACL: ', '')
        eacl = eacl.split('Signature')[0]
        json_eacl = json.loads(eacl)
    logger.info(json_eacl)
    eacl_result = {
                    "body":
                    {
                        "eaclTable":
                        {
                            "containerID":
                            {
                                "value": enc_cid
                            },
                            "records": []
                        },
                        "lifetime":
                        {
                            "exp": EACL_LIFETIME,
                            "nbf": "1",
                            "iat": "0"
                        }
                    }
                }

    if not eacl_records:
        raise(f"Got empty eacl_records list: {eacl_records}")
    for record in eacl_records:
        op_data = {
                "operation": record['Operation'],
                "action":   record['Access'],
                "filters":  [],
                "targets":  []
            }

        if Role(record['Role']):
            op_data['targets'] = [
                                    {
                                        "role": record['Role']
                                    }
                                ]
        else:
            op_data['targets'] = [
                                    {
                                        "keys": [ record['Role'] ]
                                    }
                                ]

        if 'Filters' in record.keys():
            op_data["filters"].append(record['Filters'])

        eacl_result["body"]["eaclTable"]["records"].append(op_data)

    # Add records from current eACL
    if "records" in json_eacl.keys():
        for record in json_eacl["records"]:
            eacl_result["body"]["eaclTable"]["records"].append(record)

    with open(file_path, 'w', encoding='utf-8') as eacl_file:
        json.dump(eacl_result, eacl_file, ensure_ascii=False, indent=4)

    logger.info(f"Got these extended ACL records: {eacl_result}")
    sign_bearer_token(wif, file_path)
    return file_path


def sign_bearer_token(wif: str, eacl_rules_file: str):
    cmd = (
        f'{NEOFS_CLI_EXEC} util sign bearer-token --from {eacl_rules_file} '
        f'--to {eacl_rules_file} --wallet {wif} --json'
    )
    logger.info(f"cmd: {cmd}")
    _cmd_run(cmd)


@keyword('Form eACL JSON Common File')
def form_eacl_json_common_file(eacl_records: list) -> str:
    # Input role can be Role (USER, SYSTEM, OTHERS) or public key.
    eacl = {"records":[]}
    file_path = f"{os.getcwd()}/{ASSETS_DIR}/{str(uuid.uuid4())}"

    for record in eacl_records:
        op_data = dict()

        if Role(record['Role']):
            op_data = {
                        "operation": record['Operation'],
                        "action":    record['Access'],
                        "filters":   [],
                        "targets": [
                            {
                                "role": record['Role']
                            }
                        ]
                    }
        else:
            op_data = {
                        "operation": record['Operation'],
                        "action":    record['Access'],
                        "filters":   [],
                        "targets": [
                            {
                                "keys": [ record['Role'] ]
                            }
                        ]
                    }

        if 'Filters' in record.keys():
            op_data["filters"].append(record['Filters'])

        eacl["records"].append(op_data)

    logger.info(f"Got these extended ACL records: {eacl}")

    with open(file_path, 'w', encoding='utf-8') as eacl_file:
        json.dump(eacl, eacl_file, ensure_ascii=False, indent=4)

    return file_path
