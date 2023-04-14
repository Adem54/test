<style>
.nss_btn_map_primary {
	background-color: var(--nss_primary);
	color: var(--nss_white);
	border-radius: 5px;
	color: white !important;
}

.nss_btn_map_danger {
	background-color: var(--nss_danger);
	color: var(--nss_white);
	border-radius: 5px;
	color: white !important;
}

.nss_btn_map_warning {
	background-color: var(--nss_warning);
	color: var(--nss_black);
	border-radius: 5px;
	color: white !important;
}

.ol-control button {
background-color: gray;
} 


</style>
<script src="js/nativescript-webview-interface.js?v={{@version_js}}"></script>
<script src="modules/module_map.js?v={{@version_js}}"></script>
<script src="modules/module_map_util.js"></script>
<script>

console.log("test---ADEM---test");
let sMapLayers='{{@mapLayers}}';
console.log("sMapLayers: ", sMapLayers);
let aMapLayers = JSON.parse(sMapLayers);

let oClassMapLayer = new module_map_layers(aMapLayers);
oClassMapLayer.modifyMapLayersByFeatureFormat(aMapLayers);
oClassMapLayer.createFeaturesFromMapLayers();
oClassMapLayer.createStylesForMapLayersFeature();
oClassMapLayer.setStyleByCategory();
let sourceFromMapLayer = oClassMapLayer.createSourceFromMapLayer(); 

//let aMapLayers = JSON.parse(sMapLayers);

const IS_ADMIN_TO_CHANGE_ORDER_STATUS = false;

// Define the flag type constants.
const OBJECT_STATUS_RED = {{@object_status_red}};
const OBJECT_STATUS_GREEN = {{@object_status_green}};
const OBJECT_STATUS_BLUE = {{@object_status_blue}};
const OBJECT_STATUS_ORANGE = {{@object_status_orange}};
const OBJECT_STATUS_RING = {{@object_status_ring}};
const OBJECT_STATUS_RING_MULTI = {{@object_status_ring_multi}};
const OBJECT_STATUS_RING_EXTRA = {{@object_status_ring_extra}};
const OBJECT_STATUS_RING_ORANGE = {{@object_status_ring_orange}};

console.log("obj-stats-red: ",OBJECT_STATUS_RED);

// Define the object type constants
const OBJECT_TYPE_COTTAGE = {{@object_type_cottage}};
const OBJECT_TYPE_APARTMENT = {{@object_type_apartment}};
const OBJECT_TYPE_PARKING = {{@object_type_parking}};
const OBJECT_TYPE_COTTAGE_NO_ROAD = {{@object_type_cottage_no_road}};
const OBJECT_TYPE_APARTMENT_BUILDING = {{@object_type_apartment_building}};
const OBJECT_TYPE_HOUSE = {{@object_type_house}};

const ICON_SIZE_SMALL = 0.5;
const ICON_SIZE_NORMAL = 1.0;
const ICON_SIZE_LARGE = 1.5;
const ICON_SIZE_HUGE = 2.0;

const WARNING_OFFSET_RING = 0;
const WARNING_OFFSET_FLAG = 1;
const WARNING_OFFSET_EXTRA = 2;

// The initial center point.
var g_dCENTER_LONGITUDE = {{@longitude}};
var g_dCENTER_LATITUDE = {{@latitude}};

var g_oWebViewInterface = window.nsWebViewInterface;
var g_overlayAreaName = null;
var g_timeoutAreaName = null;
var g_classMapSelect = new module_map();

//
// Terminate the popup.
function timeoutAreaName()
{
	$("#areaname").css("display", "none");
	
	window.clearTimeout(g_timeoutAreaName);
	g_timeoutAreaName = null;
}

function clearAreaNameTimeout()
{
	if (g_timeoutAreaName)
	{
		window.clearTimeout(g_timeoutAreaName);
		g_timeoutAreaName = null;
		$("#areaname").css("display", "none");
	}
}

var g_classMapClass = new function()
{
	this.SERVICE_MODE_ADMIN = 0;
	this.SERVICE_MODE_PLOWER = 1;
	//this.SERVICE_MODE_MARKALL = 2;
	
	this.m_aPreDefSms = [];
	this.m_bModuleImages = false;
	this.m_bAllow2Order = true;
	this.m_oSearchMarkerLayer = null;
	
	this.CURRENT_DEVICEID = "{{@device_id}}";
	this.m_myShow = null;
	this.m_bMapReadOnly = {{@map_read_only}};
	this.m_sMapTypeSelected = '{{@mapselected}}';
	//this.m_sMessageOnOrderConfirm = '{{@message_on_order_confirm}}';
	this.m_iServiceTemplateId = {{@service_template_id}};
	this.m_sServiceTag = '{{@service_tag}}';
	this.m_bColorBlind = {{@color_blind}};
	this.m_iLogPos = {{@logposition}};
	this.m_sIsAdminChangeOrderStatus = '{{@admin_change_order_status}}';
	this.m_sPlowerChangeOrderStatNoSms = '{{@plower_change_order_stat_no_sms}}';
	this.m_sIsPlowerSearch = '{{@map_plower_search}}';
	this.m_sIsAdminSearch = '{{@map_admin_search}}';
	this.m_dMapGPSAccuracy = {{@map_gps_accuracy}};
	this.m_dMapGPSMinSpeed = {{@map_gps_min_speed}};
	this.m_bMapHouseNo = {{@map_houseno}};
	this.m_bShowDateAboveFlag = {{@map_showdateaboveflag}};
	this.m_bDeviceOrientation = true; // Turn device orientation on or off.
	
	// Start point
	this.m_iPROVIDER_ID = {{@providerid}}; // The current providerid.
	this.m_iRentingProviderId = {{@renting_providerid}};
	this.m_iUSER_ID = {{@userid}};

	this.m_sName = '{{@shortname}}';
	this.m_bTogglePan = {{@toggle_pan}}; // true / false

	// Local variables.
	this.m_sDateToShow = '{{@today}}'; // Start with today.
	//this.m_bAreaDropdown = (this.m_sDropdownArea.toUpperCase()==='YES')?true:false;
	this.m_bOkClickMap = true; // Prevent other popups to popup when terminating one popup.

	// Map related variables.
	this.m_oMap = null; // The map object.
	this.m_oView = null; // The map view
	this.m_iZoom = 17;
	this.m_iRotate = 0;
	this.m_oMapLayer = null; // The map source used in layers.
	this.m_oAreaLayer = null;
	this.m_oFlagLayer = null;
	this.m_oMyPosLayer = null;
	this.m_oLayerFromMapLayerModule = null;
	this.m_element = null;
	this.m_popup;
	this.m_geolocation;
	this.m_oSearchMarker = null; // The marker used when searching.
	
	this.m_dHeading = 0;
	this.m_dAccuracy = 0;
	this.m_dSpeed = 0;
	this.m_iLastLat = 0;
	this.m_iLastLon = 0;
	this.m_iLastHeading = 0;
	this.m_iLastAltitude = 0;
	this.m_iLastSpeed = 0;
	this.m_iLastAccuracy = 0;
	this.m_iLastAltitudeAccuracy = 0;
	this.m_iUpdateFleetInterval = {{@fleet_interval}}; // Milliseconds
	this.m_aPositionList = [];
	this.m_timestampLastUpdatePos = 0;

	this.m_bShowAllAreas = {{@showallareas}};
	this.m_iSelectedAreaId = 0;
	this.m_iServiceMode = {{@servicemode}}; // Plower or Admin
	this.m_iShowAll = 0;
	this.m_iFlagSize = ICON_SIZE_NORMAL;
	this.m_oTimer = null;
	this.m_aFlags = [];
	this.m_aPlowPos = [];
	this.m_bArrivalTime = {{@usearrivaltime}};
	//this.m_bTrackMode = (this.m_iServiceMode===this.SERVICE_MODE_PLOWER || this.m_iServiceMode===this.SERVICE_MODE_MARKALL);
	this.m_bTrackMode = (this.m_iServiceMode===this.SERVICE_MODE_PLOWER);
	this.m_aPolygonList = []; // List of polygons to show.
	this.m_aWeekDays = [];
	this.m_aServiceAreas = [];
	this.m_defaultStyle = null;
	this.m_oLastLayer = null;
	this.m_oMyLastPos = null;
	this.m_oMyPosition = null;
	this.m_dLastHeadingDegrees = null;
	this.bMapCreated = false;
	
	// Create an empty vector for all the flags.
	this.m_vectorFlagSource = new ol.source.Vector({

	});

	// Create an empty vector for the positons on the map.
	this.m_vectorPositonSource = new ol.source.Vector({

	});

	this.m_iconStyleOther = new ol.style.Style({
		image: new ol.style.Icon({
			anchor: [ 0.5, 0.5 ],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			anchorOrigin: 'top-left',
			opacity: 0.75,
			scale: 1.0,
			src: 'img/bullet-pink.svg'
		}),
		zIndex: 10
	});
	
	this.m_oIconStyleMe = new ol.style.Style({
		image: new ol.style.Icon({
			anchor: [ 0.5, 0.5 ],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			anchorOrigin: 'top-left',
			opacity: 0.75,
			scale: 1.0,
			src: 'img/bullet-dark-blue.svg'
		}),
		zIndex: 10
	});

	this.m_oTextStyleMe = new ol.style.Style({
		text: new ol.style.Text({
			text: "Meg",
			font: 'bold 10px Times New Roman',
			offsetY: 0,
			offsetX: 0,
			fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
			stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
		}),
		zIndex: 10
	});
	
	//
	// When click on the map.
	this.mapClick = (evt) => 
	{
		let feature = this.m_oMap.forEachFeatureAtPixel(evt.pixel,
			function (feature, layer) {
				return feature;
			}
		);

		if (feature)
		{
			let isIcon = feature.get("isicon"); // Check if it is a icon.
			if (isIcon)
			{
				let iMainObjectId = feature.get("objectid");
				let sStatus = feature.get("status"); // Red, Green, Blue, Orange, Ring, Ring_multi
				let sName = feature.get("name");
				
				g_oWebViewInterface.emit("onClickMap", { objectid: iMainObjectId, status: sStatus, name: sName });
				
				clearAreaNameTimeout();
			}
			else // If not area or other stuff
			{
				let sName = feature.get("name");
				
				clearAreaNameTimeout();
				
				g_overlayAreaName.setPosition(evt.coordinate);
				$("#areaname").html('<div style="height:relative; padding-left:10px; padding-right:10px; padding-top:5px; padding-bottom:5px; background-color: #A8C1BF; opacity:0.7; border: 2px solid #5a827f;">'+
					sName+'</div>');
				$("#areaname").css("display", "block");
				//document.body.style.cursor = feature ? 'pointer' : '';

				g_timeoutAreaName = window.setTimeout(timeoutAreaName, 2000);
			}
		}
		else // Outside a feature.
		{
			clearAreaNameTimeout();
		}
	};
	
	this.getFleetInterval = () =>
	{
		return (this.m_iUpdateFleetInterval);
	};

	//
	// Return the iconstyle
	this.getIconStyle = (iObjectTypeId, sValueType, sServicevalue, iconScale, iRotation, sContinues, sStatus, iObjectType) =>
	{
		let sFlagIcon = "";

		if (sContinues === 'T')
		{
			switch (sStatus)
			{
				case OBJECT_STATUS_GREEN: // Green flag.
					switch (iObjectTypeId)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = 'img/greenflag_house_cont.svg';
							break;
							
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = 'img/greenflag_apartement_cont.svg';
							break;
							
						case OBJECT_TYPE_PARKING:
							sFlagIcon = 'img/greenflag_parking_cont.svg';
							break;
							
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = 'img/greenflag_parking_cont.svg';
							break;
							
						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'greenflag_cont.svg', 'greenflag_cont.svg', 'greenflag2_cont.svg', 'greenflag3_cont.svg', 'greenflag4_cont.svg', 'greenflag5_cont.svg', 'greenflag6_cont.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else
							{
								sFlagIcon = 'img/greenflag_cont.svg'; // Green
							}
							break;
					}
					break;

				case OBJECT_STATUS_BLUE: // Blue flag.
					switch (iObjectTypeId)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = 'img/glueflag_house_cont.svg';
							break;
							
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = 'img/blueflag_apartement_cont.svg';
							break;
							
						case OBJECT_TYPE_PARKING:
							sFlagIcon = 'img/blueflag_parking_cont.svg';
							break;
							
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = 'img/blueflag_parking_cont.svg';
							break;
							
						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'blueflag_cont.svg', 'blueflag_cont.svg', 'blueflag2_cont.svg', 'blueflag3_cont.svg', 'blueflag4_cont.svg', 'blueflag5_cont.svg', 'blueflag6_cont.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else
							{
								sFlagIcon = 'img/blueflag_cont.svg'; // Blue
							}
							break;
					}
					break;

				default:
					switch (iObjectTypeId)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = 'img/redflag_house_cont.svg';
							break;
							
						case OBJECT_TYPE_APARTMENT:
							break; // Do not show anything.
							
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = 'img/redflag_apartment_cont.svg';
							break;
							
						case OBJECT_TYPE_PARKING:
							sFlagIcon = 'img/redflag_parking_cont.svg';
							break;
							
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = 'img/greenflag_parking_cont.svg';
							break;
							
						default: // Cottage
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'redflag_cont.svg', 'redflag_cont.svg', 'redflag2_cont.svg', 'redflag3_cont.svg', 'redflag4_cont.svg', 'redflag5_cont.svg', 'redflag6_cont.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 3)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else
							{
								sFlagIcon = "img/redflag_cont.svg";
							}
							break;
					}
					break;
			}
		}
		else // Normal.
		{
			switch (sStatus)
			{
				case OBJECT_STATUS_RED:
					switch (iObjectType)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = "img/redflag_house.svg";
							break;

						case OBJECT_TYPE_APARTMENT:
							break; // Apartment should not be marked.
							
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = "img/redflag_apartment.svg";
							break;

						case OBJECT_TYPE_PARKING:
							sFlagIcon = "img/redflag_parking.svg";
							break;
							
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = 'img/redflag_no_road.svg';
							break;

						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'redflag.svg', 'redflag.svg', 'redflag2.svg', 'redflag3.svg', 'redflag4.svg', 'redflag5.svg', 'redflag6.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else // Other than PARKING.
							{
								sFlagIcon = "img/redflag.svg"; // Red
							}
							break;
					}
					break;

				case OBJECT_STATUS_ORANGE:
					switch (iObjectType)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = "img/orangeflag_house.svg";
							break;

						case OBJECT_TYPE_APARTMENT:
							break; // Do not show anything.
							
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = "img/orangeflag_apartment.svg";
							break;

						case OBJECT_TYPE_PARKING:
							sFlagIcon = "img/orangeflag_parking.svg";
							break;

						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = 'img/orangeflag_no_road.svg';
							break;

						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'orange.svg', 'orange.svg', 'orange2.svg', 'orange3.svg', 'orange4.svg', 'orange5.svg', 'orange6.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else // Other than parking.
							{
								sFlagIcon = 'img/orange.svg'; // Orange
							}
							break;
					}
					break;

				case OBJECT_STATUS_GREEN:
					switch (iObjectType)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = "img/greenflag_house.svg";
							break;

						case OBJECT_TYPE_APARTMENT:
							break; // Do not show anyting.
						
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = "img/greenflag_apartment.svg";
							break;

						case OBJECT_TYPE_PARKING:
							sFlagIcon = "img/greenflag_parking.svg";
							break;
					
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = "img/greenflag_no_road.svg";
							break;

						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'greenflag.svg', 'greenflag.svg', 'greenflag2.svg', 'greenflag3.svg', 'greenflag4.svg', 'greenflag5.svg', 'greenflag6.svg' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else
							{
								sFlagIcon = 'img/greenflag.svg'; // Green
							}
							break;
					}
					break;

				case OBJECT_STATUS_BLUE:
					switch (iObjectType)
					{
						case OBJECT_TYPE_HOUSE:
							sFlagIcon = "img/blueflag_house.svg";
							break;

						case OBJECT_TYPE_APARTMENT:
							break; // Do not show anyting.
						
						case OBJECT_TYPE_APARTMENT_BUILDING:
							sFlagIcon = "img/blueflag_apartment.svg";
							break;

						case OBJECT_TYPE_PARKING:
							sFlagIcon = "img/blueflag_parking.svg";
							break;
					
						case OBJECT_TYPE_COTTAGE_NO_ROAD:
							sFlagIcon = "img/blueflag_no_road.svg";
							break;

						default:
							if (sValueType===VALUETYPE_PARKING)
							{
								let aFlagIcons = [ 'blueflag.svg', 'blueflag.svg', 'blueflag2.svg', 'blueflag3.svg', 'blueflag4.svg', 'blueflag5.svg', 'blueflag6.svt' ];

								let iNumParkings = parseInt(sServicevalue);
								if (iNumParkings > 0 && iNumParkings <= 6)
									sFlagIcon = "img/"+aFlagIcons[parseInt(sServicevalue)];
								else
									sFlagIcon = "img/"+aFlagIcons[0];
							}
							else
							{
								sFlagIcon = 'img/blueflag.svg'; // Blue
							}
							break;
					}
					break;

				default:
					sFlagIcon = 'img/flag-red-nono.svg';
					break;
			}
		}
		let oIcon = new ol.style.Icon({
			anchor: [0, 35],
			anchorXUnits: 'fraction',
			anchorYUnits: 'pixels',
			opacity: 0.9,
			scale: iconScale,
			rotation: iRotation,
			src: sFlagIcon
		});

		let iconStyle = new ol.style.Style({
			image: oIcon,
			zIndex: 1
		});
		return (iconStyle);
	};
	
	this.create_textstyle_colorblind = (charToShow) =>
	{
		let textStyle = null;
		let iOffsetY = 0;
		let iOffsetX = 0;
		let iFontSize = 0;
		
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL: // Not using extra icons.
				break;

			case ICON_SIZE_NORMAL:
				iOffsetY = -17;
				iOffsetX = 27;
				iFontSize = 16;
				break;

			case ICON_SIZE_LARGE:
				iOffsetY = -21;
				iOffsetX = 40;
				iFontSize = 16;
				break;

			case ICON_SIZE_HUGE:
				iOffsetY = -30;
				iOffsetX = 53;
				iFontSize = 16;
				break;
		}

		if (iFontSize>0)
		{
			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: charToShow, // Warning icon.
					font: 'bold '+iFontSize+'px Verdana',
					offsetY: iOffsetY,
					offsetX: iOffsetX,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)' }),
					stroke: new ol.style.Stroke({ color: 'rgb(245,245,245)', width: 2 })
				}),
				zIndex: 2
			});
		}
		return (textStyle);
	};
	
	this.create_textstyle_houseno = (sHouseNo) =>
	{
		let iFontSize = 0;
		let iOffsetY = 6;
		let oTextStyle = null;
		
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL: // Not using extra icons.
				iOffsetY = 6;
				iFontSize = 9;
				break;

			case ICON_SIZE_NORMAL:
				iOffsetY = 6;
				iFontSize = 14;
				break;

			case ICON_SIZE_LARGE:
				iOffsetY = 6;
				iFontSize = 18;
				break;

			case ICON_SIZE_HUGE:
				iOffsetY = 6;
				iFontSize = 20;
				break;
		}
		
		if (iFontSize > 0)
		{
			oTextStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: sHouseNo+"",
					font: iFontSize+'px sans-serif',
					offsetY: iOffsetY,
					offsetX: 0,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)' }), // Black color.
					stroke: new ol.style.Stroke({ color: 'rgb(0,0,0)', width: 1 })
				}),
				zIndex: 10
			});
		}
		return (oTextStyle);
	};

	this.create_textstyle_arrival = (sArrivalTime) =>
	{
		let textCh = "";
		let textStyle = null;
		let iOffsetY = 0;
		let iOffsetX = 0;
		let iFontSize = 0;

		switch (sArrivalTime)
		{
			case ARRIVAL_TIME_MORNING:
			case ARRIVAL_TIME_MORNING_EARLY:
				textCh = "1";
				break;

			case ARRIVAL_TIME_AFTERNOON:
				textCh = "2";
				break;

			case ARRIVAL_TIME_EVNING:
				textCh = "3";
				break;

			case ARRIVAL_TIME_NIGHT:
				textCh = "4";
				break;

			default:
				textCh = "A";
				break;
		}
		
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL: // Not using extra icons.
				break;

			case ICON_SIZE_NORMAL:
				iOffsetY = -17;
				iOffsetX = 2;
				iFontSize = 11;
				break;

			case ICON_SIZE_LARGE:
				iOffsetY = -21;
				iOffsetX = 2;
				iFontSize = 14;
				break;

			case ICON_SIZE_HUGE:
				iOffsetY = -30;
				iOffsetX = 2;
				iFontSize = 16;
				break;
		}
		
		if (iFontSize > 0)
		{
			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: textCh,
					font: 'bold '+iFontSize+'px Times New Roman',
					offsetY: iOffsetY,
					offsetX: iOffsetX,
					fill: new ol.style.Fill({ color: 'rgb(255,255,255)' }),
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
				}),
				zIndex: 2
			});
		}
		return (textStyle);
	};

	this.create_textstyle_multi = () =>
	{
		let textStyleMulti = 0;
		
		if (this.m_iZoom >= 16)
		{
			let iFontSize = 18;
			let iOffsetY = -5;
		
			textStyleMulti = new ol.style.Style({
				text: new ol.style.Text({
					text: "\uf0c0", // Users icon.
					font: 'normal '+iFontSize+'px FontAwesome',
					offsetY: iOffsetY,
					offsetX: 0,
					fill: new ol.style.Fill({ color: 'rgb(0,100,0)' }), // Allways marked as valid contract.
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
				}),
				zIndex: 2
			});
		}
		return (textStyleMulti);
	};

	//
	// The textstyle warning.
	this.create_textstyle_warning = (iWarningOffset) =>
	{
		let textStyle = null;
		let iOffsetY = iWarningOffset;
		let iOffsetX = 0;
		let iFontSize = 0;
		
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL: // Not using extra icons.
				break;

			case ICON_SIZE_NORMAL:
				iFontSize = 18;
				break;

			case ICON_SIZE_LARGE:
				iFontSize = 18;
				break;

			case ICON_SIZE_HUGE:
				iFontSize = 20;
				break;
		}
		
		if (iFontSize > 0)
		{
			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: "\uf071", // Warning icon.
					font: 'normal '+iFontSize+'px FontAwesome',
					offsetY: iOffsetY,
					offsetX: iOffsetX,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
				}),
				zIndex: 2
			});
		}
		return (textStyle);
	};
	
	this.create_textstyle_dateto = (sDate) =>
	{
		let textStyle = null;
		let sDispDate = "";
		let iOffsetY = 0;
		let iOffsetX = 0;
		let iFontSize = 0;
		
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL: // Not using extra icons.
				break;

			case ICON_SIZE_NORMAL:
				iOffsetY = -39;
				iOffsetX = 20;
				iFontSize = 12;
				break;

			case ICON_SIZE_LARGE:
				iOffsetY = -56;
				iOffsetX = 25;
				iFontSize = 16;
				break;

			case ICON_SIZE_HUGE:
				iOffsetY = -75;
				iOffsetX = 30;
				iFontSize = 18;
				break;
		}
		
		if (sDate && iFontSize>0)
		{
			sDispDate = nss_sqldate2dispdate_short(sDate);
		
			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: sDispDate,
					font: 'bold '+iFontSize+'px Times New Roman',
					offsetY: iOffsetY,
					offsetX: iOffsetX,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
				}),
				zIndex: 2
			});
		}
		return (textStyle);
	};
	
	//
	// Type:
	// 1 - Ring with 
	this.warning_offset = (iType) =>
	{
		let aOffset = [
			[ -10, -20, -5 ], // Small
			[ -20, -35,  5 ], // Normal
			[ -30, -50, 10 ], // Large
			[ -40, -65, 15 ]  // Huge
		];
		let iWarningOffset = 0;
		switch (this.m_iFlagSize)
		{
			case ICON_SIZE_SMALL:
				iWarningOffset = aOffset[0][iType];
				break;
				
			case ICON_SIZE_NORMAL:
				iWarningOffset = aOffset[1][iType];
				break;
				
			case ICON_SIZE_LARGE:
				iWarningOffset = aOffset[2][iType];
				break;
				
			case ICON_SIZE_HUGE:
				iWarningOffset = aOffset[3][iType];
				break;
		}
		return (iWarningOffset);
	};
	
	this.create_iconstyle = (sImage) =>
	{
		let iconStyle = new ol.style.Style({
			image: new ol.style.Icon({
				anchor: [0.5, 35],
				anchorXUnits: 'fraction',
				anchorYUnits: 'pixels',
				opacity: 0.9,
				scale: this.m_iFlagSize,
				rotation: 0,
				src: sImage
			}),
			zIndex: 1
		});
		return (iconStyle);
	};
	
	this.createMapFeature = (iObjectId, oObject) =>
	{
		let iconFeature = null;
		let bSkip = false;
		let sArrivalTime = ""; // Default value.
		let iconScale = this.m_iFlagSize;
		let iRotation = 0; //(iNumOrders * 0.3) - 0.3;
		
		if (parseFloat(oObject.ln) <= 0 && parseFloat(oObject.lt) <= 0)
			return (false); // continue.

		switch (oObject.st)
		{
			case OBJECT_STATUS_RED: // Red flag.
			case OBJECT_STATUS_GREEN: // Green flag.
			case OBJECT_STATUS_BLUE: // Blue flag.
			case OBJECT_STATUS_ORANGE: // Orange flag.
				iconFeature = new ol.Feature({
					objectid: parseInt(oObject.oi),
					name: oObject.on, // The object address
					geometry: new ol.geom.Point(ol.proj.fromLonLat([ parseFloat(oObject.ln), parseFloat(oObject.lt) ])),
					status: oObject.st, // status
					validcont: oObject.vc,
					continues: oObject.co,
					isicon: true,
					isorder: true
				});
				break;
				
			case OBJECT_STATUS_RING: // No order, create a ring.
			case OBJECT_STATUS_RING_MULTI: // Multi.
			case OBJECT_STATUS_RING_EXTRA:
			case OBJECT_STATUS_RING_ORANGE:
				iconFeature = new ol.Feature({
					objectid: parseInt(oObject.oi),
					name: oObject.on, // The object addresshytte.
					geometry: new ol.geom.Point(ol.proj.fromLonLat([ parseFloat(oObject.ln), parseFloat(oObject.lt) ])),
					status: oObject.st, // status
					validcont: oObject.vc,
					continues: oObject.co,
					isicon: true,
					isorder: false
				});
				break;

			default: // Just skip.
				bSkip = true;
				break;
		}

		// Skip to the next record.
		if (bSkip) // Skip to next.
			return (false); // continue.

		let iconStyle = null;
		let iWarningOffset = this.warning_offset(WARNING_OFFSET_FLAG);
		let bIsFlag = false;
		
		if (oObject.co==='T') // Continues.
		{
			iconStyle = this.getIconStyle(oObject.ot, oObject.vt, oObject.sv, iconScale, iRotation, oObject.co, oObject.st, oObject.ot);
		}
		else
		{
			let sImage = null;
			let iMinOld = parseInt(oObject.mo); // Minutes old.
			
			// Create the flags.
			switch (oObject.st)
			{
				case OBJECT_STATUS_RING: // No order, create a ring.
					iWarningOffset = this.warning_offset(WARNING_OFFSET_RING);
					sImage = (oObject.vc==='T') ? "img/cottage_green.svg" : nss_red_ring(this.m_bColorBlind);
					iconStyle = this.create_iconstyle(sImage);
					break;

				case OBJECT_STATUS_RING_MULTI:
					iWarningOffset = this.warning_offset(WARNING_OFFSET_RING);
					sImage = (oObject.vc==='T') ? "img/cottage_grey.svg" : "img/cottage_grey.svg";
					iconStyle = this.create_iconstyle(sImage);
					break;
					
				case OBJECT_STATUS_RING_ORANGE:
					iWarningOffset = this.warning_offset(WARNING_OFFSET_RING);
					sImage = "img/cottage_orange.svg";
					iconStyle = this.create_iconstyle(sImage);
					break;
					break;

				case OBJECT_STATUS_RING_EXTRA:
					iWarningOffset = this.warning_offset(WARNING_OFFSET_EXTRA);
					if (oObject.vc === 'T') // Valid contract.
					{
						if (iMinOld>{{@one_week_in_minutes}}) // One week or more.
						{
							sImage = "img/cottage_green.svg"; // Show the normal flag.
						}
						else if (iMinOld>{{@24_hours_in_minutes}}) // 24 hours
						{
							sImage = "img/cottage_grey_flag.svg"; // Show green flag, less than 24 hours.
						}
						else
						{
							sImage = "img/cottage_green_flag.svg";
						}
					}
					else
					{
						sImage = nss_red_ring(this.m_bColorBlind);
					}						
					iconStyle = this.create_iconstyle(sImage);
					break;

				case OBJECT_STATUS_RED: // Red flag.
				case OBJECT_STATUS_GREEN: // Green flag.
				case OBJECT_STATUS_BLUE: // Blue flag.
				case OBJECT_STATUS_ORANGE: // Orange flags.
					bIsFlag = true;
					iconStyle = this.getIconStyle(oObject.ot, oObject.vt, oObject.sv, iconScale, iRotation, oObject.co, oObject.st, oObject.ot);
					break;

				default: // Just skip.
					break;
			}
		}

		if (iconStyle && iconFeature)
		{
			let aStyleList = [];

			switch (this.m_sServiceTag)
			{
				case SERVICETAG_SNOWPLOW_SEASON: // Defined in nss_constants.js
				case SERVICETAG_SNOWPLOW_ONETIME:

					aStyleList.push(iconStyle); // Add the icon style.
					sArrivalTime = (this.m_bArrivalTime) ? oObject.at : ""; // Arrival time, if it is not arrival day this is empty.
					
					// If arrival time set the arrival time as a number on the flag 1-Morning, 2-Afternoon, 3-Eavning, 4-Night, A-Arrival.
					switch (oObject.st)
					{
						case OBJECT_STATUS_GREEN:
						case OBJECT_STATUS_BLUE:
						case OBJECT_STATUS_ORANGE:
						case OBJECT_STATUS_RED:
							// Add textstyle if the arrival time has got a length.
							if (sArrivalTime.length>0)
							{
								let textStyle = (this.m_bArrivalTime) ? this.create_textstyle_arrival(sArrivalTime) : this.create_textstyle_arrival("A");
								if (textStyle)
									aStyleList.push(textStyle);
							}
							break;

						case OBJECT_STATUS_RING_MULTI:
							let textStyleMulti = this.create_textstyle_multi();
							if (textStyleMulti)
								aStyleList.push(textStyleMulti); // Add the multi text icon.
							break;
							
						default: // No extra text styles.
							break;
					}

					//
					// If colorblind add extra tag.
					if (this.m_bColorBlind)
					{
						let ch = "";
						switch (oObject.st)
						{
							case OBJECT_STATUS_ORANGE:
								ch = "O";
								break;

							case OBJECT_STATUS_RED:
								ch = "R";
								break;
								
							case OBJECT_STATUS_GREEN:
								ch = "G";
								break;

							case OBJECT_STATUS_BLUE:
								ch = "B";
								break;
						}
						if (ch.length > 0)
						{
							let textStyle = this.create_textstyle_colorblind(ch);
							if (textStyle)
								aStyleList.push(textStyle);
						}
					}
					const keys = Object.keys(oObject);

					// Not continues.
					if (oObject.dt && bIsFlag && this.m_bShowDateAboveFlag && oObject.co!=='T')
					{
						let textStyle = this.create_textstyle_dateto(oObject.dt);
						if (textStyle)
							aStyleList.push(textStyle);
					}						

					if (oObject.im==='T') // Is message.
					{
						let textStyle = this.create_textstyle_warning(iWarningOffset);
						if (textStyle)
							aStyleList.push(textStyle);
					}
					if (this.m_bMapHouseNo)
					{
						let iHouseNo = parseInt(oObject.hn);
						let textStyle = this.create_textstyle_houseno(iHouseNo);
						if (textStyle)
							aStyleList.push(textStyle);
					}
					iconFeature.setStyle(aStyleList); // Set the style.
					break;

				default:
					aStyleList.push(iconStyle); // Add the icon style.

					//
					// If colorblind add extra tag.
					if (this.m_bColorBlind)
					{
						let ch = "";
						switch (oObject.st)
						{
							case OBJECT_STATUS_ORANGE:
								ch = "O";
								break;

							case OBJECT_STATUS_RED:
								ch = "R";
								break;
								
							case OBJECT_STATUS_GREEN:
								ch = "G";
								break;

							case OBJECT_STATUS_BLUE:
								ch = "B";
								break;
						}
						if (ch.length > 0)
						{
							let textStyle = this.create_textstyle_colorblind(ch);
							if (textStyle)
								aStyleList.push(textStyle);
						}
					}
					if (oObject.im==='T') // Is message.
					{
						let textStyle = this.create_textstyle_warning(iWarningOffset);
						if (textStyle)
							aStyleList.push(textStyle);
					}
					if (this.m_bMapHouseNo)
					{
						let iHouseNo = parseInt(oObject.hn);
						let textStyle = this.create_textstyle_houseno(iHouseNo);
						if (textStyle)
							aStyleList.push(textStyle);
					}
					iconFeature.setStyle(aStyleList); // Set the style.
					break;
			}
		}
		return (iconFeature);
	};
	
	//
	// Swaps the feature from the featurelist.
	this.swapFeature = (aObjectIdList, sOrderStatus, bExtraData, oExtraData) =>
	{
		let aFeatureList = this.m_vectorFlagSource.getFeatures();
		
		for (let i=0; i<aObjectIdList.length; i++)
		{
			// Make the objectId numeric.
			let iObjectId = parseInt(aObjectIdList[i]);
			
			aFeatureList.forEach((oFeature) => {
				let iObjectFeatureId = parseInt(oFeature.get("objectid"));
				let bLateOrder = false;

				if (iObjectFeatureId===iObjectId)
				{
					// First update the object data with new status.
					if (bExtraData)
					{
						//if (this.m_aFlags[iObjectId].im==='F')
						//	this.m_aFlags[iObjectId].im = (oExtraData.bMessage)?'T':'F'; // This message is not cottage message.
						this.m_aFlags[iObjectId].lo = (oExtraData.bLateOrder)?'T':'F';
						this.m_aFlags[iObjectId].vt = oExtraData.sValueType;
						this.m_aFlags[iObjectId].sv = oExtraData.sServiceValue;
						this.m_aFlags[iObjectId].at = oExtraData.sArrivalTime;
						this.m_aFlags[iObjectId].co = oExtraData.sContinues;
						bLateOrder = oExtraData.bLateOrder;
					}

					let iObjectStatus = OBJECT_STATUS_RING;

					switch (sOrderStatus)
					{
						case ORDER_STATUS_FINISHED: // Defined in nss_constants.
							iObjectStatus = OBJECT_STATUS_GREEN;
							break;
							
						case ORDER_STATUS_FINISHED_NOT:
							iObjectStatus = OBJECT_STATUS_BLUE;
							break;

						case ORDER_STATUS_ORDERED:
						case ORDER_STATUS_REORDERED:
						case ORDER_STATUS_REORDERED_NO_SMS:
							iObjectStatus = (bLateOrder) ? OBJECT_STATUS_ORANGE : OBJECT_STATUS_RED; //this.m_aFlags[iObjectId].st; // The object status.
							break;
							
						default:
							switch (this.m_aFlags[iObjectId].ot)
							{
								case OBJECT_TYPE_APARTMENT_BUILDING:
								case OBJECT_TYPE_PARKING:
									iObjectStatus = (sOrderStatus===ORDER_STATUS_FINISHED_EXTRA) ? OBJECT_STATUS_RING_EXTRA : OBJECT_STATUS_RING_MULTI;
									break;

								case OBJECT_TYPE_HOUSE:
								case OBJECT_TYPE_COTTAGE:
								case OBJECT_TYPE_COTTAGE_NO_ROAD:
								case OBJECT_TYPE_APARTMENT:
								default:
									iObjectStatus = (sOrderStatus===ORDER_STATUS_FINISHED_EXTRA) ? OBJECT_STATUS_RING_EXTRA : OBJECT_STATUS_RING;
									break;
							}
							break;
					}
					this.m_aFlags[iObjectId].st = iObjectStatus;

					// Remove the feature
					let iFeatureId = oFeature.getId();
					this.m_vectorFlagSource.removeFeature(oFeature);

					// Create the new map feature.
					let iconFeature = this.createMapFeature(iObjectId, this.m_aFlags[iObjectId]);
					if (iconFeature!==false)
					{
						// Set the feature id, so i do net get any conflict.
						iconFeature.setId(iFeatureId);

						// Add the new feature.
						this.m_vectorFlagSource.addFeature(iconFeature);
					}
					return; // Get out of the loop.
				}
			});
		}
	};
	
	this.updateFlagLayer = (aObjectList) =>
	{
		try
		{
			let aFeatureList = this.m_vectorFlagSource.getFeatures();

			$.each(aObjectList, (iObjectId, oObject) => {
				
				iObjectId = parseInt(iObjectId);
			
				aFeatureList.forEach((oFeature) => {
					let iObjectFeatureId = parseInt(oFeature.get("objectid"));

					if (iObjectFeatureId===iObjectId)
					{
						// First update the object data with new status.
						//if (this.m_aFlags[iObjectId].im==='F')
						//	this.m_aFlags[iObjectId].im = oObject.im;
						this.m_aFlags[iObjectId].lo = oObject.lo;
						this.m_aFlags[iObjectId].vt = oObject.vt;
						this.m_aFlags[iObjectId].sv = oObject.sv;
						this.m_aFlags[iObjectId].at = oObject.at;
						this.m_aFlags[iObjectId].co = oObject.co;
						this.m_aFlags[iObjectId].st = oObject.st;
						
						// Remove the feature
						let iFeatureId = oFeature.getId();
						this.m_vectorFlagSource.removeFeature(oFeature);

						// Create the new map feature.
						let iconFeature = this.createMapFeature(iObjectId, this.m_aFlags[iObjectId]);
						if (iconFeature!==false)
						{
							// Set the feature id, so i do net get any conflict.
							iconFeature.setId(iFeatureId);

							// Add the new feature.
							this.m_vectorFlagSource.addFeature(iconFeature);
						}
						return (true); // Get out of the inner loop. forEach(feature)
					}
				});
			});
		}
		catch (err)
		{
			console.log("ERROR: "+err.message);
		}
		return;
	};
	
	//
	// Create the flag layer.
	this.createFlagLayer = (aObjectList) =>
	{
	console.log("this.createFlagLayer-START-aObjectList: ", aObjectList.length);
		// Clear the vecor layer.
		this.m_vectorFlagSource.clear(true);

		// New array
		let iconFeatureList = []; // Empty the list.

		try
		{
			let i=0;
			// Loop through all the objects.
			$.each(aObjectList, (iObjectId, oObject) =>
			{
				let iconFeature = this.createMapFeature(iObjectId, oObject);
				if (iconFeature!==false)
				{
					iconFeature.setId(i);

					// Update the list.
					iconFeatureList.push(iconFeature);
					i++;
				}
			});
			// Pull all the flags onto the map.
		this.m_vectorFlagSource.addFeatures(iconFeatureList);
		console.log("this.createFlagLayer- m_oFlagLayerSource-Features-length: ",this.m_vectorFlagSource.getFeatures().length);	

			this.clusterForVectorFlagSource = new ol.source.Cluster({
				name:"clusterForVectorFlagSource",
				distance:50,
				
				//minDistance:parseInt(20,10),
				source:this.m_vectorFlagSource,
				//source:this.m_oFlagLayer.getSource(),
			/*	geometryFunction: function(feature) {
					if (this.m_oMap.getView().getZoom() < 16){
						return null;
					}else{
				
					return feature.getGeometry();
						
					}
					
				} , */ 
				
			})
			console.log("this.createFlagLayer -  this.clusterForVectorFlagSource.LENGTH: ");
			console.log("this.createFlagLayer -  this.clusterForVectorFlagSource.LENGTH: ",this.clusterForVectorFlagSource.getSource().getFeatures().length);

			const styleCache = {};
		
			console.log("this.clusterForVectorFlagSource-RIGHT BEFORE-CLUSTERFLAGLAYER-CREATE:");
			console.log(this.clusterForVectorFlagSource?.getSource()?.getFeatures()?.length);
			
			this.clusterFlagLayer = new ol.layer.Vector({ // Layer for the flags.
					name:"clusterFlagLayer",
					minResolution:3,
					source: this.clusterForVectorFlagSource , 
				//	style: clusterStyle
				style: function (feature) {
					const size = feature.get('features').length;
					let style = styleCache[size];
					if (!style) {
					style = new ol.style.Style({
						image: new ol.style.Circle({
						radius: 10,
						stroke: new ol.style.Stroke({
							color: '#fff',
						}),
						fill: new ol.style.Fill({
							color: '#3399CC',
						}),
						}),
						text: new ol.style.Text({
						text: size.toString(),
						fill: new ol.style.Fill({
							color: '#fff',
						}),
						}),
					});
					styleCache[size] = style;
					}
					return style;
				},
				});

			
				console.log("LAYERSCOUNTRIGHTBEFORE-ADD-CLUSTER: ",this.m_oMap.getAllLayers().length);

				this.m_oMap.getView().un('change:resolution', this.onChangeZoomLevel );

				if(this.clusterForVectorFlagSource.getSource().getFeatures().length > 0){
					this.m_oMap.removeLayer(this.clusterFlagLayer);
					this.m_oMap.addLayer(this.clusterFlagLayer);
				}  
				
				this.m_oMap.getView().on('change:resolution', this.onChangeZoomLevel );
				

				console.log("LAYERSCOUNTRIGHTAFTER-ADD-CLUSTER: ",this.m_oMap.getAllLayers().length);

				function clusterStyle (clusterFeature)
				{
					if(Array.isArray(clusterFeature.get('features')))
					{
						const size = clusterFeature.get('features').length;
						let style = styleCache[size];
						var selectedFeature = clusterFeature.get('features')[0];
						if (!style) 
						{
	
						style =  new ol.style.Style({
						image: new ol.style.Circle({
						radius: 10,
						stroke: new ol.style.Stroke({
							color: '#fff',
						}),
						fill: new ol.style.Fill({
							color: '#3399CC',
						}),
						}),
						text: new ol.style.Text({
						text: size.toString(),
						fill: new ol.style.Fill({
							color: '#fff',
						}),
						}),
					});
						
						}
					}
				
				}	

				console.log("ZOOM-LEVEL: ",this.m_oMap.getView().getZoom());
				

				this.m_oMap.getAllLayers().forEach(layer=>{
				if(layer.get("name") == "clusterFlagLayer"){
						console.log("clusterFlagLayerName: ", layer.get("name"));
					console.log("CLUSTERFLAGLAYER-features-number: ",layer?.getSource()?.getSource()?.getFeatures()?.length)
					}
				})	

				//this.createFlagLayer invoke edilip bu satira geldikten sonra this.creaetMap icinde nereyi calistiriyor kendisinden sonra ki zoom-level eventini icerisiinde zoom-level lara gore conditionlar olan kismi cslistiriyor
				
				//clusterLayer i map e burda ekleyelim once map i test edelim.. 
			//	console.log("clusterFlagLayer-NAME; ",this.clusterFlagLayer.get("name"));
			//	console.log("clusterFlagLayer-features-count: ", this.clusterFlagLayer.getSource()?.getSource()?.getFeatures()?.length)
			
		}
		catch (e)
		{
			console.log("ERROR: "+e.message);
			return (false);
		}
		return (true);
	};

	//
	// Create the map.
	this.createMap = (crd, sName) =>
	{
	console.log("this.createMap-START: ");
		//let point = new ol.proj.transform([parseFloat(crd.longitude), parseFloat(crd.latitude)], 'EPSG:4326', 'EPSG:3857');
		let point = ol.proj.fromLonLat([parseFloat(crd.longitude), parseFloat(crd.latitude)]);
		let aFeatureList = [];

		// Create a style.
		this.m_defaultStyle = new ol.style.Style({
			stroke: new ol.style.Stroke({
				color: '#AAAAAA',
				width: 2
			}),
			fill: new ol.style.Fill({
				color: [10, 10, 10, 0.1]
			})
		});

		// Create array of all the features / polygons.
		for (let i=0; i<this.m_aServiceAreas.length; i++)
		{
			if (i === 0)
			{
				// Set the first area as selected.
				this.m_iSelectedAreaId = this.m_aServiceAreas[i].id;
			}
			// Create a feature of the polygon
			// Get the are as json and convert to an array.
			let polyCoords = JSON.parse(this.m_aServiceAreas[i].area_json);

			let oFeature = new ol.Feature({
				geometry: new ol.geom.Polygon(polyCoords),
				id: this.m_aServiceAreas[i].id,
				name: this.m_aServiceAreas[i].area_name
			});

			// Set the style for the feature.
			oFeature.setStyle(this.m_defaultStyle);

			aFeatureList.push(oFeature);

			this.m_aPolygonList.push({
				id: this.m_aServiceAreas[i].id,
				name: this.m_aServiceAreas[i].area_name,
				polygon: this.m_aServiceAreas[i].area_json,
				feature: oFeature
			});
		}
		let polygonSource = new ol.source.Vector({
			features: aFeatureList
		});

		this.m_oView = new ol.View({
			//projection: 'EPSG:3857',
			center: point,
			zoom: this.m_iZoom,
			maxZoom: 20,
			rotation: 0
		});
		 
		// Create an empty vector for all the flags.
		this.m_oMapLayer = new ol.layer.Tile({
			source: g_classMapSelect.map_select(this.m_sMapTypeSelected),
			preload: 3
		});
		
		this.m_oAreaLayer = new ol.layer.Vector({
			source: polygonSource, // Layer for the areas
			maxResolution: 20
		});
		
		this.m_oFlagLayer = new ol.layer.Vector({ // Layer for the flags.
			name:"m_oFlagLayer",
			source: this.m_vectorFlagSource,
		//	source: this.clusterForVectorFlagSource , 
			maxResolution: 4,
		//	style: clusterStyle
		}); 

		console.log("this.createMap - flaglayerfeatures-count: ", this.m_vectorFlagSource.getFeatures().length);
		

		this.m_oMyPosLayer =	new ol.layer.Vector({ // Layer for the position.
			source: this.m_vectorPositonSource,
			maxResolution: 20
		});

		this.m_oLayerFromMapLayerModule = new ol.layer.Vector({ 
		// layer from MapLayer module
			source: sourceFromMapLayer,
		});
		

		g_overlayAreaName = new ol.Overlay({
			element: document.getElementById('areaname'),
			positioning: 'bottom-left'
		});

		console.log("this.createMap-rightBeforeAdding this.m_oFlagLayer in Map:");
//		console.log("this.createMap-rightBeforeAdding this.m_oFlagLayer in Map: ",this.m_oFlagLayer.getSource().getFeatures().length);
		// Set the global map at the same time, to use in static functions.
		this.m_oMap = new ol.Map({
			layers: [ this.m_oMapLayer, this.m_oAreaLayer, this.m_oFlagLayer, this.m_oMyPosLayer, this.m_oLayerFromMapLayerModule ],
			target: document.getElementById('map'),
			controls: ol.control.defaults({
				attributionOptions: /** @type { olx.control.AttributionOptions} */ ({
					collapsible: false
				})
			}),
			view: this.m_oView
		});
	console.log("getFlagLayerName: ");
	

	this.m_oMap.getAllLayers().forEach(layer=>{
		if(layer.get("name") == "m_oFlagLayer"){
			console.log("layerName: ", layer.get("name"));
		console.log("layer-features-number: ",layer?.getSource()?.getFeatures()?.length)
		}
	})	
	
		
		g_overlayAreaName.setMap(this.m_oMap);

		// display popup on click
		this.m_element = document.getElementById('popup');
		this.m_popup = new ol.Overlay({
			element: this.m_element,
			//positioning: 'bottom-center',
			stopEvent: false
		});

		// Where am i.
		this.m_geolocation = new ol.Geolocation({
			projection: this.m_oView.getProjection(),
			tracking: true
		});
		
		this.m_oMap.addOverlay(this.m_popup);

		this.m_oMap.on('click', this.mapClick);
		
		/*
		var multiTouchEvent = 0;
		var timeoutId;
		var waitFor = 1000;
		$(document).delegate("#map", "pagecreate", function() {
			  this.m_oMap.events.register('touchstart', this.m_oMap, function(e) {
					multiTouchEvent = e.touches.length;
					timeoutId = setTimeout(function() {
						  if (multiTouchEvent > 1) {
								 clearTimeout(timeoutId);
						  }
						  else {
								 alert("longpress!!!");
						  }
					}, waitFor);
			  }, true);

			  this.m_oMap.events.register('touchmove', map, function(e) {
					clearTimeout(timeoutId);
			  });
			  this.m_oMap.events.register('touchend', map, function(e) {
					clearTimeout(timeoutId);
			  });
		}*/		

		console.log("this.createMap - this.m_aFlags: ", this.m_aFlags.length);

		this.onChangeZoomLevel = ()=>
		{  
			this.m_iZoom = parseInt(this.m_oMap.getView().getZoom());
			console.log("onChangeZoomLevelLLLLLLLLLLLL", this.m_iZoom);
			if (this.m_iZoom >= 20)
			{
				console.log("this.m_iZoom >= 20");
				this.m_iFlagSize = ICON_SIZE_HUGE;
				this.createFlagLayer(this.m_aFlags);

			}	
			else if (this.m_iZoom >= 18 && this.m_iZoom < 20)
			{
				console.log("this.m_iZoom >= 18 && this.m_iZoom < 20");

				this.m_iFlagSize = ICON_SIZE_LARGE;
				this.createFlagLayer(this.m_aFlags);
			}
			else if (this.m_iZoom >= 16 && this.m_iZoom < 18)
			{
			console.log("this.m_iZoom >= 16 && this.m_iZoom < 18")
				this.m_iFlagSize = ICON_SIZE_NORMAL;
				this.createFlagLayer(this.m_aFlags);
			}
			else if (this.m_iZoom < 16)
			{
				console.log("this.m_iZoom < 16")
				this.m_iFlagSize = ICON_SIZE_SMALL;
				this.createFlagLayer(this.m_aFlags);
			} 
		}
		
		function debounce(func, delay) 
		{
			let timer;
			return function() 
			{
				const context = this;
				const args = arguments;
				clearTimeout(timer);
				timer = setTimeout(() => func.apply(context, args), delay);
			};
		}
								  
		const debouncedFunction = debounce(this.onChangeZoomLevel, 1000);
	   // this.createFlagLayer(this.m_aFlags);
		// Changeing resolution, change the icon size.
		this.m_oMap.getView().on('change:resolution', debouncedFunction );

		// change mouse cursor when over marker
		this.m_oMap.on('pointermove', (e) =>
		{
			console.log("pointermove-dragging-working")
			if (e.dragging) {
				//$(this.m_element).popover('destroy');
				return;
			}
			let pixel = this.m_oMap.getEventPixel(e.originalEvent);
			let hit = this.m_oMap.hasFeatureAtPixel(pixel);
			this.m_oMap.getTarget().style.cursor = hit ? 'pointer' : '';
		});
		// Set the map created flag.
		this.bMapCreated = true;
		};
	
	//
	// Return the current logposition.
	this.getLogPosition = () =>
	{
		return (this.m_iLogPos);
	};

	//
	// Change the service.
	this.changeService = (sServiceTag) =>
	{
		// Save the new service tag.
		this.m_sServiceTag = sServiceTag;
		/*
		// Remove all the flags from the flag layer.
		let aFeatureList = this.m_vectorFlagSource.getFeatures();
		
		aFeatureList.forEach((oFeature) => {
			this.m_vectorFlagSource.removeFeature(oFeature);
		});
		
		// Remove the previouse layer.
		//this.m_oMap.removeLayer(this.m_oFlagLayer);
		
		// Show the new layer.
		//this.m_oMap.addLayer(this.m_oFlagLayer);
		*/
		return (true);
	};
	
	this.setMapType = (sMapType) =>
	{
		// First destroy the current layer.
		this.m_oMap.removeLayer(this.m_oMapLayer);
		this.m_oMap.removeLayer(this.m_oAreaLayer);
		this.m_oMap.removeLayer(this.m_oFlagLayer);
		this.m_oMap.removeLayer(this.m_oMyPosLayer);
		// Change the map type.
		this.m_sMapTypeSelected = sMapType;
		
		// Create an empty vector for all the flags.
		this.m_oMapLayer = new ol.layer.Tile({
			source: g_classMapSelect.map_select(this.m_sMapTypeSelected)
		});
		this.m_oMap.addLayer(this.m_oMapLayer);
		this.m_oMap.addLayer(this.m_oAreaLayer);
		this.m_oMap.addLayer(this.m_oFlagLayer);
		this.m_oMap.addLayer(this.m_oMyPosLayer);
		
		return (true);
	};
	
	//
	// Get the timestamp.
	this.getTimeStamp = () =>
	{
		let timenow = Math.floor(Date.now() / 1000);
		return (timenow);
	};

	//
	// setMyPosition
	this.setMyPosition = (dLongitude, dLatitude, dHeadingDegrees, dSpeed) =>
	{
		if ( !this.bMapCreated)
			return (false);
		
		this.m_oMyLastPos = ol.proj.transform([parseFloat(dLongitude), parseFloat(dLatitude)], 'EPSG:4326', 'EPSG:3857');
		
		
		// Create the position feature, if not allready created.
		if (this.m_oMyPosition===null)
		{
			let point = new ol.geom.Point(this.m_oMyLastPos);
			
			this.m_oMyPosition = {
				deviceId: this.CURRENT_DEVICEID,
				longitude: dLongitude,
				latitude: dLatitude,
				timestamp: null,
				feature: null
			};
			let positionFeature = new ol.Feature({
				geometry: point
			});
			
			positionFeature.setStyle([ this.m_oIconStyleMe, this.m_oTextStyleMe ]);

			// Put the new feature into the array.
			this.m_oMyPosition.feature = positionFeature;

			// Update the timestamp in seconds.
			this.m_oMyPosition.timestamp = this.getTimeStamp();

			// Move to new position
			this.m_oMyPosition.feature.setGeometry(point);

			// Add the feature.
			this.m_vectorPositonSource.addFeature(this.m_oMyPosition.feature);
		}
		else
		{
			// Move to new position
			this.m_oMyPosition.feature.getGeometry().setCoordinates(this.m_oMyLastPos);
		}

		// If tracking mode, hold the my position in center.
		if (this.m_bTrackMode && this.m_bDeviceOrientation) // Check if view and map is created.
		{
			// Set the position at the center of the map
			this.m_oView.setCenter(this.m_oMyLastPos);

			if (dHeadingDegrees !== null)
			{
				//this.m_dLastHeadingDegrees = this.changePosition(Math.round(this.m_dLastHeadingDegrees), Math.round(dHeadingDegrees));

				// Set the compass heading in radians.
				this.m_oView.setRotation(((360 - dHeadingDegrees) * Math.PI) / 180);

				// save the last heading, not used at the moment.
				this.m_dLastHeadingDegrees = dHeadingDegrees;
			}
		}
		return (true);
	};
	
	this.calcShortDeg = (iLastHeadingDeg, iHeadingDeg) =>
	{
		let iDiff=0;

		// Clockwise
		if (iLastHeadingDeg > iHeadingDeg)
		{
			let d1 = (360-iLastHeadingDeg)+iHeadingDeg;
			let d2 = iLastHeadingDeg - iHeadingDeg;

			iDiff = Math.min(d1,d2);

		}
		else
		{
			let d1 = (360-iHeadingDeg)+iLastHeadingDeg;
			let d2 = iHeadingDeg - iLastHeadingDeg;

			iDiff = (Math.min(d1,d2) * -1);
		}
		return (Math.round(iDiff));
	};

	this.changePosition = (iLastHeadingDeg, iHeadingDeg) =>
	{
		let iDiff = this.calcShortDeg(iLastHeadingDeg, iHeadingDeg);
		let iCurrDeg = iLastHeadingDeg;
		let iBetween = 0;

		if (iDiff>0)
		{
			for (let i=0; i<iDiff; i++)
			{
				if (++iCurrDeg===360)
					iCurrDeg=0;
				if (++iBetween===2)
				{
					this.m_oView.setRotation(((360 - iCurrDeg) * Math.PI) / 180);
					iBetween=0;
				}
			}
		}
		else
		{ 
			iDiff = Math.abs(iDiff);
			for (let i=0; i<iDiff; i++)
			{
				if (--iCurrDeg===0)
					iCurrDeg=360;
				if (++iBetween===2)
				{
					this.m_oView.setRotation(((360 - iCurrDeg) * Math.PI) / 180);
					iBetween=0;
				}
			}
		}
		if (iBetween>0)
		{
			this.m_oView.setRotation(((360 - iCurrDeg) * Math.PI) / 180);
		}
		return (iHeadingDeg);
	};

	//
	// Show the area in the center og the screen.
	this.displayArea = (iAreaId) =>
	{
		let sName = "";
		
		for (let i = 0; i < this.m_aPolygonList.length; i++)
		{
			if (parseInt(this.m_aPolygonList[i].id) === parseInt(iAreaId))
			{

				// Create a style.
				let style = new ol.style.Style({
					stroke: new ol.style.Stroke({
						color: '#3300ff',
						width: 2
					}),
					fill: new ol.style.Fill({
						color: [ 90, 90, 90, 0 ]
					})
				});
				// Set the style for the feature.
				this.m_aPolygonList[i].feature.setStyle(style);

				// Create a new source with current feature.
				let vectorSource = new ol.source.Vector({
					features: [ this.m_aPolygonList[i].feature ]
				});
				let extent = vectorSource.getExtent();
				this.m_oMap.getView().fit(extent, this.m_oMap.getSize());
				
				sName = this.m_aPolygonList[i].name;
			}
			else
			{
				// Reset the style.
				this.m_aPolygonList[i].feature.setStyle(this.m_defaultStyle);
			}
		}
		return (sName);
	};
	
	//
	// Remove the search marker on the map.
	this.removeSearchMarker = () =>
	{
		if (this.m_oSearchMarker)
		{
			this.m_oMap.removeLayer(this.m_oSearchMarker);
			this.m_oSearchMarker = null;
			return (true);
		}
		return (false);
	};
	
	//
	// Handles the marker when search for an address.
	this.setSearchMarker = (lon, lat) =>
	{
		this.removeSearchMarker();
		
		if (lon > 0 && lat > 0)
		{
			// Get only the first at the moment.
			let oPos = ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857');
			this.m_oView.setCenter(oPos);

			this.m_oSearchMarker = this.createMarker(oPos);
			this.m_oMap.addLayer(this.m_oSearchMarker);
			
			return (true);
		}
		return (false);
	};
	
	//
	// Create the marker.
	this.createMarker = (oPos) =>
	{
		let iconStyle = new ol.style.Style({
			image: new ol.style.Icon({
				anchor: [0.5, -40],
				anchorXUnits: 'fraction',
				anchorYUnits: 'pixels',
				anchorOrigin: 'bottom-left',
				scale: 0.1,
				opacity: 0.75,
				src: 'img/map-marker-icon.svg'
			}),
			zIndex: 10
		});

		let iconFeature = new ol.Feature({
		  geometry: new ol.geom.Point(oPos)
		});
		
		iconFeature.setStyle(iconStyle);
		
		let vectorSource = new ol.source.Vector({
			features: [iconFeature]
		});

		let vectorLayer = new ol.layer.Vector({
			source: vectorSource
		});

		return (vectorLayer);
	};
	
	//
	// Create the position for other.
	this.createPlowerMapPosition = (iUserId, lon, lat, sDeviceId, Accuracy, sName, isMe) =>
	{
		var positionFeature = null;

		var oPosList = { deviceId: sDeviceId, UserId: parseInt(iUserId), longitude: lon, latitude: lat, accuracy: Accuracy, timestamp: this.getTimeStamp(), name: sName, feature: null };

		// Inser the item into the array and update the index.
		var ixPos = this.m_aPositionList.push(oPosList) - 1;

		if (!isMe)
		{
			// Set the icon position.
			positionFeature = new ol.Feature({
				geometry: new ol.geom.Point(ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857'))
			});

			let textStyleOther = new ol.style.Style({
				text: new ol.style.Text({
					text: sName,
					font: 'bold 10px Times New Roman',
					offsetY: 0,
					offsetX: 0,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
				}),
				zIndex: 10
			});

			positionFeature.setStyle([this.m_iconStyleOther, textStyleOther ]);

			// Put the new feature into the array.
			this.m_aPositionList[ixPos].feature = positionFeature;

			// Add the feature.
			this.m_vectorPositonSource.addFeature(this.m_aPositionList[ixPos].feature);

			// Update the timestamp.
			this.m_aPositionList[ixPos].timestamp = this.getTimeStamp();
		}
		return (ixPos);
	};
	
	//
	// Display position for other.
	this.setPlowerMapPosition = (lon, lat, sDeviceId, ixPos) =>
	{
		if (lon===0 && lat===0)
			return (false);

		// Only change if the deviceid ID mat
		// ch.
		if (this.m_aPositionList[ixPos].deviceId===sDeviceId)
		{
			// Check if we have this set from before, just update the position.
			if (this.m_aPositionList[ixPos].feature)
			{
				// Set the new geometry
				this.m_aPositionList[ixPos].feature.getGeometry().setCoordinates(ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857'));
			}
		}
		return (true);
	};
	
	//
	// Update the list with all the plowers.
	this.updatePlowerPos = (aNewPlowerList, sCurrentDeviceId) =>
	{
		for (let i=0; i<aNewPlowerList.length; i++)
		{
			let bFound = false;

			// Check if this plower exists.
			for (let ixPos=0; ixPos<this.m_aPositionList.length; ixPos++)
			{
				if (aNewPlowerList[i].did===this.m_aPositionList[ixPos].deviceId) // Deviceid is the same.
				{
					// Update the position.
					this.setPlowerMapPosition(aNewPlowerList[i].lon, aNewPlowerList[i].lat, aNewPlowerList[i].did, ixPos);

					// Set the found flag.
					bFound = true;
					break;
				}
			}
			if ( !bFound)
			{
				let isMe = (aNewPlowerList[i].did===sCurrentDeviceId) ? true : false;

				let ixPos = this.createPlowerMapPosition(
					aNewPlowerList[i].uid,
					aNewPlowerList[i].lon,
					aNewPlowerList[i].lat,
					aNewPlowerList[i].did,
					aNewPlowerList[i].accuracy,
					aNewPlowerList[i].name, isMe);
			}
		}
	};
	
	//
	// Remove the marker for a plower.
	this.removePlowerMarker = (ixPos) =>
	{
		// If found remove the feature / icon.
		if (ixPos >= 0)
		{
			if (this.m_aPositionList[ixPos].feature)
				this.m_vectorPositonSource.removeFeature(this.m_aPositionList[ixPos].feature);

			// Remove the element from the array.
			this.m_aPositionList.splice(ixPos, 1);
		}
	};
	
	//
	// Check for plowers to delete.
	this.checkDeletePlowerMapPosition = (aNewPlowerList) =>
	{
		let bDeleted = false;

		for (let ixPos=0; ixPos<this.m_aPositionList.length; ixPos++)
		{
			let bFound = false;

			for (let i=0; i<aNewPlowerList.length; i++)
			{
				if (aNewPlowerList[i].did===this.m_aPositionList[ixPos].deviceId)
				{
					bFound = true;
					break;
				}
			}
			if ( !bFound)
			{
				bDeleted = true;
				// Remove the element from the list.
				this.removePlowerMarker(ixPos); // Do not move the pointer.
				break; // Get out.
			}
		}
		return (bDeleted);
	};
	
	// Set the debug text.
	this.updateDebug = (sText) =>
	{
		$("#debug_message").val(sText);
	};
};

$(document).ready(function()
{
	let coord = { longitude: g_dCENTER_LONGITUDE, latitude: g_dCENTER_LATITUDE };
	let sName = "";

	// Convert php array to javascript.
	g_classMapClass.m_aPreDefSms = JSON.parse('{{@predefsms}}');

	// Set true if the module images is present.
	g_classMapClass.m_bModuleImages = {{@moduleimages}};

	// Convert to javascript object.
	g_classMapClass.m_aServiceAreas = JSON.parse('{{@service_areas}}');
	
	// Create the map.
	g_classMapClass.createMap(coord, sName);
});

//
// Turn off Pan and Trackmode.
function onClickTogglePan()
{
	g_classMapClass.m_bTogglePan = !g_classMapClass.m_bTogglePan;

	if (g_classMapClass.m_bTogglePan)
	{
		// Change class.
		$("#button_freeze").removeClass("nss_btn_map_warning");
		$("#button_freeze").addClass("nss_btn_map_danger");

		// Set the button text
		$("#button_freeze").text("Frys kart er AV");

		// Turn on compass function.
		g_classMapClass.m_bDeviceOrientation = true; // Rotate map
	}
	else
	{
		// Change class
		$("#button_freeze").removeClass("nss_btn_map_danger");
		$("#button_freeze").addClass("nss_btn_map_warning");

		// Set the button text
		$("#button_freeze").text("Frys kart er PÅ");

		// Turn on compass function.
		g_classMapClass.m_bDeviceOrientation = false; // Do not rotate map.
	}

	//
	// Change the Pan settings.
	g_classMapClass.m_oMap.getInteractions().forEach(function(interaction) {
		if (interaction instanceof ol.interaction.DragPan) {
			interaction.setActive(g_classMapClass.m_bTogglePan);
		}
	}, this);
}

//
// Toggle the trackmode.
function toggleTrackMode()
{
	g_classMapClass.m_bTrackMode = !g_classMapClass.m_bTrackMode;

	if (g_classMapClass.m_bTrackMode)
	{
		//$("#tooggleTrackMode").removeClass("btn-danger");
		//$("#tooggleTrackMode").addClass("btn-primary");
		$("#tooggleTrackMode").text("Posisjon er PÅ");
	}
	else
	{
		//$("#tooggleTrackMode").removeClass("btn-primary");
		//$("#tooggleTrackMode").addClass("btn-danger");
		$("#tooggleTrackMode").text("Posisjon er AV");
	}
}

//
// Set my position on the map.
function OnButtonMyPosition()
{
	if (g_classMapClass.m_oMyLastPos)
	{
		// Set default zoom for my position.
		g_classMapClass.m_oView.setZoom(17);

		// Set my position at the center of the map
		g_classMapClass.m_oView.setCenter(g_classMapClass.m_oMyLastPos);
	}
	else
	{
		g_oWebViewInterface.emit("onMyPosition", { type: 'error', message: "Posisjonen er ikke oppdatert ennå, du må først 'Slå på posisjon' vent til den oppdaterer seg. Så kan denne knappen brukes." });
	}			
}

//
// webview map interface.
//
window.func_setmapcenter = function(dLongitude, dLatitude, dHeading, dSpeed)
{
	return (g_classMapClass.setMyPosition(dLongitude, dLatitude, dHeading, dSpeed));
};

window.func_change_map = function(sMapType)
{
	if (g_classMapClass.setMapType(sMapType))
		return ("Map changed to "+sMapType);
	return ("Failed");
};

window.func_change_service = function(sService)
{
	if (g_classMapClass.changeService(sService))
		return (sService);
	return ("ERROR");
};

window.func_update_flags = function(bUpdateAll, aFlags)
{
	if (bUpdateAll)
	{
		// Save the flags list.
		g_classMapClass.m_aFlags = aFlags;
		
		if (g_classMapClass.createFlagLayer(aFlags))
			return ("ok");
	}
	else
	{
		// Update the flags list.
		if (g_classMapClass.updateFlagLayer(aFlags))
			return ("ok");
	}
	return ("Failed");
};

window.func_get_log_pos = function()
{
	return (g_classMapClass.getLogPosition());
};

window.func_get_settings = function()
{
	let sSearchMap = "YES";
	switch (g_classMapClass.m_iServiceMode)
	{
		case g_classMapClass.SERVICE_MODE_PLOWER:
			sSearchMap = g_classMapClass.m_sIsPlowerSearch;
			break;
			
		case g_classMapClass.SERVICE_MODE_ADMIN:
			sSearchMap = g_classMapClass.m_sIsAdminSearch;
			break;
	}
	
	return ({
		sMapSearch: sSearchMap,
		iFleetInterval: g_classMapClass.getFleetInterval(),
		sModuleImages: (g_classMapClass.m_bModuleImages) ? "YES" : "NO",
		sIsAdminChangeOrderStatus: g_classMapClass.m_sIsAdminChangeOrderStatus,
		sPlowerChangeOrderStatNoSms: g_classMapClass.m_sPlowerChangeOrderStatNoSms,
		dMapGPSAccuracy: g_classMapClass.m_dMapGPSAccuracy,
		dMapGPSMinSpeed: g_classMapClass.m_dMapGPSMinSpeed,
		sDropdownArea: g_classMapClass.m_sDropdownArea,
		sShowAllAreas: (g_classMapClass.m_bShowAllAreas) ? "YES" : "NO",
		sShowDateAboveFlag: (g_classMapClass.m_bShowDateAboveFlag) ? "YES" : "NO"
	});
};

//
// Set the flags.
window.func_set_flag_status = function(aObjectIdList, sOrderStatus, bExtraData, oExtraData)
{
	g_classMapClass.swapFeature(aObjectIdList, sOrderStatus, bExtraData, oExtraData);
	
	return (true);
};

//
// Set the status for one object not ordered, change the round ring to the extra flag. (green flag).
window.func_set_plow_extra_status = function(iObjectId, sOrderStatus, sServiceTag, iMinOld)
{
	try
	{
		let aFeatureList = g_classMapClass.m_vectorFlagSource.getFeatures();
		let iObjectStatus = 0;
		let loopFinished = false;

		aFeatureList.forEach((oFeature) => {
			
			if (loopFinished)
				return (true);
			
			let iObjectFeatureId = parseInt(oFeature.get("objectid"));

			if (iObjectFeatureId===iObjectId)
			{
				g_classMapClass.m_aFlags[iObjectId].im = 'F';
				g_classMapClass.m_aFlags[iObjectId].lo = 'F';
				g_classMapClass.m_aFlags[iObjectId].vt = "";
				g_classMapClass.m_aFlags[iObjectId].sv = sServiceTag;
				g_classMapClass.m_aFlags[iObjectId].at = '';
				g_classMapClass.m_aFlags[iObjectId].co = 'F';
				g_classMapClass.m_aFlags[iObjectId].mo = iMinOld;

				switch (sOrderStatus)
				{
					case ORDER_STATUS_NOT_ORDERED:
						iObjectStatus = OBJECT_STATUS_RING;
						break;

					case ORDER_STATUS_FINISHED_EXTRA:
						iObjectStatus = OBJECT_STATUS_RING_EXTRA;
						break;
						
					default: // Remove the extra flag.
						iObjectStatus = OBJECT_STATUS_RING;
						break;
				}
				g_classMapClass.m_aFlags[iObjectId].st = iObjectStatus; // object status.

				// Remove the feature
				let iFeatureId = oFeature.getId();
				g_classMapClass.m_vectorFlagSource.removeFeature(oFeature);

				// Create the new map feature.
				let iconFeature = g_classMapClass.createMapFeature(iObjectId, g_classMapClass.m_aFlags[iObjectId]);
				if (iconFeature!==false)
				{
					// Set the feature id, so i do net get any conflict.
					iconFeature.setId(iFeatureId);

					// Add the new feature.
					g_classMapClass.m_vectorFlagSource.addFeature(iconFeature);
				}
				loopFinished = true;
			}
		});
	}
	catch (err)
	{
		console.log("ERROR: "+err.message);
	}
};

//
// Create the marker.
window.func_create_marker = function(lon, lat)
{
	return (g_classMapClass.setSearchMarker(lon, lat));
};

//
// Remove the marker after search.
window.func_remove_marker = function()
{
	return (g_classMapClass.removeSearchMarker());
};

//
// Use to show an area.
window.func_show_area = function(iAreaId)
{
	return (g_classMapClass.displayArea(iAreaId));
};

//
// Updates the position for all the other plowers.
window.func_update_plowers = function(aPlowerPos, sDeviceId)
{
	return (g_classMapClass.updatePlowerPos(aPlowerPos, sDeviceId));
};

window.func_remove_plower = function(aPlowerList)
{
	let bFound = false;
	
	for (let ixPos=0; ixPos<g_classMapClass.m_aPositionList.length && !bFound; ixPos++)
	{
		for (let i=0; i<aPlowerList.length; i++)
		{
			if (aPlowerList[i].did===g_classMapClass.m_aPositionList[ixPos].deviceId)
			{
				g_classMapClass.removePlowerMarker(ixPos); // Do not move the pointer.
				bFound = true;
				break;
			}
		}
	}
};

window.func_update_debug = function(sText)
{
	return (g_classMapClass.updateDebug(sText));
};

</script>
{{@command:split}}
<div id="map" class="map"></div>
<div id="popup"></div>
<div id="position-layer"></div>
<div id="areaname"></div>
{{@if:is_plower}}
	{{@if:is_toggle_pan}}
	<a id="button_freeze" class="nss_btn_map_danger" style="position:fixed; left:10px; bottom:12px; margin:12px; padding:10px;" href="#" onclick="onClickTogglePan();">Frys kart er AV</a>
	{{@end-if:is_toggle_pan}}
	<div class="knapperad">
		<button id="tooggleTrackMode" class="nss_btn_map_primary" onclick="toggleTrackMode();">Posisjon er PÅ</button>
		<button class="nss_btn_map_primary" id="my-position" onclick="OnButtonMyPosition();">Min pos.</button>
	</div>
{{@else:is_plower}}

{{@end-if:is_plower}}