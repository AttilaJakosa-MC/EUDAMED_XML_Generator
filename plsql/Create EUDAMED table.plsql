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
            ((SELECT COUNT(*) FROM model_list) = 0
            OR tp.model IN (SELECT model FROM model_list)) AND tp.model not like 'PF%'
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
    ),

    divisions AS (
        SELECT '01' AS div FROM DUAL UNION ALL
        SELECT '10' AS div FROM DUAL UNION ALL
        SELECT '11' AS div FROM DUAL UNION ALL
        SELECT '12' AS div FROM DUAL
    ),

    distchannels AS (
        SELECT '01' AS distchain FROM DUAL UNION ALL
        SELECT '40' AS distchain FROM DUAL
    ),

    non_iol_parts AS (
        SELECT /*+ MATERIALIZE */ * FROM TABLE(Get_Transferable_Parts_NON_IOL_table()) WHERE eudamed = 'x'
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
        NULL                            AS distchain,
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
        NULL                            AS distchain,
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

    -- DEVICE_BASIC_UDI_CREATE_PAYLOAD_ROOT
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
        'DEVICE_BASIC_UDI_CREATE_PAYLOAD_ROOT'
                                        AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('/Push/payload/Device/MDRBasicUDI')
                                        AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- DEVICE_UDI_DI_CREATE_PAYLOAD_ROOT
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
        'DEVICE_UDI_DI_CREATE_PAYLOAD_ROOT'
                                        AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('/Push/payload/Device/MDRUDIDIData')
                                        AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL
    
UNION ALL

    -- BASIC_UDI_UPDATE_PAYLOAD_ROOT
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
        'BASIC_UDI_UPDATE_PAYLOAD_ROOT'
                                        AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('/Push/payload/BasicUDI')
                                        AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- UDI_DI_PAYLOAD_ROOT
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
        'UDI_DI_PAYLOAD_ROOT'
                                        AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        TO_CLOB('/Push/payload/UDIDIData')
                                        AS valtext,
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

    -- BasicUDI/Risk class by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/riskClass'                        AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE WHEN div IN ('01', '10', '11') THEN 'CLASS_IIB' 
                     ELSE 'CLASS_IIA' END)
                                                    AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/type by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/type'                             AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE WHEN div = '10' THEN 'SYSTEM' 
                     ELSE 'DEVICE' END)             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/Issuing entity by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/identifier/issuingEntityCode'     AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('GS1')                              AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/Animal Tissues Cells entity by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/animalTissuesCells'              AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/Human Tissues Cells entity by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/humanTissuesCells'                AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/implantable by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/implantable'                      AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE WHEN div IN ('01', '11') THEN 'true' 
                     ELSE 'false' END)              AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/humanProductCheck by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/humanProductCheck'                AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/IIb_implantable_exceptions by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/IIb_implantable_exceptions'       AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/medicinalProductCheck by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/medicinalProductCheck'            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/active by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/active'                           AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/administeringMedicine by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/administeringMedicine'            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/measuringFunction by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/measuringFunction'                AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/reusable by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/reusable'                         AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/deviceCertificateLinks/deviceCertificateLink[0]/NBActorCode by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/deviceCertificateLinks/deviceCertificateLink[0]/NBActorCode' AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE WHEN div = '01' THEN '2265' 
                     ELSE '1639' END)               AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/deviceCertificateLinks/deviceCertificateLink[0]/certificateType by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/deviceCertificateLinks/deviceCertificateLink[0]/certificateType' AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('MDR_TECHNICAL_DOCUMENTATION')      AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- BasicUDI/MF Actor Code entity by division and distchain
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        d.div                                       AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        dc.distchain                                AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/MFActorCode'                      AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE dc.distchain 
                     WHEN '01' THEN 'HU-MF-000026801'
                     WHEN '40' THEN 'DE-MF-0000?????' 
                END)                                AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions d
    CROSS JOIN distchannels dc

UNION ALL

    -- BasicUDI/Lens Medicontur model
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        '01'                                        AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/model'                            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('''=PRODGR')                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM dual

UNION ALL

    -- BasicUDI/identifier/UDICode by filtered_models
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        '01'                                        AS div,
        fm.model                                    AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/identifier/UDICode'               AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE fm.model
            WHEN '640PM' THEN '599302640PMYV'
            WHEN '677AD' THEN '599302677ADYN'
            WHEN '677ADY' THEN '599302677ADYRD'
            WHEN '677CMTY' THEN '599302677CMTYP3'
            WHEN '677CMY' THEN '599302677CMYSJ'
            WHEN '677CTAY' THEN '599302677CTAYND'
            WHEN '677MTY' THEN '599302677MTYUR'
            WHEN '677MY' THEN '599302677MY37'
            WHEN '677P' THEN '599302677PE9'
            WHEN '677PMY' THEN '599302677PMYUK'
            WHEN '677PY' THEN '599302677PY3G'
            WHEN '677TAY' THEN '599302677TAYU3'
            WHEN '690AD' THEN '599302690ADXZ'
            WHEN '690ADY' THEN '599302690ADYQJ'
            WHEN '690CMTY' THEN '599302690CMTYMG'
            WHEN '690CMY' THEN '599302690CMYRP'
            WHEN '690CTAY' THEN '599302690CTAYLS'
            WHEN '690MTY' THEN '599302690MTYTW'
            WHEN '690MY' THEN '599302690MY2J'
            WHEN '690TAY' THEN '599302690TAYT8'
            WHEN '640AD' THEN '599302640ADWW'
            WHEN '640ADY' THEN '599302640ADYNT'
            WHEN '640CMY' THEN '599302640CMYPY'
            WHEN '640MY' THEN '599302640MYZC'
            WHEN '640P' THEN '599302640PD5'
            WHEN '640PY' THEN '599302640PYZM'
            WHEN '677CTA' THEN '599302677CTARP'
            WHEN '677M' THEN '599302677ME3'
            WHEN '677MT' THEN '599302677MT2V'
            WHEN '677TA' THEN '599302677TA2C'
            WHEN '690CM' THEN '599302690CMYR'
            WHEN '690CTA' THEN '599302690CTAQU'
            WHEN '690TA' THEN '599302690TAZL'
            WHEN '860PT' THEN '599302860PT2J'
            WHEN '860PTY' THEN '599302860PTYU6'
            WHEN '860PETY' THEN '599302860PETYNW'
            WHEN '877PT' THEN '599302877PT3U'
            WHEN '877PTY' THEN '599302877PTYW2'
            WHEN '877PETY' THEN '599302877PETYRQ'
            WHEN 'A45DT' THEN '599302A45DT4H'
            WHEN 'A45RD2' THEN '599302A45RD2U9'
            WHEN 'A45RT' THEN '599302A45RT5T'
            WHEN 'A45SML' THEN '599302A45SMLWT'
            WHEN 'A46R' THEN '599302A46RFZ'
            WHEN 'A4EDF1' THEN '599302A4EDF1VG'
            WHEN 'A4EDF2' THEN '599302A4EDF2VJ'
            WHEN '613AD' THEN '599302613ADWQ'
            WHEN '860FAB' THEN '599302860FABPD'
            WHEN '877FAB' THEN '599302877FABR9'
            WHEN '860FABY' THEN '599302860FABYJE'
            WHEN '877EBY' THEN '599302877EBYSM'
            WHEN '877FABY' THEN '599302877FABYM8'
            WHEN '860PA' THEN '599302860PAZ9'
            WHEN '877PA' THEN '599302877PA2N'
            WHEN '860PAY' THEN '599302860PAYSD'
            WHEN '860PEY' THEN '599302860PEYSR'
            WHEN '877PAY' THEN '599302877PAYU9'
            WHEN '877PEY' THEN '599302877PEYUM'
        END)                                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM filtered_models fm

UNION ALL

    -- BasicUDI/identifier/UDICode by non_iol_parts
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        p.div                                       AS div,
        p.prodgr                                    AS prodgr,
        NULL                                        AS ver,
        p.pcode                                     AS pcode,
        NULL                                        AS plant,
        p.distchan                                  AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/identifier/UDICode'               AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        p.SAP_part_no                               AS partno,
        TO_CLOB(p.Basic_UDI)                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM non_iol_parts p

UNION ALL

    -- BasicUDI/model by non_iol_parts
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        p.div                                       AS div,
        p.prodgr                                    AS prodgr,
        NULL                                        AS ver,
        p.pcode                                     AS pcode,
        NULL                                        AS plant,
        p.distchan                                  AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/model'                            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        p.SAP_part_no                               AS partno,
        TO_CLOB(p.prodgr)                           AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM non_iol_parts p

UNION ALL

    -- UDI-DI/basicUDIIdentifier/DICode by filtered_models
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        '01'                                        AS div,
        fm.model                                    AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/basicUDIIdentifier/DICode'          AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(CASE fm.model
            WHEN '640PM' THEN '599302640PMYV'
            WHEN '677AD' THEN '599302677ADYN'
            WHEN '677ADY' THEN '599302677ADYRD'
            WHEN '677CMTY' THEN '599302677CMTYP3'
            WHEN '677CMY' THEN '599302677CMYSJ'
            WHEN '677CTAY' THEN '599302677CTAYND'
            WHEN '677MTY' THEN '599302677MTYUR'
            WHEN '677MY' THEN '599302677MY37'
            WHEN '677P' THEN '599302677PE9'
            WHEN '677PMY' THEN '599302677PMYUK'
            WHEN '677PY' THEN '599302677PY3G'
            WHEN '677TAY' THEN '599302677TAYU3'
            WHEN '690AD' THEN '599302690ADXZ'
            WHEN '690ADY' THEN '599302690ADYQJ'
            WHEN '690CMTY' THEN '599302690CMTYMG'
            WHEN '690CMY' THEN '599302690CMYRP'
            WHEN '690CTAY' THEN '599302690CTAYLS'
            WHEN '690MTY' THEN '599302690MTYTW'
            WHEN '690MY' THEN '599302690MY2J'
            WHEN '690TAY' THEN '599302690TAYT8'
            WHEN '640AD' THEN '599302640ADWW'
            WHEN '640ADY' THEN '599302640ADYNT'
            WHEN '640CMY' THEN '599302640CMYPY'
            WHEN '640MY' THEN '599302640MYZC'
            WHEN '640P' THEN '599302640PD5'
            WHEN '640PY' THEN '599302640PYZM'
            WHEN '677CTA' THEN '599302677CTARP'
            WHEN '677M' THEN '599302677ME3'
            WHEN '677MT' THEN '599302677MT2V'
            WHEN '677TA' THEN '599302677TA2C'
            WHEN '690CM' THEN '599302690CMYR'
            WHEN '690CTA' THEN '599302690CTAQU'
            WHEN '690TA' THEN '599302690TAZL'
            WHEN '860PT' THEN '599302860PT2J'
            WHEN '860PTY' THEN '599302860PTYU6'
            WHEN '860PETY' THEN '599302860PETYNW'
            WHEN '877PT' THEN '599302877PT3U'
            WHEN '877PTY' THEN '599302877PTYW2'
            WHEN '877PETY' THEN '599302877PETYRQ'
            WHEN 'A45DT' THEN '599302A45DT4H'
            WHEN 'A45RD2' THEN '599302A45RD2U9'
            WHEN 'A45RT' THEN '599302A45RT5T'
            WHEN 'A45SML' THEN '599302A45SMLWT'
            WHEN 'A46R' THEN '599302A46RFZ'
            WHEN 'A4EDF1' THEN '599302A4EDF1VG'
            WHEN 'A4EDF2' THEN '599302A4EDF2VJ'
            WHEN '613AD' THEN '599302613ADWQ'
            WHEN '860FAB' THEN '599302860FABPD'
            WHEN '877FAB' THEN '599302877FABR9'
            WHEN '860FABY' THEN '599302860FABYJE'
            WHEN '877EBY' THEN '599302877EBYSM'
            WHEN '877FABY' THEN '599302877FABYM8'
            WHEN '860PA' THEN '599302860PAZ9'
            WHEN '877PA' THEN '599302877PA2N'
            WHEN '860PAY' THEN '599302860PAYSD'
            WHEN '860PEY' THEN '599302860PEYSR'
            WHEN '877PAY' THEN '599302877PAYU9'
            WHEN '877PEY' THEN '599302877PEYUM'
        END)                                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM filtered_models fm

UNION ALL

    -- UDI-DI/basicUDIIdentifier/DICode by non_iol_parts
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        p.div                                       AS div,
        p.prodgr                                    AS prodgr,
        NULL                                        AS ver,
        p.pcode                                     AS pcode,
        NULL                                        AS plant,
        p.distchan                                  AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/basicUDIIdentifier/DICode'          AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        p.SAP_part_no                               AS partno,
        TO_CLOB(p.Basic_UDI)                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM non_iol_parts p

UNION ALL

    -- UDI-DI/basicUDIIdentifier/issuingEntityCode by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/basicUDIIdentifier/issuingEntityCode' AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('GS1')                              AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

-----------------------------------------------------------------------
--UDI-DI section-------------------------------------------------------
-----------------------------------------------------------------------


    -- UDI-DI/identifier/DICode by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/identifier/DICode'                  AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(q'[{{SAP_GTIN}}]')                  AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/identifier/issuingEntityCode by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/identifier/issuingEntityCode'       AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('GS1')                              AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

    -- UDI-DI/referenceNumber by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/referenceNumber'                    AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB(q'[{{SAP_GTIN}}]')                  AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/sterile by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/sterile'                            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('true')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/sterilization by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/sterilization'                      AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/website by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/website'                            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('www.medicontur.com/eifus')         AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/numberOfReuses by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/numberOfReuses'                     AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('0')                                AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/baseQuantity by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/baseQuantity'                       AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('1')                                AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/latex by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/latex'                              AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions

UNION ALL

    -- UDI-DI/reprocessed by division
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        div                                         AS div,
        NULL                                        AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        NULL                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'udi_di/reprocessed'                        AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('false')                             AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM divisions


/*
    -- BasicUDI/Lens model by filtered_models
    SELECT
        'EUDAMED'                                   AS rowtype,
        NULL                                        AS semi,
        NULL                                        AS fin,
        '01'                                        AS div,
        fm.model                                    AS prodgr,
        NULL                                        AS ver,
        NULL                                        AS pcode,
        NULL                                        AS plant,
        '01'                                        AS distchain,
        NULL                                        AS lang,
        NULL                                        AS prver,
        'basicudi/model'                            AS name,
        NULL                                        AS dpt_l,
        NULL                                        AS dpt_h,
        NULL                                        AS cyl_l,
        NULL                                        AS cyl_h,
        NULL                                        AS partno,
        TO_CLOB('''=PRODGR')                        AS valtext,
        NULL                                        AS valnom,
        NULL                                        AS valmin,
        NULL                                        AS valmax,
        NULL                                        AS validfrom
    FROM filtered_models fm
*/


--FROM portfolio_data pd
--WHERE pd.model IN (SELECT model FROM filtered_models)
;
