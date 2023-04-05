
/*
	mapLayers is an array which consist of another arrays
	mapLayers [
[{id: 1, name: 'point-1', type: 'POINT', coordinates: Array(2), category_id: 1},
{id: 2, name: 'point-2', type: 'POINT', coordinates: Array(2), category_id: 2}
]
	]
	
	*/

declare var ol: any;
declare var feature: any;
declare var sourceFromMapLayer:any;

type Point1 = Array<string>;
type LineString1 = Array<Point1>;
type Point2 = Array<number>;
type LineString2 = Array<Point2>;
type Polygon = Array<LineString2>;

interface Layer{
	id:number,
	name:string,
	type:string,
//	coordinates:(Point1 | LineString1 | Point2 | LineString2 | Polygon) ,
	 coordinates:any,
	category_id:number,
	feature?:any
}

/*
type GridRow = GridCell[]   //array of cells
const grid: GridRow[] = []; //array of rows
*/
type MapLayer = Array<Layer>;
//type MapLayer = Layer[];
type MapLayers = Array<MapLayer>;

class module_map_layers {

	//{id: 1, name: 'point-1', type: 'POINT', coordinates: Array(2), category_id: 1}
	public mapLayer:MapLayer;
	public mapLayers:MapLayers;


	private aFeaturesFromMapLayers:any;
	private g_defaultShapeStyle:any;
	private lineRoadStyle:any;
	private linePavementStyle:any;
	private polygonPlowedAreaStyle:any;
	private polygonPlowedAreaBorder:any;
	private polygonLandfillAreaStyle:any;
	private polygonLandfillAreaBorder:any;
	private pointInfoStyle:any;
	private pointDangerStyle:any;

	constructor(maplayers:MapLayer[]){
		this.mapLayers = maplayers;
	}

	 convertFromLonLat(aLonLat:any):any
	{
		let coordXY = ol.proj.transform(aLonLat, 'EPSG:4326', 'EPSG:3857');
		let coordX = coordXY[0];
		let coordY = coordXY[1];

		return [coordX, coordY];
	}

	swapCommaFrom(sStr:any):any
	{
		let sNewStr = sStr.replace(/@@C/g, ',');
		return (sNewStr);
	}

	//parseMaplayer  - modifyMapLayerByFeatureFormat

	modifyMapLayerByFeatureFormat(maplayers:MapLayers):MapLayers
	{
		maplayers = maplayers.map((aLayer:MapLayer)=>
			{
				aLayer = aLayer.map((oShape:Layer) => {
					let { type,coordinates,name } = oShape;
		
					if (type === "POINT")
					{
						name = this.swapCommaFrom(name);
						coordinates = this.convertFromLonLat(coordinates);
						return { ...oShape,name,coordinates,type: "Point" };
					}
					else if (type === "LINESTRING")
					{
						name = this.swapCommaFrom(name);
						coordinates = coordinates.map((aCoord) => {
							aCoord = this.convertFromLonLat(aCoord);
							return aCoord;
						});
						return { ...oShape,name,coordinates,type: "LineString" };
					}
					else if (type === "POLYGON")
					{
						name = this.swapCommaFrom(name);
						coordinates = coordinates.map(aCoord => {
							aCoord = this.convertFromLonLat(aCoord);
							return aCoord;
						});
						return { ...oShape,name,coordinates:[coordinates],type: "Polygon" };
					}
				});
				return aLayer;	
			});
		
		return maplayers;
	}

	createFeaturesFromMapLayers():MapLayers
	{
		this.aFeaturesFromMapLayers = [];
		//let aFeaturesTest = [];
		let aMapLayers =this.modifyMapLayerByFeatureFormat(this.mapLayers);
		aMapLayers = aMapLayers.map(aMapLayer=>
		{
			aMapLayer = aMapLayer.map(oShape =>
			{
				let { id,name,coordinates,type,category_id } = oShape;
	
				this.aFeaturesFromMapLayers.push(new ol.Feature({	geometry: new ol.geom[type](coordinates),	name,id:category_id }));
				return { ...oShape,feature:new ol.Feature({ geometry: new ol.geom[type](coordinates),	name,id:category_id })};
			});
			return aMapLayer;
		});
	 return aMapLayers;	
	}

	createStylesForMapLayersFeature()
	{
		this.g_defaultShapeStyle = new ol.style.Style({
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
		this.lineRoadStyle = new ol.style.Style({
			stroke:new ol.style.Stroke({
				color:[10, 129, 247,1],
				width:4
			})
		});
	
		//green-fortau
		this.linePavementStyle =	new ol.style.Style({
			stroke:new ol.style.Stroke({
				color:[53, 237, 17,1],
				width:4
			})
		});
	
		//weak green - brøyted område
		this.polygonPlowedAreaStyle = new ol.style.Style({ 
			fill:new ol.style.Fill({
			color:[174, 232, 174,0.6],
			})
		});
	
		//brøyted område - stroke
		this.polygonPlowedAreaBorder = new ol.style.Style({
			stroke:new ol.style.Stroke({
				color:[77, 168, 77,1],
				width:1
			})
		});
		
		//blue(litt light) - depon i område
		//color:[51, 139, 212,1],
		this.polygonLandfillAreaStyle =new ol.style.Style({ 
			fill:new ol.style.Fill({
				color:[159, 189, 201,0.6],
			})
		});
		
		this.polygonLandfillAreaBorder = new ol.style.Style({
			stroke:new ol.style.Stroke({
				color:[59, 99, 115,1],
				width:1
			})
		});
		
		this.pointInfoStyle = new ol.style.Style({ 
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
		this.pointDangerStyle = new ol.style.Style({
			image:new ol.style.Icon({
			src: 'img/danger.png',
			size:[100,100],
			offset:[0,0],
			opacity:1,
			scale:0.6,
			color:[239, 247, 10,1]
			
			})
		});
	}

	setStyleByCategory()
	{
		this.aFeaturesFromMapLayers.forEach(feature=>{		
		let iCategoryId = feature.get("id")
		//console.log("iCategoryId: ",iCategoryId);
			switch(iCategoryId) 
			{
				case 1:
					feature.setStyle([this.pointDangerStyle]);
					break;
				case 2:
					feature.setStyle([this.pointInfoStyle]);
					break;
				case 3:
					feature.setStyle([this.lineRoadStyle]);
					break;
				case 4:
					feature.setStyle([this.linePavementStyle]);
					break;
				case 5:
					feature.setStyle([this.polygonPlowedAreaStyle, this.polygonPlowedAreaBorder]);
					break;
				case 6:
					feature.setStyle([this.polygonLandfillAreaStyle, this.polygonLandfillAreaBorder]);
					break;
				default:
					feature.setStyle([this.g_defaultShapeStyle]);
			}
		})	
	}	

	createSourceFromMapLayer():any
	{
		let sourceFromMapLayer = new ol.source.Vector({
			//	features: [g_lastFeature,featureLine,featurePoint]
			features: this.aFeaturesFromMapLayers
		});
		return sourceFromMapLayer;
	}


}


