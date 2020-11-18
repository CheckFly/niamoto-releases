-- FUNCTION: niamoto_portal.insert_shape_frequency_fragmentation()

-- DROP FUNCTION niamoto_portal.insert_shape_frequency_fragmentation();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape_frequency_fragmentation(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		
--extract classes and statistiques for any gid
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	
    (select * from (
        SELECT 'forest_fragmentation' as class_object,10 as class_name,
            round((area_ha_10/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id) 

        union

        SELECT 'forest_fragmentation' as class_object,20 as class_name,
            round((area_ha_20/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,30 as class_name,
            round((area_ha_30/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,40 as class_name,
            round((area_ha_40/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,50 as class_name,
            round((area_ha_50/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
        union

        SELECT 'forest_fragmentation' as class_object,60 as class_name,
            round((area_ha_60/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
        union

        SELECT 'forest_fragmentation' as class_object,70 as class_name,
            round((area_ha_70/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,80 as class_name,
            round((area_ha_80/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,90 as class_name,
            round((area_ha_90/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,100 as class_name,
            round((area_ha_100/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,125 as class_name,
            round((area_ha_125/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,150 as class_name,
            round((area_ha_150/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,175 as class_name,
            round((area_ha_175/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,200 as class_name,
            round((area_ha_200/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,225 as class_name,
            round((area_ha_225/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,250 as class_name,
            round((area_ha_250/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,275 as class_name,
            round((area_ha_275/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,300 as class_name,
            round((area_ha_300/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,325 as class_name,
            round((area_ha_325/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,350 as class_name,
            round((area_ha_350/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,375 as class_name,
            round((area_ha_375/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,400 as class_name,
            round((area_ha_400/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,425 as class_name,
            round((area_ha_425/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,450 as class_name,
            round((area_ha_450/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,475 as class_name,
            round((area_ha_475/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,500 as class_name,
            round((area_ha_500/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,600 as class_name,
            round((area_ha_600/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,700 as class_name,
            round((area_ha_700/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,800 as class_name,
            round((area_ha_800/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,900 as class_name,
            round((area_ha_900/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1000 as class_name,
            round((area_ha_1000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1100 as class_name,
            round((area_ha_1100/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1200 as class_name,
            round((area_ha_1200/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1300 as class_name,
            round((area_ha_1300/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1400 as class_name,
            round((area_ha_1400/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1500 as class_name,
            round((area_ha_1500/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
        union

        SELECT 'forest_fragmentation' as class_object,1600 as class_name,
            round((area_ha_1600/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1700 as class_name,
            round((area_ha_1700/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1800 as class_name,
            round((area_ha_1800/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,1900 as class_name,
            round((area_ha_1900/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)
        union

        SELECT 'forest_fragmentation' as class_object,2000 as class_name,
            round((area_ha_2000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,7000 as class_name,
            round((area_ha_7000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,12000 as class_name,
            round((area_ha_12000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,17000 as class_name,
            round((area_ha_17000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,22000 as class_name,
            round((area_ha_22000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        union

        SELECT 'forest_fragmentation' as class_object,35000 as class_name,
            round((area_ha_35000/total)::numeric,4) as value , gid as shape_id
        FROM data_preprocess.fragmentation WHERE exists (select 1 from niamoto_portal.data_shape_shape WHERE gid = id)

        order by shape_id, class_name
    );   

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_fragmentation()
    OWNER TO amapiac;
