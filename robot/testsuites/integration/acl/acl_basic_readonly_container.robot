*** Settings ***
Variables    common.py

Library      neofs.py
Library      payment_neogo.py

Resource     common_steps_acl_basic.robot
Resource     payment_operations.robot
Resource     setup_teardown.robot


*** Test cases ***
Basic ACL Operations for Read-Only Container
    [Documentation]         Testcase to validate NeoFS operations with ACL for Read-Only Container.
    [Tags]                  ACL  NeoFS  NeoCLI
    [Timeout]               20 min

    [Setup]                 Setup

    ${WALLET}   ${ADDR}     ${USER_KEY} =   Prepare Wallet And Deposit
    ${WALLET_OTH}   ${ADDR_OTH}     ${OTHER_KEY} =   Prepare Wallet And Deposit

    ${READONLY_CID} =       Create Read-Only Container    ${USER_KEY}
    ${FILE_S}    ${FILE_S_HASH} =                        Generate file    ${SIMPLE_OBJ_SIZE}
                            Check Read-Only Container    Simple    ${USER_KEY}    ${FILE_S}    ${READONLY_CID}    ${OTHER_KEY}

    ${READONLY_CID} =       Create Read-Only Container    ${USER_KEY}
    ${FILE_S}    ${FILE_S_HASH} =             Generate file    ${COMPLEX_OBJ_SIZE}
                            Check Read-Only Container    Complex    ${USER_KEY}    ${FILE_S}    ${READONLY_CID}    ${OTHER_KEY}

    [Teardown]              Teardown    acl_basic_readonly_container


*** Keywords ***


Check Read-Only Container
    [Arguments]     ${RUN_TYPE}    ${USER_KEY}    ${FILE_S}    ${READONLY_CID}    ${OTHER_KEY}

    # Put
    ${S_OID_USER} =         Put object                 ${USER_KEY}         ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Put object            ${OTHER_KEY}        ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Put object            ${NEOFS_IR_WIF}    ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
    ${S_OID_SYS_SN} =       Put object                 ${NEOFS_SN_WIF}    ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}


    # Storage group Operations (Put, List, Get, Delete)
    ${SG_OID_INV} =     Put Storagegroup    ${USER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
    ${SG_OID_1} =       Put Storagegroup    ${USER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${USER_KEY}    ${READONLY_CID}   ${EMPTY}    ${SG_OID_1}  ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER}
                        Get Storagegroup    ${USER_KEY}    ${READONLY_CID}    ${SG_OID_1}   ${EMPTY}    ${EMPTY}    @{EXPECTED_OIDS}
                        Delete Storagegroup    ${USER_KEY}    ${READONLY_CID}    ${SG_OID_1}    ${EMPTY}

                        Run Keyword And Expect Error        *
                        ...  Put Storagegroup    ${OTHER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${OTHER_KEY}    ${READONLY_CID}   ${EMPTY}    ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER}
                        Get Storagegroup    ${OTHER_KEY}    ${READONLY_CID}    ${SG_OID_INV}   ${EMPTY}    ${EMPTY}    @{EXPECTED_OIDS}
                        Run Keyword And Expect Error        *
                        ...  Delete Storagegroup    ${OTHER_KEY}    ${READONLY_CID}    ${SG_OID_INV}    ${EMPTY}

                        Run Keyword And Expect Error        *
                        ...  Put Storagegroup    ${NEOFS_IR_WIF}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${NEOFS_IR_WIF}    ${READONLY_CID}   ${EMPTY}    ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER}
                        Get Storagegroup    ${NEOFS_IR_WIF}    ${READONLY_CID}    ${SG_OID_INV}   ${EMPTY}    ${EMPTY}    @{EXPECTED_OIDS}
                        Run Keyword And Expect Error        *
                        ...  Delete Storagegroup    ${NEOFS_IR_WIF}    ${READONLY_CID}    ${SG_OID_INV}    ${EMPTY}

    # Get
                            Get object               ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read
                            Get object               ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read
                            Get object               ${NEOFS_IR_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read
                            Get object               ${NEOFS_SN_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read

    # Get Range
                            Get Range                           ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${NEOFS_IR_WIF}    ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${NEOFS_SN_WIF}    ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256


    # Get Range Hash
                            Get Range Hash                      ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${NEOFS_IR_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${NEOFS_SN_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256

    # Search
    @{S_OBJ_RO} =	        Create List	                        ${S_OID_USER}       ${S_OID_SYS_SN}
                            Search object                       ${USER_KEY}         ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${OTHER_KEY}        ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${NEOFS_IR_WIF}    ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${NEOFS_SN_WIF}    ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}


    # Head
                            Head object                         ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${NEOFS_IR_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${NEOFS_SN_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}

    # Delete
                            Run Keyword And Expect Error        *
                            ...  Delete object                  ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Delete object                  ${NEOFS_IR_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Delete object                  ${NEOFS_SN_WIF}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Delete object                       ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
