-- FUNCTION: niamoto_portal.insert_plot_frequency()

-- DROP FUNCTION niamoto_portal.insert_plot_frequency();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_plot_frequency(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN

        -- ALTER SEQUENCE niamoto_portal.data_plot_frequency_id_seq RESTART WITH 1;
        WITH
            familyTop10Total AS (
                SELECT plot_id, SUM(class_value) total
                FROM data_preprocess.data_plot_frequency 
                WHERE class_object='top10_family'
                GROUP BY plot_id
            ),
            speciesTop10Total AS (
                SELECT plot_id, SUM(class_value) total
                FROM data_preprocess.data_plot_frequency 
                WHERE class_object='top10_species'
                GROUP BY plot_id
            ),
            dbhTotal AS (
                SELECT plot_id, SUM(class_value) total
                FROM data_preprocess.data_plot_frequency
                WHERE class_object='dbh'
                GROUP BY plot_id
            )

        INSERT INTO niamoto_portal.data_plot_frequency (class_object,class_name, class_value, plot_id, class_index)

        select * from (
        select 'stems' class_object, 'vivante' classname, round(living_stems/total_stems::numeric,2)*100 class_value, id_locality plot_id,2 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        union ALL
        select 'stems'  class_object, 'morte' classname,round((total_stems - living_stems)/total_stems::numeric,2)*100 class_value, id_locality plot_id,1 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'type_plant'  class_object, 'arbres' classname,round(total_stems/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,1 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'type_plant'  class_object, 'fougères' classname,round(ferns/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,2 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'type_plant'  class_object, 'palmiers' classname,round(palms/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,3 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'type_plant'  class_object, 'lianes' classname,round(lianas/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,4 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'strates'  class_object, 'Emergent' classname,round(emergent/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,1 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'strates'  class_object, 'Canopée' classname,round(canopy/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,2 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'strates'  class_object, 'Sous-Canopée' classname,round(undercanopy/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,3 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION ALL
        select 'strates'  class_object, 'Sous-Bois' classname,round(understorey/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,4 i from data_preprocess.data_plot WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = id_locality)
        UNION  ALL
        select class_object, class_name, round((class_value/total)::numeric,2)*100 class_value, dpf.plot_id, class_index
		from data_preprocess.data_plot_frequency dpf
		LEFT JOIN familyTop10Total ftt ON dpf.plot_id = ftt.plot_id
		WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = dpf.plot_id)
            AND class_object ='top10_family' AND class_index <= 10
        UNION ALL
        select class_object, class_name, round((class_value/total)::numeric,2)*100 class_value, dpf.plot_id,class_index
		from data_preprocess.data_plot_frequency dpf
		LEFT JOIN speciesTop10Total ftt ON dpf.plot_id = ftt.plot_id
		WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = dpf.plot_id)
			AND class_object='top10_species' AND class_index <= 10
        UNION ALL
        select class_object, class_name, round((class_value/total)::numeric,2)*100 class_value, dpf.plot_id,class_index
		from data_preprocess.data_plot_frequency dpf
		LEFT JOIN dbhTotal dt ON dpf.plot_id = dt.plot_id
		WHERE exists (select 1 from niamoto_portal.data_plot_plot WHERE id = dpf.plot_id)
			AND class_object='dbh' AND class_index <= 10
        ) as t order by 4,1,5;

        RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_plot_frequency()
    OWNER TO amapiac;
