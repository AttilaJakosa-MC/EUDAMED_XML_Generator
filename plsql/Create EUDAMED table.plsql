SET DEFINE OFF;

WITH
    model_list AS (
        -- SELECT column_value AS model FROM TABLE(SYS.ODCIVARCHAR2LIST('860FAB','PFIM4'))
        -- FROM TABLE(SYS.ODCIVARCHAR2LIST('877FAB'))
        -- To run for all models, comment out the list above and uncomment the line below,
        -- which creates an empty list.
        SELECT NULL AS model FROM DUAL WHERE 1 = 0
    ),

    transferable_parts AS (
        SELECT /*+ MATERIALIZE */ * FROM TABLE(get_transferable_parts_lens_table('ALL'))
    ),

    transferable_parts_std AS (
        SELECT /*+ MATERIALIZE */ part_no, model, ver FROM TABLE(get_transferable_parts_lens_table('STD'))
    ),

    portfolio_data AS (
        SELECT /*+ MATERIALIZE */ * FROM TABLE(mc_get_portfolio_data())
    ),

    filtered_models AS (
        SELECT /*+ MATERIALIZE */ DISTINCT model
        FROM transferable_parts tp
        WHERE
            (SELECT COUNT(*) FROM model_list) = 0
            OR tp.model IN (SELECT model FROM model_list)
    ),

    filtered_models_ver AS (
        SELECT /*+ MATERIALIZE */
            model,
            MIN(ver) AS ver
        FROM transferable_parts tp
        WHERE
            (SELECT COUNT(*) FROM model_list) = 0
            OR tp.model IN (SELECT model FROM model_list)
        GROUP BY model
    )

    -- UDI-DI limit for one xml file, Eudamed
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '01'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'UDI_DI_LIMIT'                  AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        NULL                            AS valtext,
        300                             AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Eudamed XSD schema version. Mandatory for upload
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '01'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'XSD_VERSION'                   AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('3.0.28')               AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL




    -- Device create envelope for Medicontur HQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '01'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'DEVICE_CREATE_ENV'             AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
<m:Push
  xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
  xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
  xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
  xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
  xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
  xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
  xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="{VERSION}">

  <m:conversationID>{CONVERSATION_ID}</m:conversationID>
  <m:correlationID>{CORRELATION_ID}</m:correlationID>
  <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
  <m:messageID>{MESSAGE_ID}</m:messageID>

  <m:recipient>
    <m:node>
      <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
      <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
      <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:recipient>

  <m:payload>
  <device:Device xsi:type="device:MDRDeviceType">
      <device:MDRBasicUDI xsi:type="device:MDRBasicUDIType"></device:MDRBasicUDI>
      <device:MDRUDIDIData></device:MDRUDIDIData>
    </device:Device>
  </m:payload>

  <m:sender>
    <m:node>
      <s:nodeActorCode>HU-MF-000026801</s:nodeActorCode>
      <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:sender>
</m:Push>
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

-- Device create envelope for 1STQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '40'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'DEVICE_CREATE_ENV'             AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
    TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
    <m:Push
    xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
    xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
    xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
    xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
    xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
    xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
    xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="{VERSION}">

    <m:conversationID>{CONVERSATION_ID}</m:conversationID>
    <m:correlationID>{CORRELATION_ID}</m:correlationID>
    <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
    <m:messageID>{MESSAGE_ID}</m:messageID>

    <m:recipient>
        <m:node>
        <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
        <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
        </m:node>
        <m:service>
        <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
        <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
        <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
        </m:service>
    </m:recipient>

    <m:payload>
    <device:Device xsi:type="device:MDRDeviceType">
        <device:MDRBasicUDI xsi:type="device:MDRBasicUDIType"></device:MDRBasicUDI>
        <device:MDRUDIDIData></device:MDRUDIDIData>
        </device:Device>
    </m:payload>

    <m:sender>
        <m:node>
        <s:nodeActorCode>DE-MF-0000?????</s:nodeActorCode>
        <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
        </m:node>
        <m:service>
        <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
        <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
        </m:service>
    </m:sender>
    </m:Push>
    ~')                                 AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Basic UDI Update envelope for Medicontur HQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '01'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'BASIC_UDI_UPDATE_ENV'          AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
<m:Push
  xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
  xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
  xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
  xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
  xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
  xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
  xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="{VERSION}">

  <m:conversationID>{CONVERSATION_ID}</m:conversationID>
  <m:correlationID>{CORRELATION_ID}</m:correlationID>
  <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
  <m:messageID>{MESSAGE_ID}</m:messageID>

  <m:recipient>
    <m:node>
      <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
      <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
      <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:recipient>

  <m:payload>
      <device:BasicUDI xsi:type="device:MDRBasicUDIType"></device:BasicUDI>
  </m:payload>

  <m:sender>
    <m:node>
      <s:nodeActorCode>HU-MF-000026801</s:nodeActorCode>
      <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:sender>
</m:Push>
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

-- Basic UDI Update envelope for 1STQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '40'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'BASIC_UDI_UPDATE_ENV'          AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
<m:Push
  xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
  xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
  xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
  xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
  xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
  xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
  xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="{VERSION}">

  <m:conversationID>{CONVERSATION_ID}</m:conversationID>
  <m:correlationID>{CORRELATION_ID}</m:correlationID>
  <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
  <m:messageID>{MESSAGE_ID}</m:messageID>

  <m:recipient>
    <m:node>
      <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
      <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
      <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:recipient>

  <m:payload>
      <device:BasicUDI xsi:type="device:MDRBasicUDIType"></device:BasicUDI>
  </m:payload>

  <m:sender>
    <m:node>
      <s:nodeActorCode>DE-MF-0000?????</s:nodeActorCode>
      <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:sender>
</m:Push>
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL




UNION ALL

    -- UDI-DI envelope for Medicontur HQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '01'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'UDI_DI_ENV'                    AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
<m:Push
  xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
  xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
  xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
  xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
  xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
  xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
  xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="{VERSION}">

  <m:conversationID>{CONVERSATION_ID}</m:conversationID>
  <m:correlationID>{CORRELATION_ID}</m:correlationID>
  <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
  <m:messageID>{MESSAGE_ID}</m:messageID>

  <m:recipient>
    <m:node>
      <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
      <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
      <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:recipient>

  <m:payload>
      <device:BasicUDI xsi:type="device:MDRBasicUDIType"></device:BasicUDI>
  </m:payload>

  <m:sender>
    <m:node>
      <s:nodeActorCode>HU-MF-000026801</s:nodeActorCode>
      <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:sender>
</m:Push>
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

-- UDI-DI envelope for 1STQ International Distribution Channel
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '40'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'UDI_DI_ENV'                    AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
TO_CLOB(q'~<?xml version="1.0" encoding="UTF-8"?>
<m:Push
  xmlns:basicudi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/BasicUDI/v1"
  xmlns:commondi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/CommonDevice/v1"
  xmlns:device="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Device/v1"
  xmlns:lsn="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/Common/LanguageSpecific/v1"
  xmlns:m="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Message/v1"
  xmlns:s="https://ec.europa.eu/tools/eudamed/dtx/servicemodel/Service/v1"
  xmlns:udidi="https://ec.europa.eu/tools/eudamed/dtx/datamodel/Entity/UDIDI/v1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="{VERSION}">

  <m:conversationID>{CONVERSATION_ID}</m:conversationID>
  <m:correlationID>{CORRELATION_ID}</m:correlationID>
  <m:creationDateTime>{CREATION_DATE_TIME}</m:creationDateTime>
  <m:messageID>{MESSAGE_ID}</m:messageID>

  <m:recipient>
    <m:node>
      <s:nodeActorCode>{RECIPIENT_NODE_ACTOR_CODE}</s:nodeActorCode>
      <s:nodeID>{RECIPIENT_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceAccessToken>{RECIPIENT_SERVICE_ACCESS_TOKEN}</s:serviceAccessToken>
      <s:serviceID>{RECIPIENT_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{RECIPIENT_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:recipient>

  <m:payload>
      <device:BasicUDI xsi:type="device:MDRBasicUDIType"></device:BasicUDI>
  </m:payload>

  <m:sender>
    <m:node>
      <s:nodeActorCode>DE-MF-0000?????</s:nodeActorCode>
      <s:nodeID>{SENDER_NODE_ID}</s:nodeID>
    </m:node>
    <m:service>
      <s:serviceID>{SENDER_SERVICE_ID}</s:serviceID>
      <s:serviceOperation>{SENDER_SERVICE_OPERATION}</s:serviceOperation>
    </m:service>
  </m:sender>
</m:Push>
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

-- XML Object order
    SELECT
        'EUDAMED'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'XML_OBJECT_ORDER'              AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB(q'~XML_OBJECT_ORDER	[
  { elementLocalName: 'Device', namespacePrefix: 'device', correctOrder: ['MDRBasicUDI', 'MDRUDIDIData'], },
  { elementLocalName: 'MDRBasicUDI', parentLocalName: 'Device', namespacePrefix: 'device', correctOrder: ['state', 'version', 'versionDate', 'riskClass', 'model', 'modelName', 'identifier', 'certificateLinks', 'lastUpdated', 'animalTissuesCells', 'ARActorCode', 'humanTissuesCells', 'MFActorCode', 'ARComments', 'clinicalInvestigationLinks', 'deviceCertificateLinks', 'humanProductCheck', 'IIb_implantable_exceptions', 'medicinalProductCheck', 'specialDevice', 'type', 'active', 'administeringMedicine', 'implantable', 'measuringFunction', 'reusable',], },
  { elementLocalName: 'BasicUDI', parentLocalName: 'payload', namespacePrefix: 'device', correctOrder: ['riskClass', 'modelName', 'identifier', 'animalTissuesCells', 'humanTissuesCells', 'MFActorCode', 'humanProductCheck', 'medicinalProductCheck', 'type', 'active', 'administeringMedicine', 'implantable', 'measuringFunction', 'reusable',], },
  { elementLocalName: 'MDRUDIDIData', parentLocalName: 'Device', namespacePrefix: 'device', correctOrder: ['state', 'version', 'versionDate', 'identifier', 'status', 'lastUpdated', 'additionalDescription', 'basicUDIIdentifier', 'MDNCodes', 'productionIdentifier', 'referenceNumber', 'secondaryIdentifier', 'sterile', 'sterilization', 'tradeNames', 'website', 'storageHandlingConditions', 'packages', 'criticalWarnings', 'substatuses', 'numberOfReuses', 'relatedUDILink', 'marketInfos', 'deviceMarking', 'baseQuantity', 'productDesignerActor', 'annexXVINonMedicalDeviceTypes', 'annexXVIApplicable', 'latex', 'reprocessed', 'substances', 'clinicalSizes',], },
  { elementLocalName: 'UDIDIData', parentLocalName: 'payload', namespacePrefix: 'device', correctOrder: ['state', 'version', 'versionDate', 'identifier', 'status', 'lastUpdated', 'additionalDescription', 'basicUDIIdentifier', 'MDNCodes', 'productionIdentifier', 'referenceNumber', 'secondaryIdentifier', 'sterile', 'sterilization', 'tradeNames', 'website', 'storageHandlingConditions', 'packages', 'criticalWarnings', 'substatuses', 'numberOfReuses', 'relatedUDILink', 'marketInfos', 'deviceMarking', 'baseQuantity', 'productDesignerActor', 'annexXVINonMedicalDeviceTypes', 'annexXVIApplicable', 'latex', 'reprocessed', 'substances', 'clinicalSizes',], },
  { elementLocalName: 'modelName', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', correctOrder: ['model', 'name'], },
  { elementLocalName: 'modelName', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', correctOrder: ['model', 'name'], },
  { elementLocalName: 'identifier', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'identifier', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'identifier', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
]~')
      || TO_CLOB(q'~[
  { elementLocalName: 'identifier', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'basicUDIIdentifier', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'basicUDIIdentifier', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'secondaryIdentifier', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'secondaryIdentifier', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'directMarkingDI', parentLocalName: 'deviceMarking', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'unitOfUseIdentifier', parentLocalName: 'deviceMarking', namespacePrefix: 'udidi', correctOrder: ['DICode', 'issuingEntityCode'], },
  { elementLocalName: 'status', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['code'], },
  { elementLocalName: 'status', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['code'], },
  { elementLocalName: 'storageHandlingConditions', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['condition'], },
]~')
      || TO_CLOB(q'~[
  { elementLocalName: 'storageHandlingConditions', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['condition'], },
  { elementLocalName: 'criticalWarnings', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['warning'], },
  { elementLocalName: 'criticalWarnings', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['warning'], },
  { elementLocalName: 'substatuses', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['substatus'], },
  { elementLocalName: 'substatuses', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['substatus'], },
  { elementLocalName: 'deviceMarking', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['directMarkingDI', 'unitOfUseIdentifier'], },
  { elementLocalName: 'deviceMarking', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['directMarkingDI', 'unitOfUseIdentifier'], },
  { elementLocalName: 'condition', parentLocalName: 'storageHandlingConditions', namespacePrefix: 'udidi', correctOrder: ['comments', 'storageHandlingConditionValue'], },
  { elementLocalName: 'warning', parentLocalName: 'criticalWarnings', namespacePrefix: 'udidi', correctOrder: ['comments', 'warningValue'], },
  { elementLocalName: 'tradeNames', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', correctOrder: ['name'], },
  { elementLocalName: 'tradeNames', parentLocalName: 'UDIDIData', namespacePrefix: 'udidi', correctOrder: ['name'], },
  { elementLocalName: 'comments', parentLocalName: 'condition', namespacePrefix: 'commondi', correctOrder: ['name'], },
  { elementLocalName: 'comments', parentLocalName: 'warning', namespacePrefix: 'commondi', correctOrder: ['name'], },
  { elementLocalName: 'name', parentLocalName: 'tradeNames', namespacePrefix: 'lsn', correctOrder: ['language', 'textValue'], },
  { elementLocalName: 'name', parentLocalName: 'comments', namespacePrefix: 'lsn', correctOrder: ['language', 'textValue'], },
  { elementLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'conversationID', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'correlationID', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'creationDateTime', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'messageID', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'recipient', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'payload', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'sender', parentLocalName: 'Push', namespacePrefix: 'm', },
  { elementLocalName: 'node', parentLocalName: 'recipient', namespacePrefix: 'm', },
  { elementLocalName: 'service', parentLocalName: 'recipient', namespacePrefix: 'm', },
  { elementLocalName: 'node', parentLocalName: 'sender', namespacePrefix: 'm', },
  { elementLocalName: 'service', parentLocalName: 'sender', namespacePrefix: 'm', },
  { elementLocalName: 'nodeActorCode', parentLocalName: 'node', namespacePrefix: 's', },
  { elementLocalName: 'nodeID', parentLocalName: 'node', namespacePrefix: 's', },
  { elementLocalName: 'serviceAccessToken', parentLocalName: 'service', namespacePrefix: 's', },
  { elementLocalName: 'serviceID', parentLocalName: 'service', namespacePrefix: 's', },
  { elementLocalName: 'serviceOperation', parentLocalName: 'service', namespacePrefix: 's', },
  { elementLocalName: 'riskClass', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'animalTissuesCells', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'humanTissuesCells', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'MFActorCode', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'humanProductCheck', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
]~')
      || TO_CLOB(q'~[
  { elementLocalName: 'medicinalProductCheck', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'type', parentLocalName: 'BasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'riskClass', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'animalTissuesCells', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'humanTissuesCells', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'MFActorCode', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'humanProductCheck', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'medicinalProductCheck', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'type', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'basicudi', },
  { elementLocalName: 'model', parentLocalName: 'modelName', namespacePrefix: 'commondi', },
  { elementLocalName: 'name', parentLocalName: 'modelName', namespacePrefix: 'commondi', },
  { elementLocalName: 'DICode', parentLocalName: 'identifier', namespacePrefix: 'commondi', },
  { elementLocalName: 'issuingEntityCode', parentLocalName: 'identifier', namespacePrefix: 'commondi', },
  { elementLocalName: 'active', parentLocalName: 'BasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'administeringMedicine', parentLocalName: 'BasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'implantable', parentLocalName: 'BasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'measuringFunction', parentLocalName: 'BasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'reusable', parentLocalName: 'BasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'active', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'administeringMedicine', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'implantable', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'measuringFunction', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'reusable', parentLocalName: 'MDRBasicUDI', namespacePrefix: 'commondi', },
  { elementLocalName: 'MDNCodes', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'productionIdentifier', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'referenceNumber', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'sterile', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'sterilization', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'website', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'numberOfReuses', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'baseQuantity', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'latex', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'reprocessed', parentLocalName: 'MDRUDIDIData', namespacePrefix: 'udidi', },
  { elementLocalName: 'code', parentLocalName: 'status', namespacePrefix: 'commondi', },
  { elementLocalName: 'comments', parentLocalName: 'condition', namespacePrefix: 'commondi', },
  { elementLocalName: 'storageHandlingConditionValue', parentLocalName: 'condition', namespacePrefix: 'commondi', },
  { elementLocalName: 'comments', parentLocalName: 'warning', namespacePrefix: 'commondi', },
  { elementLocalName: 'warningValue', parentLocalName: 'warning', namespacePrefix: 'commondi', },
  { elementLocalName: 'language', parentLocalName: 'name', namespacePrefix: 'lsn', },
  { elementLocalName: 'textValue', parentLocalName: 'name', namespacePrefix: 'lsn', },
]
~')                                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Actor code for 1stQ distribution channel
    SELECT
        'EUD_ENV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '40'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'sender/node/NodeActorCode'     AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('DE-MF-0000?????')               AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL






--FROM portfolio_data pd
--WHERE pd.model IN (SELECT model FROM filtered_models)
;
