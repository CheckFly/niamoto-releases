
--------- forest_cover ------------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forest' class_object,
			'Forêt' class_name,
		round(forest_area_ha/land_area_ha,2)*100 as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
	Union	
	Select 'cover_forest' class_object,
			'Hors-forêt' class_name,
		round((land_area_ha-forest_area_ha)/land_area_ha, 2)*100 as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
) cover_forest
order by shape_id,class_object, class_name);

----------- forest_um cover ---------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forestum' class_object,
			'Forêt' class_name,
		Case  when landum_area_ha>0 then round(forest_um_area_ha/landum_area_ha,2)*100 else 0 end as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
	Union	
	Select 'cover_forestum' class_object,
			'Hors-forêt' class_name,
		Case  when landum_area_ha>0  then round((landum_area_ha-forest_um_area_ha)/landum_area_ha, 2)*100 else 0 end as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
) cover_forestum
order by shape_id,class_object, class_name);

----------- forest_num cover ---------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forestnum' class_object,
			'Forêt' class_name,
		Case  when (land_area_ha-landum_area_ha)>0 then round((forest_area_ha-forest_um_area_ha)/(land_area_ha-landum_area_ha),2)*100 else 0 end as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
	Union	
	Select 'cover_forestnum' class_object,
			'Hors-forêt' class_name,
		Case  when (land_area_ha-landum_area_ha)>0  then round(((land_area_ha-forest_area_ha)-(landum_area_ha-forest_um_area_ha))/(land_area_ha-landum_area_ha), 2)*100 else 0 end as class_value,
		gid shape_id
		from atlas_pn.pn_emprises
) cover_forestnum
order by shape_id,class_object, class_name);

----------Onglet occupation (type forestiers, proportion forêts)-----------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_foresttype' class_object,
			'Forêt secondaire' class_name,
		case when forest_area_ha>0 then round(((forest_area_ha -forest_100m_ha)/forest_area_ha)::numeric,2)*100 else 0 end as forest_core,
		gid shape_id
		from atlas_pn.pn_emprises
	Union	
	Select 'cover_foresttype' class_object,
			'Forêt mature' class_name,
		case when forest_area_ha>0 then round(((forest_100m_ha-forest_ssdm80_ha)/forest_area_ha)::numeric,2)*100 else 0 end as  forest_mature,
		gid shape_id
		from atlas_pn.pn_emprises
	Union
	Select 'cover_foresttype' class_object,
			'Forêt coeur' class_name,
		case when forest_area_ha>0 then round((forest_ssdm80_ha/forest_area_ha)::numeric,2)*100 else 0 end as forest_coeur,
		gid shape_id
		from atlas_pn.pn_emprises
) cover_foresttype
order by shape_id,class_object, class_name);


------- admin forest cover --------------------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forestadmin' class_object,
		'Concession' class_name,
		case when forest_area_ha>0 then round(forest_mining_ha/forest_area_ha,3) * 100 else 0 end as forest,
		gid shape_id
		from atlas_pn.pn_emprises where type='Commune'
	Union
	Select 'cover_forestadmin' class_object,
		'Réserves' class_name,
		case when forest_area_ha>0 then round(forest_reserve_ha/forest_area_ha,3) * 100 else 0 end as forest,
		gid shape_id
		from atlas_pn.pn_emprises where type='Commune'
	Union
	Select 'cover_forestadmin' class_object,
		'Forêt' class_name,
		case when forest_area_ha>0 then round((forest_area_ha - forest_reserve_ha - forest_mining_ha)/forest_area_ha,3) *100 else 0 end as forest,
		gid shape_id
		from atlas_pn.pn_emprises where type='Commune'
	
) cover_forestadmin
order by shape_id, class_object, forest);
