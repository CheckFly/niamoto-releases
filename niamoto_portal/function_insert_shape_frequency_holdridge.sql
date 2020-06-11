-- FUNCTION: niamoto_portal.insert_shape_frequency_holdridge()

-- DROP FUNCTION niamoto_portal.insert_shape_frequency_holdridge();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape_frequency_holdridge(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN
		

with 
	hodlridge_classif as (
		select * from (
			select gid_emprise,mnt_object,'1' cl,'Sec' classe, sum(pixelcount) pixelcount from niamoto_preprocess.emprises_holdridge
			where classe in ('1') and mnt_object in ('forest', 'land')
			group by 1,2,3,4
			union
			select gid_emprise,mnt_object,'2' cl,'Humide'classe, sum(pixelcount) pixelcount from niamoto_preprocess.emprises_holdridge
			where classe in ('2') and mnt_object in ('forest', 'land')
			group by 1,2,3,4
			union
			select gid_emprise,mnt_object,'3' cl,'Très humide'classe, sum(pixelcount) pixelcount from niamoto_preprocess.emprises_holdridge
			where classe in ('3') and mnt_object in ('forest', 'land')
			group by 1,2,3,4) as hodlridge_classif order by 1,2,3),
	shape_land_all_pixel as (
		SELECT gid_emprise, type,name, sum(pixelcount) allpixel
					FROM  niamoto_preprocess.emprises a
					LEFT JOIN niamoto_preprocess.emprises_holdridge b	ON a.gid=b.gid_emprise
				   WHERE b.mnt_object = 'land'
					GROUP BY gid_emprise, type, name)
					
INSERT INTO niamoto_portal.data_shape_frequency(class_object, class_name, class_value, shape_id)
	(SELECT concat('holdridge_', hc.mnt_object) class_object,
		hc.classe, 
		Case when hc.pixelcount >0 then round((hc.pixelcount::float/sap.allpixel)::numeric,3) else 0 end  class_value,
		hc.gid_emprise shape_id 
	from hodlridge_classif hc
	left join shape_land_all_pixel sap on hc.gid_emprise=sap.gid_emprise)

UNION ALL

SELECT 'holdridge_forest_out' class_object,
		hc_forest.classe,
		Case when (hc_land.pixelcount-hc_forest.pixelcount) >0 then round(((hc_land.pixelcount-hc_forest.pixelcount)::float/sap.allpixel)::numeric,3) else 0 end  class_value,
		hc_forest.gid_emprise shape_id 
	from hodlridge_classif hc_forest
	left join shape_land_all_pixel sap on hc_forest.gid_emprise=sap.gid_emprise 
	left join hodlridge_classif hc_land on hc_forest.gid_emprise=hc_land.gid_emprise and hc_land.mnt_object='land' and hc_forest.classe=hc_land.classe
	where hc_forest.mnt_object='forest';

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_holdridge()
    OWNER TO amapiac;
