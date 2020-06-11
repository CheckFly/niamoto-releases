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
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch >=0 AND aire_patch <10))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,20 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <20))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,30 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <30))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,40 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <40))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,50 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <50))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,60 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <60))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,70 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <70))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,80 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <80))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,90 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <90))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,100 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <100))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,125 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <125))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,150 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <150))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,175 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <175))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,200 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <200))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,225 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <225))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,250 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <250))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,275 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <275))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,300 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <300))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,325 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <325))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,350 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <350))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,375 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <375))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,400 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <400))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,425 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <425))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,450 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <450))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,475 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <475))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,500 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <500))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,600 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <600))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,700 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <700))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,800 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <800))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,900 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <900))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1100 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1100))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1200 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1200))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1300 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1300))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1400 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1400))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1500 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1500))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1600 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1600))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1700 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1700))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1800 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1800))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,1900 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <1900))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,2000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <2000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,7000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <7000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,12000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <12000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,17000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <17000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,22000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <22000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,27000 as class_name,
            round(coalesce(((sum(aire_patch) FILTER (WHERE aire_patch <27000))/ds.total),0)::numeric,5) as value , df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total

        union

        SELECT 'forest_fragmentation' as class_object,32000 as class_name,
            1 as value, df.gid as shape_id
        FROM niamoto_preprocess.data_forest df
        LEFT JOIN niamoto_preprocess.data_stats ds ON df.gid=ds.gid
        GROUP BY df.gid, ds.total) as fragmentation

        order by shape_id, class_name
    );   

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_fragmentation()
    OWNER TO amapiac;
