<style>
.ol-control button {
background-color: gray;
} 
</style>
<link type="text/css" rel="stylesheet" href="css/map.css" />
<script src="js/map_gps.js?v={{@version_js}}"></script>
<script  src="modules/module_map_util.js"></script>
<!--script src="modules/module_websocket.js"></script-->

<script>
	//admin_road_plowing_map_layers.php plowing checked maplayers--operation start

	let sMapLayers='{{@mapLayers}}'; 
	let aMapLayers = JSON.parse(sMapLayers);
	console.log("aMapLayers: ",aMapLayers);

	let class_mapLayer = new module_map_layers(aMapLayers);

	class_mapLayer.modifyMapLayersByFeatureFormat(aMapLayers);
	class_mapLayer.createFeaturesFromMapLayers();
	class_mapLayer.createStylesForMapLayersFeature();
	class_mapLayer.setStyleByCategory();

	let sourceFromMapLayer = class_mapLayer.createSourceFromMapLayer();
	//admin_road_plowing_map_layers.php plowing checked maplayers--operation-end
		