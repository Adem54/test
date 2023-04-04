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
	
	function convertFromLonLat(aLonLat)
	{
		let coordXY = ol.proj.transform(aLonLat, 'EPSG:4326', 'EPSG:3857');
		let coordX = coordXY[0];
		let coordY = coordXY[1];

		return [coordX, coordY];
	}

	function swapCommaFrom(sStr)
	{
		let sNewStr = sStr.replace(/@@C/g, ',');
		return (sNewStr);
	}

	//aMapLayers comes from admin_road_plowing_map_layers.php which is checked plowing among maplayers
	aMapLayers = aMapLayers.map(aLayer=>
	{
	console.log("aLayer:",aLayer);
		aLayer = aLayer.map(oShape => {
		
			let { type,coordinates,name }=oShape;

			if (type === "POINT")
			{
				name = swapCommaFrom(name);
				coordinates = convertFromLonLat(coordinates);
				return { ...oShape,name,coordinates,type: "Point" };
			}
			else if (type === "LINESTRING")
			{
				name = swapCommaFrom(name);		
				coordinates = coordinates.map(aCoord => {
				aCoord = convertFromLonLat(aCoord);
					
					return aCoord;
				});
				return { ...oShape,name,coordinates,type: "LineString" };
			}
			else if (type === "POLYGON")
			{
				name = swapCommaFrom(name);
				coordinates = coordinates.map(aCoord => {
				aCoord = convertFromLonLat(aCoord);
					return aCoord;
				});
				return { ...oShape,name,coordinates:[coordinates],type: "Polygon" };
			}
		});
		console.log("aLayerrrrrrrrrr:",aLayer);
		return aLayer;	
	});
	
	console.log("aMapLayers after map func: ", aMapLayers);
	let aFeaturesFromMapLayers = [];
	//let aFeaturesTest = [];
	aMapLayers = aMapLayers.map(aMapLayer=>
	{
		aMapLayer = aMapLayer.map(oShape =>
		{
			let { id,name,coordinates,type,category_id } = oShape;

			aFeaturesFromMapLayers.push(new ol.Feature({	geometry: new ol.geom[type](coordinates),	name,id:category_id }));
			return { ...oShape,feature:new ol.Feature({ geometry: new ol.geom[type](coordinates),	name,id:category_id })};
		});
		return aMapLayer;
	});

	console.log("aMapLayersAfterFeature: ", aMapLayers);
	console.log("aFeaturesTest: ",aFeaturesFromMapLayers);
	let sourceFromMapLayer = new ol.source.Vector({
		//	features: [g_lastFeature,featureLine,featurePoint]
		features: aFeaturesFromMapLayers
	});

	//Style..this is just style after features category..
	g_defaultShapeStyle = new ol.style.Style({
		fill: new ol.style.Fill({
			color: 'rgba(255, 255, 255, 0.2)'
		}),
		stroke: new ol.style.Stroke({
			color: '#3300ff', // Blue
			width: 2
		}),
		image: new ol.style.Circle({
			radius: 7,
			fill: new ol.style.Fill({
				color: '#3300ff'
			})
		})
	});

	//blue-vei
	let lineRoadStyle = new ol.style.Style({
		stroke:new ol.style.Stroke({
			color:[10, 129, 247,1],
			width:4
		})
	});

	//green-fortau
	let linePavementStyle =	new ol.style.Style({
		stroke:new ol.style.Stroke({
			color:[53, 237, 17,1],
			width:4
		})
	});

	//weak green - brøyted område
	let polygonPlowedAreaStyle = new ol.style.Style({ 
		fill:new ol.style.Fill({
		color:[174, 232, 174,0.6],
		})
	});

	//brøyted område - stroke
	let polygonPlowedAreaBorder = new ol.style.Style({
		stroke:new ol.style.Stroke({
			color:[77, 168, 77,1],
			width:1
		})
	});
	
	//blue(litt light) - depon i område
	//color:[51, 139, 212,1],
	let polygonLandfillAreaStyle =new ol.style.Style({ 
		fill:new ol.style.Fill({
			color:[159, 189, 201,0.6],
		})
	});
	
	let polygonLandfillAreaBorder = new ol.style.Style({
		stroke:new ol.style.Stroke({
			color:[59, 99, 115,1],
			width:1
		})
	});
	
	let pointInfoStyle = new ol.style.Style({ 
		image:new ol.style.Icon({
	//	src: 'img/information_black.svg',
		src: 'img/info2.png',
		size:[100,100],
		offset:[0,0],
		opacity:1,
		scale:0.6,
		color:[10,98,240,1],
		})
	});

	//src: 'img/redflag.svg'
	let pointDangerStyle = new ol.style.Style({
		image:new ol.style.Icon({
		src: 'img/danger.png',
		size:[100,100],
		offset:[0,0],
		opacity:1,
		scale:0.6,
		color:[239, 247, 10,1]
		
		})
	});

	aFeaturesFromMapLayers.forEach(feature=>{		
	let iCategoryId = feature.get("id")
	//console.log("iCategoryId: ",iCategoryId);
	switch(iCategoryId) 
	{
		case 1:
			feature.setStyle([pointDangerStyle]);
			break;
		case 2:
			feature.setStyle([pointInfoStyle]);
			break;
		case 3:
			feature.setStyle([lineRoadStyle]);
			break;
		case 4:
			feature.setStyle([linePavementStyle]);
			break;
		case 5:
			feature.setStyle([polygonPlowedAreaStyle, polygonPlowedAreaBorder]);
			break;
		case 6:
			feature.setStyle([polygonLandfillAreaStyle, polygonLandfillAreaBorder]);
			break;
		default:
			feature.setStyle([g_defaultShapeStyle]);
	}
	});

	

	//admin_road_plowing_map_layers.php plowing checked maplayers--operation-end
	