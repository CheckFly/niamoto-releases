-- FUNCTION: niamoto_portal.insert_shape_frequency_cover()

-- DROP FUNCTION niamoto_portal.insert_shape_frequency_cover();

CREATE OR REPLACE FUNCTION niamoto_portal.insert_shape_frequency_cover(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

        BEGIN

ALTER SEQUENCE data_shape_frequency_id_seq RESTART WITH 1

--------- forest_cover ------------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forest' class_object,
			'Forêt' class_name,
		round(forest_area_ha/land_area_ha*100, 3) as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
	Union	
	Select 'cover_forest' class_object,
			'Hors-forêt' class_name,
		round((land_area_ha-forest_area_ha)/land_area_ha*100, 3) as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
) cover_forest
order by shape_id,class_object, class_name);

----------- forest_um cover ---------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forestum' class_object,
			'Forêt' class_name,
		Case  when land_um_area_ha>0 then round(forest_um_area_ha/land_um_area_ha*100, 3) else 0 end as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
	Union	
	Select 'cover_forestum' class_object,
			'Hors-forêt' class_name,
		Case  when land_um_area_ha>0  then round((land_um_area_ha-forest_um_area_ha)/land_um_area_ha*100, 3) else 0 end as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
) cover_forestum
order by shape_id,class_object, class_name);

----------- forest_num cover ---------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'cover_forestnum' class_object,
			'Forêt' class_name,
		Case  when (land_area_ha-land_um_area_ha)>0 then round((forest_area_ha-forest_um_area_ha)/(land_area_ha-land_um_area_ha)*100, 3) else 0 end as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
	Union	
	Select 'cover_forestnum' class_object,
			'Hors-forêt' class_name,
		Case  when (land_area_ha-land_um_area_ha)>0  then round(((land_area_ha-forest_area_ha)-(land_um_area_ha-forest_um_area_ha))/(land_area_ha-land_um_area_ha)*100, 3) else 0 end as class_value,
		gid shape_id
		from niamoto_preprocess.emprises
) cover_forestnum
order by shape_id,class_object, class_name);

----------Onglet occupation (type forestiers, proportion forêts)-----------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
		Select 'cover_foresttype' class_object,
				'Forêt secondaire' class_name,
			case when forest_area_ha>0 then round(((forest_area_ha -forest_100m_ha)/forest_area_ha)::numeric*100, 3) else 0 end as forest_core,
			gid shape_id
		from niamoto_preprocess.emprises
	Union	
		Select 'cover_foresttype' class_object,
			'Forêt mature' class_name,
			case when forest_area_ha>0 then round(((forest_100m_ha-forest_ssdm80_ha)/forest_area_ha)::numeric*100, 3) else 0 end as  forest_mature,
			gid shape_id
		from niamoto_preprocess.emprises
	Union
		Select 'cover_foresttype' class_object,
				'Forêt coeur' class_name,
				case when forest_area_ha>0 then round((forest_ssdm80_ha/forest_area_ha)::numeric*100, 3) else 0 end as forest_coeur,
				gid shape_id
		from niamoto_preprocess.emprises
) cover_foresttype
order by shape_id,class_object, class_name);

-- occupation du sol
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
		Select 'land_use' class_object,'01_NUM' class_name,land_area-land_um_area,id shape_id
		from niamoto_portal.data_shape_shape
	Union	
		Select 'land_use' class_object,'02_UM' class_name,land_um_area,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'03_ ' class_name,0,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'04_Sec' class_name,land_holdridge1,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'05_Humide' class_name,land_holdridge2,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'06_Très Humide' class_name,land_holdridge3,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'07_  ' class_name,0,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'08_Réserve' class_name,reserve_area,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'09_PPE' class_name,ppe_area,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'10_Concessions' class_name,mining_area,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'11_   ' class_name,0,id shape_id
		from niamoto_portal.data_shape_shape
	Union
		Select 'land_use' class_object,'12_Forêt' class_name,forest_area,id shape_id
		from niamoto_portal.data_shape_shape
) land_use
order by shape_id,class_object, class_name);

-- INSERT INTO niamoto_portal.data_shape_frequency(
-- ------- admin forest cover --------------------------------------
-- 	class_object, class_name, class_value, shape_id)
-- 	(select * from (
-- 	Select 'cover_forestadmin' class_object,
-- 		'Concession' class_name,
-- 		case when forest_area_ha>0 then round(forest_mining_ha/forest_area_ha*100, 0) else 0 end as forest,
-- 		gid shape_id
-- 		from niamoto_preprocess.emprises where type='Commune'
-- 	Union
-- 	Select 'cover_forestadmin' class_object,
-- 		'Réserves' class_name,
-- 		case when forest_area_ha>0 then round(forest_reserve_ha/forest_area_ha*100, 0) else 0 end as forest,
-- 		gid shape_id
-- 		from niamoto_preprocess.emprises where type='Commune'
-- 	Union
-- 	Select 'cover_forestadmin' class_object,
-- 		'Forêt' class_name,
-- 		case when forest_area_ha>0 then round((forest_area_ha - forest_reserve_ha - forest_mining_ha)/forest_area_ha*100, 0) else 0 end as forest,
-- 		gid shape_id
-- 		from niamoto_preprocess.emprises where type='Commune'
	
-- ) cover_forestadmin
-- order by shape_id, class_object, forest);

--------- substrat ------------------------------
INSERT INTO niamoto_portal.data_shape_frequency(
	class_object, class_name, class_value, shape_id)
	(select * from (
	Select 'substrat' class_object,
			'UM' class_name,
		case when land_um_area_ha is not null then round((land_um_area_ha)/land_area_ha*100, 3) else 0 end class_value,
		gid shape_id
		from niamoto_preprocess.emprises
	Union	
	Select 'substrat' class_object,
			'NUM' class_name,
		case when land_um_area_ha is not null then round((land_area_ha-land_um_area_ha)/land_area_ha*100, 3) else 0 end class_value,
		gid shape_id
		from niamoto_preprocess.emprises
) substrat
order by shape_id,class_object, class_name);

                RETURN 1;
        END;
$BODY$;

ALTER FUNCTION niamoto_portal.insert_shape_frequency_cover()
    OWNER TO amapiac;
