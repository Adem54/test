class module_map_layers {
	constructor(maplayers) {
	  console.log("constructor is working")
	  this.mapLayers = maplayers
	}
 
	convertFromLonLat(aLonLat) {
	  let coordXY = ol.proj.transform(aLonLat, "EPSG:4326", "EPSG:3857")
	  let coordX = coordXY[0]
	  let coordY = coordXY[1]
 
	  return [coordX, coordY]
	}
 
	swapCommaFrom(sStr) {
	  let sNewStr = sStr.replace(/@@C/g, ",")
	  return sNewStr
	}
 
	//parseMaplayer  - modifyMapLayersByFeatureFormat
 
	modifyMapLayersByFeatureFormat(maplayers) {
	  maplayers = maplayers.map(aLayer => {
		 aLayer = aLayer.map(oShape => {
			let { type, coordinates, name } = oShape
 
			if (type === "POINT") {
			  name = this.swapCommaFrom(name)
			  coordinates = this.convertFromLonLat(coordinates)
			  return { ...oShape, name, coordinates, type: "Point" }
			} else if (type === "LINESTRING") {
			  name = this.swapCommaFrom(name)
			  coordinates = coordinates.map(aCoord => {
				 aCoord = this.convertFromLonLat(aCoord)
				 return aCoord
			  })
			  return { ...oShape, name, coordinates, type: "LineString" }
			} else if (type === "POLYGON") {
			  name = this.swapCommaFrom(name)
			  coordinates = coordinates.map(aCoord => {
				 aCoord = this.convertFromLonLat(aCoord)
				 return aCoord
			  })
			  return {
				 ...oShape,
				 name,
				 coordinates: [coordinates],
				 type: "Polygon"
			  }
			}
		 })
		 return aLayer
	  })
 
	  return maplayers
	}
 
	createFeaturesFromMapLayers() {
	  this.aFeaturesFromMapLayers = []
	  //let aFeaturesTest = [];
	  let aMapLayers = this.modifyMapLayersByFeatureFormat(this.mapLayers)
	  aMapLayers = aMapLayers.map(aMapLayer => {
		 aMapLayer = aMapLayer.map(oShape => {
			let { id, name, coordinates, type, category_id } = oShape
 
			this.aFeaturesFromMapLayers.push(
			  new ol.Feature({
				 geometry: new ol.geom[type](coordinates),
				 name,
				 id: category_id
			  })
			)
			return {
			  ...oShape,
			  feature: new ol.Feature({
				 geometry: new ol.geom[type](coordinates),
				 name,
				 id: category_id
			  })
			}
		 })
		 return aMapLayer
	  })
	  return aMapLayers
	}
 
	createStylesForMapLayersFeature() {
	  this.g_defaultShapeStyle = new ol.style.Style({
		 fill: new ol.style.Fill({
			color: "rgba(255, 255, 255, 0.2)"
		 }),
		 stroke: new ol.style.Stroke({
			color: "#3300ff", // Blue
			width: 2
		 }),
		 image: new ol.style.Circle({
			radius: 7,
			fill: new ol.style.Fill({
			  color: "#3300ff"
			})
		 })
	  })
 
	  //blue-vei
	  this.lineRoadStyle = new ol.style.Style({
		 stroke: new ol.style.Stroke({
			color: [10, 129, 247, 1],
			width: 4
		 })
	  })
 
	  //green-fortau
	  this.linePavementStyle = new ol.style.Style({
		 stroke: new ol.style.Stroke({
			color: [53, 237, 17, 1],
			width: 4
		 })
	  })
 
	  //weak green - brøyted område
	  this.polygonPlowedAreaStyle = new ol.style.Style({
		 fill: new ol.style.Fill({
			color: [174, 232, 174, 0.6]
		 })
	  })
 
	  //brøyted område - stroke
	  this.polygonPlowedAreaBorder = new ol.style.Style({
		 stroke: new ol.style.Stroke({
			color: [77, 168, 77, 1],
			width: 1
		 })
	  })
 
	  //blue(litt light) - depon i område
	  //color:[51, 139, 212,1],
	  this.polygonLandfillAreaStyle = new ol.style.Style({
		 fill: new ol.style.Fill({
			color: [159, 189, 201, 0.6]
		 })
	  })
 
	  this.polygonLandfillAreaBorder = new ol.style.Style({
		 stroke: new ol.style.Stroke({
			color: [59, 99, 115, 1],
			width: 1
		 })
	  })
 
	  this.pointInfoStyle = new ol.style.Style({
		 image: new ol.style.Icon({
			//	src: 'img/information_black.svg',
			src: "img/info2.png",
			size: [100, 100],
			offset: [0, 0],
			opacity: 1,
			scale: 0.6,
			color: [10, 98, 240, 1]
		 })
	  })
 
	  //src: 'img/redflag.svg'
	  this.pointDangerStyle = new ol.style.Style({
		 image: new ol.style.Icon({
			src: "img/danger.png",
			size: [100, 100],
			offset: [0, 0],
			opacity: 1,
			scale: 0.6,
			color: [239, 247, 10, 1]
		 })
	  })
	}
 
	setStyleByCategory() {
	  this.aFeaturesFromMapLayers.forEach(feature => {
		 let iCategoryId = feature.get("id")
		 //console.log("iCategoryId: ",iCategoryId);
		 switch (iCategoryId) {
			case 1:
			  feature.setStyle([this.pointDangerStyle])
			  break
			case 2:
			  feature.setStyle([this.pointInfoStyle])
			  break
			case 3:
			  feature.setStyle([this.lineRoadStyle])
			  break
			case 4:
			  feature.setStyle([this.linePavementStyle])
			  break
			case 5:
			  feature.setStyle([
				 this.polygonPlowedAreaStyle,
				 this.polygonPlowedAreaBorder
			  ])
			  break
			case 6:
			  feature.setStyle([
				 this.polygonLandfillAreaStyle,
				 this.polygonLandfillAreaBorder
			  ])
			  break
			default:
			  feature.setStyle([this.g_defaultShapeStyle])
		 }
	  })
	}
 
	createSourceFromMapLayer() 
	{
	  let sourceFromMapLayer = new ol.source.Vector({
		 //	features: [g_lastFeature,featureLine,featurePoint]
		 features: this.aFeaturesFromMapLayers
	  })
	  return sourceFromMapLayer
	}
 }
 