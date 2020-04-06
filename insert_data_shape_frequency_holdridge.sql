with 
	hodlridge_classif as (
		select * from (
			select gid_emprise,mnt_object,'Sec' classe, sum(pixelcount) pixelcount from atlas_pn.pn_emprises_holdridge
			where classe in ('1','2') and mnt_object in ('forest', 'land')
			group by 1,2,3
			union
			select gid_emprise,mnt_object,'Humide'classe, sum(pixelcount) pixelcount from atlas_pn.pn_emprises_holdridge
			where classe in ('3') and mnt_object in ('forest', 'land')
			group by 1,2,3
			union
			select gid_emprise,mnt_object,'Très humide'classe, sum(pixelcount) pixelcount from atlas_pn.pn_emprises_holdridge
			where classe in ('4','5') and mnt_object in ('forest', 'land')
			group by 1,2,3) as hodlridge_classif),
	shape_land_all_pixel as (
		SELECT gid_emprise, type,name, sum(pixelcount) allpixel
					FROM  atlas_pn.pn_emprises a
					LEFT JOIN atlas_pn.pn_emprises_holdridge b	ON a.gid=b.gid_emprise
				   WHERE b.mnt_object = 'land'
					GROUP BY gid_emprise, type, name)
					
INSERT INTO niamoto_portal.data_shape_frequency(class_object, class_name, class_value, shape_id)
	SELECT concat('holdridge_', hc.mnt_object) class_object,
		hc.classe, 
		Case when hc.pixelcount >0 then round((hc.pixelcount::float/sap.allpixel)::numeric,3) else 0 end  class_value,
		hc.gid_emprise shape_id 
	from hodlridge_classif hc
	left join shape_land_all_pixel sap on hc.gid_emprise=sap.gid_emprise


UNION ALL


	SELECT 'holdridge_forest_out' class_object,
		hc.classe,
		Case when (hc.pixelcount-hc_forest.pixelcount) >0 then round(((hc.pixelcount-hc_forest.pixelcount)::float/sap.allpixel)::numeric,3) else 0 end  class_value,
		hc.gid_emprise shape_id 
	from hodlridge_classif hc
	left join shape_land_all_pixel sap on hc.gid_emprise=sap.gid_emprise and hc.mnt_object = 'land' 
	left join hodlridge_classif hc_forest on hc.gid_emprise=hc_forest.gid_emprise and hc_forest.mnt_object='forest' and hc.classe=hc_forest.classe
	where hc.mnt_object='land'



