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

    -- Actor code for Medicontur distribution channel
    SELECT
        'EUD_ENV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        NULL                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        '33'                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'sender/node/NodeActorCode'     AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        'HU-MF-000026801'               AS valtext,
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
        'DE-MF-0000?????'               AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Risk class for IOL-s
    SELECT
        'EUD_DEV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        '01'                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'MDRBasicUDI/riskClass'         AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        NULL                            AS partno,
        'CLASS_IIB'                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Risk class for OVD-s
    SELECT
        'EUD_DEV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        '10'                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'MDRBasicUDI/riskClass'         AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        '?part_no_ovd'                  AS partno,
        'CLASS_IIB'                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

UNION ALL

    -- Risk class for CTR-s
    SELECT
        'EUD_DEV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        '11'                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'MDRBasicUDI/riskClass'         AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        '?part_no_ctr'                  AS partno,
        'CLASS_IIB'                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

    UNION ALL

    -- Risk class for PILMA-s
    SELECT
        'EUD_DEV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        '12'                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'MDRBasicUDI/riskClass'         AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        '?part_no_pilma'                AS partno,
        'CLASS_IIA'                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL

    -- Risk class for MDJ-s
    SELECT
        'EUD_DEV'                       AS rowtype,
        NULL                            AS semi,
        NULL                            AS fin,
        '12'                            AS div,
        NULL                            AS prodgr,
        NULL                            AS ver,
        NULL                            AS pcode,
        NULL                            AS plant,
        NULL                            AS distchain,
        NULL                            AS lang,
        NULL                            AS prver,
        'MDRBasicUDI/riskClass'         AS name,
        NULL                            AS dpt_l,
        NULL                            AS dpt_h,
        NULL                            AS cyl_l,
        NULL                            AS cyl_h,
        '?part_no_pilma'                AS partno,
        'CLASS_IIA'                     AS valtext,
        NULL                            AS valnom,
        NULL                            AS valmin,
        NULL                            AS valmax,
        NULL                            AS validfrom
    FROM DUAL





--FROM portfolio_data pd
--WHERE pd.model IN (SELECT model FROM filtered_models)
;
