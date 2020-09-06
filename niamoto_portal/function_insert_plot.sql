-- FUNCTION: niamoto_portal.insert_plot()

-- DROP FUNCTION niamoto_portal.insert_plot();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_plot(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN

          TRUNCATE niamoto_portal.data_plot_plot CASCADE;
          INSERT INTO niamoto_portal.data_plot_plot(
                           id, label,location, species_level, total_stems, living_stems, count_families, count_species, shannon, pielou, simpson, basal_area, h_mean, dbh_mean, dbh_median, dbh_min, dbh_max)
        SELECT id_locality, locality,location, species_level, total_stems, living_stems, nb_families, nb_species, shannon, pielou, simpson, basal_area, h_mean, dbh_mean, dbh_median, dbh_min, dbh_max
        FROM niamoto_preprocess.data_plot_plot dpp
        WHERE plot_type = 'plot_100x100';
          
          RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_plot()
    OWNER TO amapiac;
