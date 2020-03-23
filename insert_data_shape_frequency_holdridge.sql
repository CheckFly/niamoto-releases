--------- Holdridge --------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(SELECT 'holdridge' class_object,
	Case b.classe
		When 1 then 'Très sec'
		When 2 then 'Sec'
		When 3 then 'Humide'
		When 4 then 'Très humide'
		When 5 then 'Toujours humide'
	end	as classe_name, 
	round((sum(b.pixelcount)::float/c.allpixel)::numeric,2) class_value,
	a.gid shape_id
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN atlas_pn.pn_emprises_holdridge  b ON 	a.gid=b.gid_emprise
LEFT Join (SELECT gid_emprise, type,name, Case When sum(pixelcount)>0 then sum(pixelcount) else 1 end as allpixel
			FROM  atlas_pn.pn_emprises a
			LEFT JOIN atlas_pn.pn_emprises_holdridge b	ON a.gid=b.gid_emprise
		   WHERE b.mnt_object in ('forest', 'land')
			GROUP BY gid_emprise, type, name)  c 
	ON 	a.gid=c.gid_emprise
WHERE b.mnt_object in ('forest', 'land')
GROUP BY 
	a.gid, a.type, a.name, b.classe,c.allpixel
ORDER BY
	a.gid);

-------- holdridge forest ------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	((SELECT concat('holdridge_', b.mnt_object) class_object,
	Case b.classe
		When 1 then 'Très sec'
		When 2 then 'Sec'
		When 3 then 'Humide'
		When 4 then 'Très humide'
		When 5 then 'Toujours humide'
	end	as classe_name, 
	Case when b.pixelcount >0 then round((b.pixelcount::float/c.allpixel)::numeric,2) else 0 end  class_value,
	a.gid shape_id
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN atlas_pn.pn_emprises_holdridge  b ON 	a.gid=b.gid_emprise and  b.mnt_object = 'forest'
LEFT Join (SELECT gid_emprise, type,name, sum(pixelcount) allpixel
			FROM  atlas_pn.pn_emprises a
			LEFT JOIN atlas_pn.pn_emprises_holdridge b	ON a.gid=b.gid_emprise
		   WHERE b.mnt_object = 'land'
			GROUP BY gid_emprise, type, name)  c 
	ON 	a.gid=c.gid_emprise
ORDER BY
	a.gid));

INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	((SELECT concat('holdridge_out', b.mnt_object) class_object,
	Case b.classe
		When 1 then 'Très sec'
		When 2 then 'Sec'
		When 3 then 'Humide'
		When 4 then 'Très humide'
		When 5 then 'Toujours humide'
	end	as classe_name, 
	Case when b.pixelcount>0 then round(((d.pixelcount-b.pixelcount::float)/c.allpixel)::numeric,2) else 0 end class_value,
	a.gid shape_id
FROM  
	atlas_pn.pn_emprises a
LEFT JOIN atlas_pn.pn_emprises_holdridge  b ON 	a.gid=b.gid_emprise and b.mnt_object = 'forest'
LEFT Join (SELECT gid_emprise, type,name, sum(pixelcount) as allpixel
			FROM  atlas_pn.pn_emprises a
			LEFT JOIN atlas_pn.pn_emprises_holdridge b	ON a.gid=b.gid_emprise
		   WHERE b.mnt_object = 'land'
			GROUP BY gid_emprise, type, name)  c 
	ON 	a.gid=c.gid_emprise
LEFT JOIN atlas_pn.pn_emprises_holdridge  d ON 	a.gid=d.gid_emprise and  d.mnt_object='land' and b.classe=d.classe
ORDER BY
	a.gid));

--------------------
--------Holdridge
-- INSERT INTO niamoto_portal.data_shape_frequency (shape_id, class_object, class_name, class_value)
-- WITH count_emprise AS (Select gid_emprise, sum(pixelcount) n_count FROM atlas_pn.pn_emprises_holdridge GROUP BY gid_emprise)
-- SELECT a.gid_emprise shape_id,
-- 'Holdridge' as class_object,
-- CASE 
-- 			WHEN classe = 1 THEN 'Très sec'
-- 			WHEN classe = 2 THEN 'Sec'
-- 			WHEN classe = 3 THEN 'Humide'
-- 			WHEN classe = 4 THEN 'Très humide'
-- 			WHEN classe = 5 THEN 'Toujours humide'
-- 		END AS class_name,
-- 		CASE WHEN n_count>0 THEN sum (pixelcount)/n_count ELSE 0 END as class_value
-- FROM 
-- atlas_pn.pn_emprises_holdridge a
-- LEFT JOIN count_emprise b ON a.gid_emprise=b.gid_emprise
-- GROUP BY a.gid_emprise, classe,n_count
-- order by shape_id, classe
-- ;