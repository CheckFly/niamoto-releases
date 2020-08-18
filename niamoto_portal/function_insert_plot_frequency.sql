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


        INSERT INTO niamoto_portal.data_plot_frequency (class_object,class_name, class_value, plot_id, param3_float)

        select * from (
        select 'stems' class_object, 'vivante' classname, round(living_stems/total_stems::numeric,2)*100 class_value, id_locality plot_id,2 i from niamoto_preprocess.data_plot_plot
        union ALL
        select 'stems'  class_object, 'morte' classname,round((total_stems - living_stems)/total_stems::numeric,2)*100 class_value, id_locality plot_id,1 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'type_plant'  class_object, 'arbres' classname,round(total_stems/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,1 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'type_plant'  class_object, 'fougères' classname,round(ferns/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,2 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'type_plant'  class_object, 'palmiers' classname,round(palms/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,3 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'type_plant'  class_object, 'lianes' classname,round(lianas/(ferns+palms+lianas+total_stems)::numeric,2)*100 class_value, id_locality plot_id,4 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'strates'  class_object, 'emergant' classname,round(emergent/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,1 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'strates'  class_object, 'canopée' classname,round(canopy/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,2 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'strates'  class_object, 'sous-canopée' classname,round(undercanopy/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,3 i from niamoto_preprocess.data_plot_plot
        UNION ALL
        select 'strates'  class_object, 'sous-bois' classname,round(understorey/(living_stems)::numeric,2)*100 class_value, id_locality plot_id,4 i from niamoto_preprocess.data_plot_plot
        ) as t order by 4,1,5;

        RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_plot_frequency()
    OWNER TO amapiac;
