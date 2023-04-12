<link type="text/css" rel="stylesheet" href="css/map.css" />
<script src="js/map_gps.js?v={{@version_js}}"></script>
<!--script src="modules/module_websocket.js"></script-->
<script src="modules/module_map_util.js"></script>


<script>
	//admin_road_plowing_map_layers.php plowing checked maplayers--operation start

	let sMapLayers='{{@mapLayers}}'; 
	let aMapLayers = JSON.parse(sMapLayers);
	

	let oClassMapLayer = new module_map_layers(aMapLayers);

    oClassMapLayer.modifyMapLayersByFeatureFormat(aMapLayers);
	oClassMapLayer.createFeaturesFromMapLayers();
	oClassMapLayer.createStylesForMapLayersFeature();
	oClassMapLayer.setStyleByCategory();
	let sourceFromMapLayer = oClassMapLayer.createSourceFromMapLayer(); 
	//new ol.layer.Vector({ // Layer for the position. source: sourceFromMapLayer,}) 572-linje

	//admin_road_plowing_map_layers.php plowing checked maplayers--operation-end
	
	const ICON_SIZE_SMALL = 0.5;
	const ICON_SIZE_NORMAL = 1.0;
	const ICON_SIZE_LARGE = 1.5;
	const ICON_SIZE_HUGE = 2.0;

	// Declaring some constants.
	var SERVICE_MODE_PLOWER = {{@mode_plower}};
	var SERVICE_MODE_ADMIN = {{@mode_admin}};
	var CENTER_LONGITUDE = {{@longitude}};
	var CENTER_LATITUDE = {{@latitude}};
	var IS_SERVICE_MODE = {{@is_service_mode}}; // If is plower mode.
	var g_iServiceMode = {{@servicemodeid}};
	var IS_ADMIN_TO_CHANGE_ORDER_STATUS = {{@is_admin_change_order_status}};
	var IS_PLOWER_USE_ADMIN_CHANGE_ORDER_STATUS = {{@is_plower_use_admin_change_order_status}};
	var SERVICE_TYPE = '{{@servicetype}}';
	var USER_ID = {{@userid}};
	var PROVIDER_ID = {{@providerid}};
	//var STATUS_ORDERED = '<?php echo class_VL_order_status::STATUS_ORDERED;?>';
	//var STATUS_FINISHED = '<?php echo class_VL_order_status::STATUS_FINISHED;?>';
	//var STATUS_REORDERED = '<?php echo class_VL_order_status::STATUS_REORDERED;?>';
	//var STATUS_REORDERED_NO_SMS = '<?php echo class_VL_order_status::STATUS_REORDERED_NO_SMS;?>';
	//var STATUS_FINISHED_WRONG = '<?php echo class_VL_order_status::STATUS_FINISHED_WRONG;?>';
	//var STATUS_WORKING = '<?php echo class_VL_order_status::STATUS_WORKING;?>';
	var CURRENT_DEVICEID = '{{@currentdeviceid}}';
	var g_bAreaDropdown = {{@areadropdown}};
	var g_myLastPos = null;
	var g_iSelectedServiceTemplateId = {{@servicetemplateid}};
	var g_iWathPosId = null;
	var g_myDeviceId = '{{@currentdeviceid}}';
	var g_mySessionId = '{{@currentsessionid}}';
	var g_iSelectedAreaId = 0;
	var g_sShowAllAreas = '{{@showallareas}}';
	var g_bShowAllAreas = (g_sShowAllAreas.toUpperCase() === 'YES') ? true : false;
	var g_iLastLogPos = {{@logposition}};
	var g_iUpdateFleetInterval = {{@updatefleetinterval}};
	var g_bColorBlind = {{@colorblind_bool}};
	var g_bArrivalTime = {{@arrivaltime_bool}};
	var g_oLastLayer = null;
	var g_iRentingProviderId = {{@rentingproviderid}};
	var g_iMapGPSAccuracy = {{@mapgpsaccuracy}};
	var g_iMapGPSMinSpeed = {{@mapgpsminspeed}};
	var g_iMapGPSReverseMaxSpeed = {{@mapgpsrevmaxspeed}};
	var g_sIconName = '{{@iconname}}';
	var g_timeoutAreaName = null;
	var g_bShowDateAboveFlag = {{@map_showdateaboveflag}};
	var g_bMapShowAreaOrderTotal = {{@map_show_area_order_total}};

	var g_dHeading = 0; // The GPS heading.
	var g_dAccuracy = 0; // The GPS accuracy.
	var g_dSpeed = 0;
	var g_bToggleHideButtons = false;

	// declaration of  the map object initialized in the init function.
	var classMap = new Object();

	classMap.map;
	classMap.view;
	classMap.bOkClickMap = true; // Prevent other popups to popup when terminating one popup.
	classMap.element = null;
	classMap.popup = null;
	classMap.geolocation;
	classMap.lastLat = 0;
	classMap.lastLon = 0;
	classMap.lastHeading = 0;
	classMap.lastAltitude = 0;
	classMap.lastSpeed = 0;
	classMap.lastAccuracy = 0;
	classMap.lastAltitudeAccuracy = 0;
	classMap.iZoom = 17;
	classMap.aFlags = []; // List over all the flags.
	classMap.aPlowPos = []; // List over all the plowing tracktors.
	classMap.iFlagSize = 1.0;
	classMap.iSmallSize = 0.5;
	classMap.iNormalSize = 1.0;
	classMap.iLargeSize = 1.5;
	classMap.UPDATE_FLAG_INTERVAL = 30000; // 30 seconds.
	classMap.UPDATE_POSITION_INTERVAL = 10000;
	classMap.positionList = [];
	classMap.timestampLastUpdatePos = 0;
	classMap.trackMode = true;
	classMap.aPolygonList = []; // List of polygons to show.
	classMap.defaultStyle = null;
	// Obtain a new *world-oriented* Full Tilt JS DeviceOrientation Promise
	classMap.oOrientationControl = null;
	classMap.myPosition = null;
	classMap.iShowAll = 1;
	classMap.bDeviceOrientation = true; // Turn device orientation on or off.
	classMap.oTimer = null;
	classMap.sDateToShow = '{{@currday}}';
	classMap.sDateStart = '{{@today}}';
	classMap.bToggleComapss = false;
	classMap.bTogglePan = true; // Pan is on.
	classMap.bHouseNo = {{@houseno}};
	classMap.bRemovePopup = {{@removepopup}};
	classMap.sBlueBottonText = '{{@bluebuttontext}}';
	classMap.sServiceTag = '{{@servicetag}}';
	classMap.bPlowingEmergency = {{@emergency_plowing}}; // true / false.
	

	// Calcualte the number of days to show
	var g_d = new Date(); // Get date today
	var g_n = parseInt(g_d.getDay()); // day number sunday=0
	var g_iNumErrors = 0;
	//var g_bLocalClosing = false;
	//classMap.iNumDaysShow = (g_n===0)?0:7 - g_n;

	//create a vector source to add the icon(s) to.
	classMap.iconFeatureList = [];
	//classMap.statusList = [];

	// Create an empty vector for all the flags.
	classMap.vectorFlagSource = new ol.source.Vector({
		name:"vectorFlagSource"
	});

	
	classMap.clusterVectorFlagSource = new ol.source.Vector({
		name:"clusterVectorFlagSource"
	});;
	// Create an empty vector for the positons on the map.
	classMap.vectorPositonSource = new ol.source.Vector({

	});

	classMap.iconStyleOther = new ol.style.Style({
		image: new ol.style.Icon({
			anchor: [0.5, 0.5],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			anchorOrigin: 'top-left',
			opacity: 0.75,
			scale: 1.0,
			src: 'img/bullet-pink.svg'
		}),
		zIndex: 10
	});

	classMap.iconStyleMe = new ol.style.Style({
		image: new ol.style.Icon({
			anchor: [0.5, 0.5],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			anchorOrigin: 'top-left',
			opacity: 0.75,
			scale: 1.0,
			src: 'img/bullet-dark-blue.svg'
		}),
		zIndex: 10
	});

	classMap.textStyleMe = new ol.style.Style({
		text: new ol.style.Text({
			text: "Meg",
			font: 'bold 10px sans-serif',
			offsetY: 0,
			offsetX: 0,
			fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
			stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
		}),
		zIndex: 10
	});
	
	//var m_oSocket = new module_websocket();
	//m_oSocket.create();

	{{@if:is_search_object_person}}

	function ajax_get_data(sSearch)
	{
		console.log("sSearch: ",sSearch);
		return ($.ajax({
			type: 'post',
			url: 'ajax_gateway.php',
			data: {
				_class: "ajax_search_ownerobject",
				_func: "action_search",
				search: sSearch,
				providerid: PROVIDER_ID
			},
			error: function (sJsonRet) {
				nss_ajax_message();
			},
			success: function (data) {
				console.log("data:",JSON.parse(data))
			}
		}));
	}

	window.addEventListener('DOMContentLoaded', (event) =>
	{
		let oSelected = null;

		const asyncAutocomplete = document.querySelector('#search_ownerobject_container');
		const asyncFilter = async (sSearch) => {

			const data = await ajax_get_data(sSearch);

			return (JSON.parse(data));
		};
		
		const Autocomplete = document.getElementById("search_ownerobject_container");
		Autocomplete.addEventListener('itemSelect.mdb.autocomplete', (e) =>
		{
			if (oSelected)
			{
				if (g_oLastLayer)
					classMap.map.removeLayer(g_oLastLayer);

				if (oSelected.longitude !== 0 && oSelected.latitude !== 0)
				{
					var oPos = ol.proj.transform([parseFloat(oSelected.longitude), parseFloat(oSelected.latitude)], 'EPSG:4326', 'EPSG:3857');
					classMap.view.setCenter(oPos);

					g_oLastLayer = createMarker(oPos, $("#search_ownerobject").val());
					classMap.map.addLayer(g_oLastLayer);
				} else
				{
					// Get all the flags.
					$.ajax({
						type: 'post',
						url: 'ajax_gateway.php',
						data: {
							_class: "ajax_search_ownerobject",
							_func: "action_get_object",
							personid: oSelected.person_id
						},
						error: function () {
							console.log("Feil: En feil oppstod ved kall til ajax_search_ownerobject.php, forsøk på nytt.");
						},
						success: function (sJsonRet) {
							//console.log(sJsonRet);
							var aTempFlags = JSON.parse(sJsonRet);

							if (aTempFlags.length > 0)
							{
								// Get only the first at the moment.
								var oPos = ol.proj.transform([parseFloat(aTempFlags[0].lon), parseFloat(aTempFlags[0].lat)], 'EPSG:4326', 'EPSG:3857');
								classMap.view.setCenter(oPos);

								g_oLastLayer = createMarker(oPos, $("#search_ownerobject").val());
								classMap.map.addLayer(g_oLastLayer);
							}
						}
					});
				}
			}
		});

		new mdb.Autocomplete(asyncAutocomplete, {
			filter: asyncFilter,
			threshold: 3,
			displayValue: (oItem) => {

				// Save the value
				oSelected = oItem;

				// Return the selected value.
				return (oItem.label);
			}
		});
	});
	{{@end-if:is_search_object_person}}

	//var iOrinetationCount = 0;
	function createMarker(oPos, sName)
	{
		var iconStyle = new ol.style.Style({
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

		var iconFeature = new ol.Feature({
			geometry: new ol.geom.Point(oPos),
			areaname: sName
		});

		iconFeature.setStyle(iconStyle);

		var vectorSource = new ol.source.Vector({
			features: [iconFeature]
		});

		var vectorLayer = new ol.layer.Vector({
			source: vectorSource
		});

		return (vectorLayer);
	}

	function update_plowers()
	{
		// Get the plower positions.
		$.ajax({
			type: 'post',
			url: 'ajax_update_plowers.php',
			data: {
				providerid: PROVIDER_ID
			},
			error: function () {
				console.log("FEIL: En feil oppstod ved kall til ajax_update_plowers.php");

			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let oRet = JSON.parse(sJsonRet); // Apiret
				if (oRet.bRet)
				{
					// Update the plowers.
					classMap.aPlowPos = oRet.aData;
					updatePlowerPos(classMap.aPlowPos, CURRENT_DEVICEID);
				} else
				{
					nss_message('danger', oRet.sMess);
				}
			}
		});
	}

	function mapInit()
	{
		//open websocket
		if (IS_SERVICE_MODE)
		{
			initTrackingMode();
		}

		// Set the company center to first positin to enter.
		var crd = { longitude: CENTER_LONGITUDE, latitude: CENTER_LATITUDE, accuracy: 0 };

		// Create the map.
		doCreateMap(crd);

		// Get all the flags.
		$.ajax({
			type: 'post',
			url: 'ajax_update_flags.php',
			data: {
				date: classMap.sDateToShow,
				showall: classMap.iShowAll,
				servicetemplateid: g_iSelectedServiceTemplateId,
				providerid: PROVIDER_ID,
				renting_provider_id: g_iRentingProviderId,
				areaid: g_iSelectedAreaId, // Show all first time.
				logpos: g_iLastLogPos,
				mode: g_iServiceMode,
				gettype: "getall"
			},
			error: function () {
				console.log("Feil: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");
			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let oRet = JSON.parse(sJsonRet); // Apiret
				if (oRet.bRet)
				{
					classMap.aFlags = oRet.aData.data;
					console.log("classMap.aFlags: ", classMap.aFlags);
					// Draw all the cottages.
					//Bizim map imiz burda olusuyor iste tam olarak....
					createFlagLayer(classMap.aFlags);
					console.log("classMap.map-outsideofCreateFlagLayer: ",classMap.map.getAllLayers());
					console.log("Zoom-level: ",classMap.map.getView().getZoom());
					/*
						classMap.map.addLayer(classMap.vectorFlagLayer);	
						classMap.map.addLayer(classMap.clusterFlagLayer);	*/
						
						classMap.map.addLayer(classMap.vectorFlagLayer);
						
						classMap.map.addLayer(classMap.clusterFlagLayer);
					   classMap.clusterFlagLayer.setVisible(false);


									console.log("layercount: ",classMap.map.getAllLayers());
						
						classMap.map.getView().on('change:resolution', function (evt)
							{
							console.log("Zoom-levellll: ",classMap.map.getView().getZoom());
								classMap.iZoom = classMap.map.getView().getZoom();

								if (classMap.iZoom >= 18)
								{
								console.log("classMap.iZoom >= 18");
								classMap.vectorFlagLayer.setVisible(true);
								classMap.clusterFlagLayer.setVisible(false);


									//classMap.iFlagSize = classMap.iLargeSize;
									//createFlagLayer(classMap.aFlags);
									//classMap.map.removeLayer(classMap.vectorFlagLayer);
									//classMap.map.removeLayer(classMap.clusterFlagLayer);
									//classMap.map.addLayer(classMap.vectorFlagLayer);
									console.log("layercount: ",classMap.map.getAllLayers());
									
								} else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
								{
								console.log("classMap.iZoom >= 16 && classMap.iZoom < 18");
								classMap.clusterFlagLayer.setVisible(true);
								classMap.vectorFlagLayer.setVisible(false);


									//classMap.iFlagSize = classMap.iNormalSize;
									//createFlagLayer(classMap.aFlags);
									//classMap.map.removeLayer(classMap.vectorFlagLayer);
									//classMap.map.removeLayer(classMap.clusterFlagLayer);
									//classMap.map.addLayer(classMap.vectorFlagLayer);
									
									console.log("layercount: ",classMap.map.getAllLayers());
								} else if (classMap.iZoom < 16)
								{
									console.log("classMap.iZoom < 16");
									classMap.clusterFlagLayer.setVisible(true);
									classMap.vectorFlagLayer.setVisible(false);
									
									
									//classMap.iFlagSize = classMap.iSmallSize;
									//createFlagLayer(classMap.aFlags);
									//classMap.map.removeLayer(classMap.vectorFlagLayer);
									//classMap.map.removeLayer(classMap.clusterFlagLayer);
									//classMap.vectorFlagLayer.setVisible(false);
								   //classMap.clusterFlagLayer.setVisible(true);
									console.log("classMap.vectorFlagLayerVisibility: ",classMap.vectorFlagLayer.getVisible());
									console.log("classMap.clusterFlagLayerVISIBILITY: ",classMap.clusterFlagLayer.getVisible());
									
									//classMap.map.addLayer(classMap.clusterFlagLayer);
									console.log("layercount: ",classMap.map.getAllLayers());
									//Problem clusterFlagLayer dan geliyor...bunun style i neden vectorFlagLayer i n ki ile ayni geliyor ona bakalim!!!!
								}
							}); 
					//
					// Update the plowers
					update_plowers();

					// Set timer to update the flags.
					classMap.oTimer = window.setTimeout(timeUpdateFlags, classMap.UPDATE_FLAG_INTERVAL);

					if (g_iServiceMode === SERVICE_MODE_PLOWER)
					{
						// Start the auto report position of this device.
						reportPosition();
					}
				}
				else
				{
					nss_message('danger', oRet.sMess);
				}
			}
		});
	}

	// 
	// This function updates the flags at a special interval, gets only the changes.
	//
	function timeUpdateFlags()
	{
		doUpdateFlags(true);
	}
	
	function doUpdateFlags(bTimer)
	{
		// Get the last updated.
		$.ajax({
			type: 'post',
			url: 'ajax_update_flags.php',
			data: {
				date: classMap.sDateToShow,
				showall: classMap.iShowAll,
				servicetemplateid: g_iSelectedServiceTemplateId,
				providerid: PROVIDER_ID,
				renting_provider_id: g_iRentingProviderId,
				areaid: (g_bShowAllAreas) ? 0 : g_iSelectedAreaId,
				mode: g_iServiceMode,
				logpos: g_iLastLogPos,
				gettype: "getupdate"
			},
			error: function () {
				//console.log("FEIL: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");

				if (bTimer)
				{
					// Start the timer once more.
					classMap.oTimer = window.setTimeout(timeUpdateFlags, classMap.UPDATE_FLAG_INTERVAL);
				}
			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let oRet = JSON.parse(sJsonRet); // Apiret
				if (oRet.bRet)
				{
					if (oRet.aData.data.length > 0)
					{
						// Draw all the flags.
						updateFlagLayer(oRet.aData.data);
						console.log("Draw all the flags.: ",oRet.aData.data);

					}
				}
				else
				{
					nss_message('danger', oRet.sMess);
				}
				// Update the plowers
				update_plowers();

				if (bTimer)
				{
					// Start the timer once more.
					classMap.oTimer = window.setTimeout(timeUpdateFlags, classMap.UPDATE_FLAG_INTERVAL);
				}
			}
		});
	}

	//
	// Terminate the popup.
	function timeoutAreaName()
	{
		$("#areaname").css("display", "none");

		window.clearTimeout(g_timeoutAreaName);
		g_timeoutAreaName = null;
	}

	function doCreateMap(crd)
	{
		//var point = new ol.proj.transform([parseFloat(crd.longitude), parseFloat(crd.latitude)], 'EPSG:4326', 'EPSG:3857');
		var point = ol.proj.fromLonLat([parseFloat(crd.longitude), parseFloat(crd.latitude)]);
		var aFeatureList = [];

		// Create a style.
		classMap.defaultStyle = new ol.style.Style({
			stroke: new ol.style.Stroke({
				color: '#AAAAAA',
				width: 2
			}),
			fill: new ol.style.Fill({
				color: [ 10, 10, 10, 0.1 ],
			})
		});

		// Create array of all the features / polygons.
	{{@loop:servicearealist}}
		// Get the area as json and convert to an array.
		var polyCoords = JSON.parse('{{@servicearealist:area_json}}');
		var oFeature = new ol.Feature({
			areaname: '{{@servicearealist:area_name}}',
			geometry: new ol.geom.Polygon(polyCoords)
		});

		// Set the style for the feature.
		oFeature.setStyle(classMap.defaultStyle);

		aFeatureList.push(oFeature);

		classMap.aPolygonList.push({
			id: {{@servicearealist:id}},
			name: '{{@servicearealist:area_name}}',
			polygon: '{{@servicearealist:area_json}}',
			feature: oFeature
		});
	{{@end-loop:servicearealist}}
		var polygonSource = new ol.source.Vector({
			features: aFeatureList
		});

		if (IS_SERVICE_MODE)
		{
			// Set the correct buttons state.
			if (classMap.trackMode)
			{
				hideButtons();
				classMap.bDeviceOrientation = true; // Do not rotate map.
			} else
			{
				showButtons();
				classMap.bDeviceOrientation = false; // Rotate map.
			}
		}

		classMap.view = new ol.View({
			//projection: 'EPSG:3857',
			center: point,
			zoom: classMap.iZoom,
			//maxZoom: 18,
			rotation: 0
		});

		classMap.overlayAreaName = new ol.Overlay({
			element: document.getElementById('areaname'),
			positioning: 'bottom-left'
		});
		
		

		classMap.map = new ol.Map({

			layers: [
				new ol.layer.Tile({
					title: "Kart",
					preload: 8,
					source: g_oMapSource
				}),
				new ol.layer.Vector({
					source: polygonSource, // Layer for the areas
				//	maxResolution: 30
				}),
			/*	new ol.layer.Vector({ // Layer for the flags.
					source: classMap.vectorFlagSource,
					
				//	source:clusterForVectorFlagSource,
					maxResolution: 10,
					
				}), */
				new ol.layer.Vector({ // Layer for the position.
					source: classMap.vectorPositonSource,
					maxResolution: 10
				}),
				new ol.layer.Vector({ // Layer for the position.
					source: sourceFromMapLayer,
				}),
				
			],
			target: document.getElementById('map'),
			controls: ol.control.defaults({
				attributionOptions: /** @type { olx.control.AttributionOptions } */ ({
					collapsible: false
				})
			}),
			view: classMap.view
		});

	
		
		
		classMap.overlayAreaName.setMap(classMap.map);

		// display popup on click
		classMap.element = document.getElementById('popup');
		classMap.popup = new ol.Overlay({
			element: classMap.element,
			//positioning: 'bottom-center',
			stopEvent: true
		});

		// Where am i.
		classMap.geolocation = new ol.Geolocation({
			projection: classMap.view.getProjection(),
			tracking: true
		});
		classMap.map.addOverlay(classMap.popup);
		//classMap.popup.setMap(classMap.map);

		classMap.map.on('click', mapClick);

		// Changeing resolution, change the icon size.
	/*	classMap.map.getView().on('change:resolution', function (evt)
		{
			classMap.iZoom = classMap.map.getView().getZoom();

			if (classMap.iZoom >= 18)
			{
				classMap.iFlagSize = classMap.iLargeSize;
				createFlagLayer(classMap.aFlags);
			} else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
			{
				classMap.iFlagSize = classMap.iNormalSize;
				createFlagLayer(classMap.aFlags);
			} else if (classMap.iZoom < 16)
			{
				classMap.iFlagSize = classMap.iSmallSize;
				createFlagLayer(classMap.aFlags);
			}
		}); */

		// change mouse cursor when over marker
		classMap.map.on('pointermove', function (e)
		{
			if (e.dragging) {
				//$(classMap.element).popover('destroy');
				return;
			}
			var pixel = classMap.map.getEventPixel(e.originalEvent);
			var hit = classMap.map.hasFeatureAtPixel(pixel);
			classMap.map.getTarget().style.cursor = hit ? 'pointer' : '';
		});
	}
	// Insert the map click javascript from the class_map_xxxxxx.php
</script>
{{@javascript_mapclick}}
<script>
	var g_myShow;

	function onChangeTexts()
	{
		let sSelText = $("#predefined_text_field").val();

		// Inser the text into the input field.
		$("#input_text_message").text(sSelText);
	}

	function OnClickHideEvent()
	{
		let bHidden = $("#create_event").is(":hidden");
		if (bHidden) // Then show.
		{
			$("#create_event").show();
		} else
		{
			$("#create_event").hide();
		}
	}
	
	var g_bImagesVisible = false;

	function OnClickShowImages(iObjectId)
	{
		if (g_bImagesVisible)
		{
			g_bImagesVisible = false;

			$("#object_images").html('');
			$("#object_images").hide();
		}
		else
		{
			g_bImagesVisible = true;

			// First get the images for this cottage.
			$.ajax({
				type: 'post',
				url: 'ajax_get_images.php',
				data: {
					act: 'get_images',
					objectid: iObjectId
				},
				error: function () {
					nss_message('danger', "FEIL<br/><br/>Ved henting av bilder.");
				},
				success: function (sJson)
				{
					//console.log(sJson);
					let oRet = JSON.parse(sJson);

					// Show the images.
					let sHtml = '<div id="carousel_images" class="carousel slide carousel-fade" data-mdb-ride="carousel">';

					if (oRet.aData.length > 0)
					{
						sHtml += '<div class="carousel-indicators">';

						// Create the html code, loop through all the images.
						for (let i=0; i<oRet.aData.length; i++)
						{
							if (i===0) // First.
								sHtml += '<button type="button" data-mdb-target="#carousel_images" data-mdb-slide-to="'+i+'" class="active" aria-current="true" aria-label="Slide_'+(i+1)+'"></button>';
							else
								sHtml += '<button type="button" data-mdb-target="#carousel_images" data-mdb-slide-to="'+i+'" aria-label="Slide_'+(i+1)+'"></button>';
						}
						sHtml += '</div>';
						sHtml += '<div class="carousel-inner">';

						// The images.
						for (let i = 0; i < oRet.aData.length; i++)
						{
							let sImage = oRet.aData[i].image_path;
							let sImageText = (oRet.aData[i].image_text) ? oRet.aData[i].image_text : oRet.aData[i].image_path;

							let sActive = '';
							if (i===0)
								sActive = ' active';

							sHtml += '<div class="carousel-item'+sActive+'">';
							sHtml += '   <img src="'+sImage+'" class="d-block w-100" alt="'+sImageText+'">';
							sHtml += '   <div class="carousel-caption d-none d-md-block">';
							sHtml += '      <h5>Bilde #'+(i+1)+'</h5>';
							sHtml += '    </div>';
							sHtml += '</div>';
						}
						sHtml += '<button class="carousel-control-prev" type="button" data-mdb-target="#carousel_images" data-mdb-slide="prev">';
						sHtml += '   <span class="carousel-control-prev-icon" aria-hidden="true"></span>';
						sHtml += '   <span class="visually-hidden">Previous</span>';
						sHtml += '</button>';
						sHtml += '<button class="carousel-control-next" type="button" data-mdb-target="#carousel_images" data-mdb-slide="next">';
						sHtml += '   <span class="carousel-control-next-icon" aria-hidden="true"></span>';
						sHtml += '   <span class="visually-hidden">Next</span>';
						sHtml += '</button>';
					}
					else
					{
						sHtml += "Ingen bilder";

						g_myShow = null;
					}
					sHtml += '</div>';

					$("#object_images").html(sHtml);
					$("#object_images").show();
				}
			});
		}
	}

	//
	// Only saves the text to database.
	/*
	 function OnButtonSaveText(aOrderIdList)
	 {
	 var sMessage = $("#input_text_message").text();
		 
	 OnButtonDestroyPopup(); // Remove the popup.
		 
	 if (sMessage.length > 0)
	 {
	 $.ajax({
	 type: 'post',
	 url: 'ajax_save_message.php',
	 data: {
	 orderid: aOrderIdList,
	 message: sMessage
	 },
	 error: function () {
	 //console.log("FEIL: En feil oppstod ved kall til ajax_send_order_sms.php, forsøk på nytt.");
		 
	 nss_message('danger', "FEIL<br/><br/>Meldingen ble ikke lagret");
	 },
	 success: function (sRet)
	 {
	 if (sRet === "ERROR")
	 {
	 nss_message("danger", "FEIL<br/><br/>Meldingen ble ikke lagret.");
	 }
	 else
	 {
	 nss_message("success", "OK<br/><br/>Meldingen er lagret.");
	 }
	 }
	 });
	 }
	 else
	 {
	 nss_message("danger", "FEIL<br/><br/>Meldingen er tom og blir derfor ikke lagret.");
	 }
	 }
	 */
	//
	// Send the message as an sms, saves the text to database.
	function OnButtonCreateEvent(iObjectId, sOrderIdList, sMobileList, sServiceTag)
	{
		let sEventText = $("#input_text_message").val();
		let bMessageOnSms = $("#event_message_on_sms").is(":checked");
		
		OnButtonDestroyPopup(); // Remove the popup.

		if (sEventText.length > 0)
		{
			$.ajax({
				type: 'post',
				url: 'ajax_gateway.php',
				data: {
					_class: 'ajax_event',
					_func: 'save_event',
					objectid: iObjectId,
					orderidlist: sOrderIdList,
					mobilelist: sMobileList,
					message: sEventText,
					servicetag: sServiceTag,
					sendmessage: (bMessageOnSms) ? "T" : "F"
				},
				error: function ()
				{
					//console.log("FEIL: En feil oppstod ved kall til ajax_send_order_sms.php, forsøk på nytt.");

					nss_message('danger', "FEIL<br><br>Hendelsen ble ikke lagret.");
				},
				success: function (sJsonRet)
				{
					//console.log(sJsonRet);
					let oRet = JSON.parse(sJsonRet);
					if (oRet.bRet)
					{
						nss_message("success", "OK<br><br>" + oRet.aData.message);
					} else
					{
						nss_message("danger", "FEIL<br><br>" + oRet.aData.message);
					}
				}
			});
		}
		else
		{
			nss_message("danger", "FEIL<br><br>Meldingen er tom og hendelsen blir derfor ikke lagret.");
		}
	}

	function trail0(iStr, iNumChar)
	{
		var iLen = (iStr + "").length;
		var sRet = "";

		for (var i = 0; i < iNumChar - iLen; i++)
		{
			sRet += "0";
		}
		sRet += (iStr + "");
		return (sRet);
	}
</script>
{{@javascript_placeorder}}
<script>
	function OnButtonDestroyPopup()
	{
		classMap.bOkClickMap = true; // Ok to click the map.
		//$(classMap.popup).a('destroy');
		classMap.popup.getElement().style.display = 'none';

		//
		// UnFreeze The Map.
		unFreezeMap();

		if (classMap.trackMode && classMap.bOkClickMap)
		{
			if (g_myLastPos)
			{
				// Set the position at the center of the map
				classMap.view.setCenter(g_myLastPos);
			}
		}
	}

	function OnReloadFlags(sDate, iPos)
	{
		classMap.sDateToShow = sDate;

		// Redraw all the cottages on the map.
		$.ajax({
			type: 'post',
			url: 'ajax_update_flags.php',
			data: {
				date: classMap.sDateToShow,
				showall: classMap.iShowAll,
				servicetemplateid: g_iSelectedServiceTemplateId,
				providerid: PROVIDER_ID,
				renting_provider_id: g_iRentingProviderId,
				areaid: (g_bShowAllAreas) ? 0 : g_iSelectedAreaId,
				logpos: g_iLastLogPos,
				mode: g_iServiceMode,
				gettype: "getall"
			},
			error: function () {
				console.log("FEIL: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");
			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let oRet = JSON.parse(sJsonRet); // Apiret
				if (oRet.bRet)
				{
					classMap.aFlags = oRet.aData.data;

					// Find the class with nss_btn_danger set it to nss_btn_primary
					for (var i = 0; i < 7; i++)
					{
						var oButton = document.getElementById("btn-" + i);
						if (oButton.className.indexOf('nss_btn_danger') >= 0) // Found.
						{
							$("#btn-" + i).removeClass('nss_btn_danger');
							$("#btn-" + i).addClass('nss_btn_primary');
						}
					}
					$("#btn-" + iPos).removeClass('nss_btn_primary');
					$("#btn-" + iPos).addClass('nss_btn_danger');

					// Draw all the cottages.
					createFlagLayer(classMap.aFlags);
				}
				else
				{
					nss_message('danger', oRet.sMess);
				}
			}
		});
	}

	function countFlagsOnSameBuilding(aBuildingIdList, iBuildingId)
	{
		var iLen = aBuildingIdList.length;
		var iCount = 0;

		for (var i = 0; i < iLen; i++)
		{
			if (parseInt(aBuildingIdList[i]) === iBuildingId)
				iCount++;
		}
		return (iCount);
	}

	function getIconStyle(iObjectTypeId, sValueType, sServicevalue, iconScale, iRotation, sContinues, sStatus, sFlagType)
	{
		var sFlagIcon = "";

		if (sContinues === 'T')
		{
			switch (sStatus)
			{
				case 'green': // Green flag.
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/greenflag_house_cont.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/greenflag_parking_cont.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/greenflag_apartment_cont.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/greenflag_parking_cont.svg'; // Not continues.
							break;

						default:
							if (sFlagType==='2') // Carpenter.
							{
								sFlagIcon = "img/greenflag_hammer_cont.svg";
							}
							else
							{
								if (sValueType === '{{@valuetype_parking}}')
								{
									sFlagIcon = "img/greenflag_cont.svg";
								}
								else
								{
									sFlagIcon = "img/greenflag_cont.svg";
								}
							}
							break;
					}
					break;

				case 'blue': // Blue flag.
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/blueflag_house_cont.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/blueflag_parking_cont.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/blueflag_apartment_cont.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/blueflag_parking_cont.svg'; // Not continues.
							break;

						default:
							if (sFlagType==='2') // Carpenter.
							{
								sFlagIcon = "img/blueflag_hammer_cont.svg";
							}
							else
							{
								if (sValueType === '{{@valuetype_parking}}')
								{
									sFlagIcon = "img/blueflag_cont.svg";
								} else
								{
									sFlagIcon = "img/blueflag_cont.svg";
								}
							}
							break;
					}
					break;

				default:
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/redflag_house_cont.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/redflag_parking_cont.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/redflag_apartment_cont.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/redflag_apartment_cont.svg';
							break;

						default:
							if (sValueType === '{{@valuetype_parking}}')
							{
								if (sFlagType==='2') // Carpenter.
								{
									sFlagIcon = "img/redflag_hammer_cont.svg";
								}
								else
								{
									switch (parseInt(sServicevalue))
									{
										case 2:
											sFlagIcon = "img/redflag2_cont.svg";
											break;

										case 3:
											sFlagIcon = "img/redflag3_cont.svg";
											break;

										default:
											sFlagIcon = "img/redflag_cont.svg";
											break;
									}
								}
							}
							else
							{
								sFlagIcon = "img/redflag_cont.svg";
							}
							break;
					}
					break;
			}
		} else // Normal.
		{
			switch (sStatus)
			{
				case 'red':
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/redflag_house.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/redflag_parking.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/redflag_apartment.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/redflag_no_road.svg';
							break;

						default:
							if (sValueType === '{{@valuetype_parking}}')
							{
								switch (parseInt(sServicevalue)) // One default.
								{
									case 2:
										sFlagIcon = 'img/redflag2.svg';
										break;

									case 3:
										sFlagIcon = 'img/redflag3.svg';
										break;

									case 4:
										sFlagIcon = 'img/redflag4.svg';
										break;

									case 5:
										sFlagIcon = 'img/redflag5.svg';
										break;

									case 6:
										sFlagIcon = 'img/redflag6.svg';
										break;

									default: // For one or more.
										sFlagIcon = 'img/redflag.svg';
										break;
								}
							}
							else // Other than PARKING.
							{
								sFlagIcon = "img/redflag.svg"; // Red
							}
							break;
					}
					break;

				case 'orange':
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/orangeflag_house.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/orangeflag_parking.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/orangeflag_apartment.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/orangeflag_no_road.svg';
							break;

						default:
							if (sValueType === '{{@valuetype_parking}}')
							{
								switch (parseInt(sServicevalue)) // One default.
								{
									case 2:
										sFlagIcon = 'img/orange2.svg';
										break;

									case 3:
										sFlagIcon = 'img/orange3.svg';
										break;

									case 4:
										sFlagIcon = 'img/orange4.svg';
										break;

									case 5:
										sFlagIcon = 'img/orange5.svg';
										break;

									case 6:
										sFlagIcon = 'img/orange6.svg';
										break;

									default: // For one or more.
										sFlagIcon = 'img/orange.svg';
										break;
								}
							} else // Other than parking.
							{
								sFlagIcon = 'img/orange.svg'; // Orange
							}
							break;
					}
					break;

				case 'green':
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/greenflag_house.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/greenflag_parking.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/greenflag_apartment.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/greenflag_no_road.svg';
							break;

						default:
							if (sValueType === '{{@valuetype_parking}}')
							{
								switch (parseInt(sServicevalue)) // One default.
								{
									case 2:
										sFlagIcon = "img/greenflag2.svg";
										break;

									case 3:
										sFlagIcon = "img/greenflag3.svg";
										break;

									case 4:
										sFlagIcon = "img/greenflag4.svg";
										break;

									case 5:
										sFlagIcon = "img/greenflag5.svg";
										break;

									case 6:
										sFlagIcon = "img/greenflag6.svg";
										break;

									default:
										sFlagIcon = 'img/greenflag.svg'; // Green parking flag.
										break;
								}
							} else
							{
								sFlagIcon = 'img/greenflag.svg'; // Normal green.
							}
							break;
					}
					break;

				case 'blue':
					switch (iObjectTypeId)
					{
						case {{@object_type_house}}:
							sFlagIcon = 'img/blueflag_house.svg';
							break;

						case {{@object_type_parking}}:
							sFlagIcon = 'img/blueflag_parking.svg';
							break;

						case {{@object_type_apartment_building}}:
							sFlagIcon = 'img/blueflag_apartment.svg';
							break;

						case {{@object_type_cottage_no_road}}:
							sFlagIcon = 'img/blueflag_no_road.svg';
							break;

						default:
							if (sValueType === '{{@valuetype_parking}}')
							{
								switch (parseInt(sServicevalue)) // One default.
								{
									case 2:
										sFlagIcon = "img/blueflag2.svg";
										break;

									case 3:
										sFlagIcon = "img/blueflag3.svg";
										break;

									case 4:
										sFlagIcon = "img/blueflag4.svg";
										break;

									case 5:
										sFlagIcon = "img/blueflag5.svg";
										break;

									case 6:
										sFlagIcon = "img/blueflag6.svg";
										break;

									default:
										sFlagIcon = 'img/blueflag.svg'; // Green parking flag.
										break;
								}
							} else
							{
								sFlagIcon = 'img/blueflag.svg'; // Normal green.
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
	}

	function updateFlagLayer(aNewObjectList)
	{
		let aDeleteList = [];
		let bFound = false;

		// JIG Må gå gjennom dette for å sjekke at dette stemmer for BLOKKER og PARKERINGSPLASSER, handle alle the status correct.
		for (let ii = 0; ii < aNewObjectList.length; ii++)
		{
			for (let i = 0; i < classMap.aFlags.length; i++)
			{
				if (parseInt(classMap.aFlags[i].object_id) === parseInt(aNewObjectList[ii].object_id))
				{
					if (aNewObjectList.logstatus === '{{@status_deleted}}')
						aDeleteList.push(i);
					else
						classMap.aFlags[i] = aNewObjectList[ii];
					bFound = true;
					
					for (let iOrd=0; iOrd<aNewObjectList[ii].orderlist.length; iOrd++)
					{
						if (aNewObjectList[ii].orderlist[iOrd].logg_id>g_iLastLogPos)
						{
							g_iLastLogPos = aNewObjectList[ii].orderlist[iOrd].logg_id;
						}
					}

					// update the logposition.
					//if (aNewObjectList[ii].logg_id && aNewObjectList[ii].logg_id > g_iLastLogPos)
					//	g_iLastLogPos = aNewObjectList[ii].logg_id;
					break;
				}
			}
			if (!bFound) // Add a new.
			{
				classMap.aFlags.push(aNewObjectList[ii]);
			}
		}

		// Remove all the deleted, delete the last first.
		let iNum2Delete = aDeleteList.length;
		if (iNum2Delete > 0)
		{
			for (let i = iNum2Delete - 1; i >= 0; i--)
			{
				classMap.aFlags.splice(aDeleteList[i], 1);
			}
		}
		createFlagLayer(classMap.aFlags);
	}

	function create_iconstyle(sImage, iconScale)
	{
		let iconStyle = new ol.style.Style({
			image: new ol.style.Icon({
				anchor: [0.5, 35],
				anchorXUnits: 'fraction',
				anchorYUnits: 'pixels',
				opacity: 0.9,
				scale: iconScale,
				rotation: 0,
				src: sImage
			}),
			zIndex: 1
		});
		return (iconStyle);
	}

	function create_textstyle_multi_parking()
	{
		let iFontSize = 20;
		let iOffsetY = -5;

		if (classMap.iZoom < 16)
		{
			iFontSize = 12;
		}
		var textStyleMulti = new ol.style.Style({
			text: new ol.style.Text({
				text: "P", //Parking
				font: 'bold ' + iFontSize + 'px sans-serif',
				offsetY: iOffsetY,
				offsetX: 0,
				fill: new ol.style.Fill({ color: 'rgb(0,100,0)' }), // Allways marked as valid contract.
				stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
			}),
			zIndex: 2
		});
		return (textStyleMulti);
	}

	function create_textstyle_multi()
	{
		let iFontSize = 18;
		let iOffsetY = -5;

		if (classMap.iZoom < 16)
		{
			iFontSize = 10;
		}
		var textStyleMulti = new ol.style.Style({
			text: new ol.style.Text({
				text: "\uf0c0", // Users icon.
				font: iFontSize + 'px FontAwesome',
				offsetY: iOffsetY,
				offsetX: 0,
				fill: new ol.style.Fill({ color: 'rgb(0,100,0)' }), // Allways marked as valid contract.
				stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
			}),
			zIndex: 2
		});
		return (textStyleMulti);
	}

	function create_textstyle_houseno(sHouseNo)
	{
		let iFontSize = 18;

		switch (classMap.iZoom)
		{
			case 17:
				iFontSize = 14;
				break;

			case 16:
			case 15:
				iFontSize = 10;
				break;

			default:
				if (classMap.iZoom < 15)
					iFontSize = 9;
				break;
		}

		let oTextStyle = new ol.style.Style({
			text: new ol.style.Text({
				text: sHouseNo + "",
				font: iFontSize + 'px sans-serif',
				offsetY: 6,
				offsetX: 0,
				fill: new ol.style.Fill({ color: 'rgb(255,255,255)' }),
				stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
			}),
			zIndex: 10
		});
		return (oTextStyle);
	}

	function create_textstyle_warning(iWarningOffset)
	{
		let iFontSize = 18;

		if (classMap.iZoom < 16)
		{
			iFontSize = 10;
		}
		let textStyle = new ol.style.Style({
			text: new ol.style.Text({
				text: "\uf071", // Warning icon.
				font: iFontSize + 'px FontAwesome',
				offsetY: iWarningOffset,
				offsetX: 0,
				fill: new ol.style.Fill({ color: 'rgb(0,0,0)' }),
				stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
			}),
			zIndex: 2
		});
		return (textStyle);
	}

	function create_textstyle_dateto(sDate)
	{
		let textStyle = null;
		let sDispDate = "";
		let iOffsetY = 0;
		let iOffsetX = 0;
		let iFontSize = 0;

		switch (classMap.iFlagSize)
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

		if (sDate && iFontSize > 0)
		{
			sDispDate = nss_sqldate2dispdate_short(sDate);

			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: sDispDate,
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
	}

	function create_textstyle_colorblind(charToShow)
	{
		let textStyle = null;
		let iOffsetY = 0;
		let iOffsetX = 0;
		let iFontSize = 0;

		switch (classMap.iFlagSize)
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
		if (iFontSize > 0)
		{
			textStyle = new ol.style.Style({
				text: new ol.style.Text({
					text: charToShow, // Warning icon.
					font: 'bold '+iFontSize+'px Verdana',
					offsetY: iOffsetY,
					offsetX: iOffsetX,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
					stroke: new ol.style.Stroke({ color: 'rgb(245,245,245)', width: 2})
				}),
				zIndex: 2
			});
		}
		return (textStyle);
	}

	function create_textstyle_arrival(sArrivalTime)
	{
		var textCh = "";

		switch (sArrivalTime)
		{
			case '{{@arrival_time_morning}}':
			case '{{@arrival_time_morning_early}}':
				textCh = "1";
				break;

			case '{{@arrival_time_afternoon}}':
				textCh = "2";
				break;

			case '{{@arrival_time_eving}}':
				textCh = "3";
				break;

			case '{{@arrival_time_night}}':
				textCh = "4";
				break;

			default:
				textCh = "A";
				break;
		}

		let iOffsetY = -18;
		let iOffsetX = 2;
		let iFontSize = 11;

		if (classMap.iZoom < 16)
		{
			iOffsetY = -10;
			iOffsetX = 2;
			iFontSize = 8;
		} else if (classMap.iZoom >= 18)
		{
			iOffsetY = -25;
			iOffsetX = 2;
			iFontSize = 12;
		}
		let textStyle = new ol.style.Style({
			text: new ol.style.Text({
				text: textCh,
				font: iFontSize + 'px FontAwesome',
				offsetY: iOffsetY,
				offsetX: iOffsetX,
				fill: new ol.style.Fill({ color: 'rgb(255,255,255)' }),
				stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1 })
			}),
			zIndex: 2
		});
		return (textStyle);
	}

	function removeAllMarkers()
	{
		// Remove all the markers except me.
		var iNum = classMap.positionList.length;
		for (var i = iNum - 1; i >= 0; i--)
		{
			if (g_myDeviceId === classMap.positionList[i].deviceId)
				classMap.positionList.splice(i, 1); // Remove myself from list, is created with init.
			else
				removeMarker(i);
		}
	}

	function validate_date(sDate) // Date dd.mm.yyyy
	{
		if (!sDate)
			return (false);
		if (sDate.length < 10)
			return (false);

		let iDay = parseInt(sDate.substr(0, 2));
		let iMonth = parseInt(sDate.substr(3, 2));
		let iYear = parseInt(sDate.substr(6, 4));

		if (iDay <= 0)
			return (false);

		if (iYear < 1900)
			return (false);
		if (iYear > 2100)
			return (false);

		switch (iMonth)
		{
			case 2:
				if (nss_is_leap_year(iYear))
				{
					if (iDay > 29)
						return (false);
				}
				else
				{
					if (iDay > 28)
						return (false);
				}
				break;

			case 1: // January
			case 3: // March
			case 5: // May
			case 7: // July
			case 8: // August
			case 10: // October
			case 12: // December
				if (iDay > 31)
					return (false);
				break;

			case 4: // April
			case 6: // June
			case 9: // September
			case 11: // November
				if (iDay > 30)
					return (false);
				break;

			default:
				return (false); // Month wrong.
		}
		return (true);
	}
	
	function getWarningOffset(iOffset)
	{
		if (classMap.iZoom >= 18)
		{
			iOffset = -30;
		}
		else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
		{
			iOffset = -20;
		}
		else if (classMap.iZoom < 16)
		{
			//iOffset = -10;
		}
		return (iOffset);
	}

//	let aStyleList = [];
	//createFlagLayer parametresine data, ajax tan asenkron bir sekilde geliyor ve map in olusturulmasi da asenkron islem sonucunda oldugu icin yani layer lar vs bilesenlerinin olusmasi yani. Ondan dolayi biz classMap.map i gidip disarda sennkron birsekilde kullanamayiz undefined aliriz...bunu bilelim.... Biz ancak classMap.map i ajax success durumundaki crateFlagLayer(data) parametrtesine ajax succes den gelen data verilerek invoke edildigikten sonra classMap.map i kullanabiliriz cunku o zaman arrtik olusmus oluyor...COOK ONEMLI BUNU BILMEK
	function createFlagLayer(aObjectList)
	{
	console.log("createFlagLayer is working")
	console.log("classMap.map-start: ",classMap.map.getLayers());
		var iconScale = classMap.iFlagSize;
		var iRotation = 0; //(iNumOrders * 0.3) - 0.3;

		// Clear the vecor layer.
		classMap.vectorFlagSource.clear(true);

		// Empty the array.
		classMap.iconFeatureList = []; // Empty the list.
		classMap.iconFeatureListWithoutStyle = [];

		try
		{
			// Loop through all the objects.
			for (let i = 0; i < aObjectList.length; i++)
			{
				let iconFeature = null;
				let iconFeatureForCluster = null;
				let bIsOrder = (aObjectList[i]['status'] === 'red' || aObjectList[i]['status'] === 'green' || aObjectList[i]['status'] === 'blue' || aObjectList[i]['status'] === 'orange') ? true : false;
				let sMessage = (aObjectList[i]['message']) ? aObjectList[i]['message'] : "";
				let sMessageOrd = (aObjectList[i]['messageord']) ? aObjectList[i]['messageord'] : "";
				let oLocation = nss_split_location(aObjectList[i]['position']);
				let bSkip = false;
				let sServiceValue = "";
				let sArrivalTime = ""; // Default value.
				let sFlagType = "1";

				if (parseFloat(oLocation.longitude) <= 0 && parseFloat(oLocation.latitude) <= 0)
					continue; // Skip zero longitude and latitude.

				let iObjectTypeId = parseInt(aObjectList[i]['object_type_id']);
				
				switch (aObjectList[i]['status'])
				{
					case 'red': // Red flag.
					case 'green': // Green flag.
					case 'blue': // Blue flag.
					case 'orange': // Orange flag.
					case 'ring': // No order, create a ring.
					case 'ring-orange': // Not paid for plowing.
					case 'ring-multi': // No order Multi.
					case 'ring-extra': // No order, extra.

						let aOrderList = [];

						//
						// Loop through all the orders for this object..
						for (let ii = 0; ii < aObjectList[i].orderlist.length; ii++)
						{
							//if ( !validate_date(aObjectList[i].orderlist[ii]['datefrom']))
							//	continue; // Just skip.

							let sObjectName = (aObjectList[i].orderlist[ii]['objname']) ? aObjectList[i].orderlist[ii]['objname'] : aObjectList[i]['objname'];

							if (aObjectList[i].orderlist[ii]['arrivaltime'])
								sArrivalTime = aObjectList[i].orderlist[ii]['arrivaltime'];
								
							aOrderList.push({
								firstname: aObjectList[i].orderlist[ii]['firstname'],
								middlename: aObjectList[i].orderlist[ii]['middlename'],
								lastname: aObjectList[i].orderlist[ii]['lastname'],
								objname: (aObjectList[i].orderlist[ii]['objname'] === null) ? "No name" : aObjectList[i].orderlist[ii]['objname'],
								address: sObjectName + ", " + aObjectList[i].orderlist[ii]['postcode'] + " " + aObjectList[i].orderlist[ii]['postcity'],
								mobile: aObjectList[i].orderlist[ii]['mobile'], // Contains the countrycode.
								datefrom: aObjectList[i].orderlist[ii]['datefrom'],
								dateto: aObjectList[i].orderlist[ii]['dateto'],
								alert: aObjectList[i].orderlist[ii]['alert'],
								arrivaltime: sArrivalTime,
								lateorder: aObjectList[i].orderlist[ii]['lateorder'],
								servicevalue: aObjectList[i].orderlist[ii]['servicevalue']
							});
							
							if (ii === 0) // Normall only one.
							{
								sFlagType = aObjectList[i].orderlist[ii]['flagtype']; // Get the flagtype.
								sServiceValue = aObjectList[i].orderlist[ii]['servicevalue']; // Only first, normally is only one.
							}
						}
						let sObjName = (aObjectList[i]['objname'] === null) ? "No name" : aObjectList[i]['objname'];

						iconFeature = new ol.Feature({
							ix: i, // The index.
							objectid: parseInt(aObjectList[i]['object_id']),
							objecttypeid: iObjectTypeId,
							geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(oLocation.longitude), parseFloat(oLocation.latitude)])),
							objname: sObjName,
							garbru: aObjectList[i]['garbru'],
							message: sMessage,
							messageord: sMessageOrd,
							status: aObjectList[i]['status'],
							servicename: (aObjectList[i]['servicename']) ? aObjectList[i]['servicename'] : "",
							servicetype: (aObjectList[i]['servicetype']) ? aObjectList[i]['servicetype'] : "",
							valuetype: (aObjectList[i]['valuetype']) ? aObjectList[i]['valuetype'] : "",
							validcont: aObjectList[i]['validcont'],
							continues: aObjectList[i]['continues'],
							servicevalue: sServiceValue, // Is with the order.
							isicon: true,
							orderidlist: aObjectList[i]['orderidlist'],
							isorder: bIsOrder,
							logstatusid: (aObjectList[i]['logstatusid']) ? aObjectList[i]['logstatusid'] : 0,
							logstatus: (aObjectList[i]['logstatusid']) ? aObjectList[i]['logstatusid'] : "",
							minold: parseInt(aObjectList[i]['minold']),
							timefinished: aObjectList[i]['timefinished'],
							orderlist: aOrderList
						});

						iconFeatureForCluster = new ol.Feature({
							objectid: parseInt(aObjectList[i]['object_id']),
							geometry: new ol.geom.Point(ol.proj.fromLonLat([parseFloat(oLocation.longitude), parseFloat(oLocation.latitude)])),
						});
						
						break;

					default: // Just skip.
						//console.log("Skip");
						bSkip = true;
						break;
				}
				// Skip to the next record.
				if (bSkip) // Skip to next.
					continue;

				let iconStyle = null;
				let iWarningOffset = -35;

				if (classMap.iZoom >= 18)
				{
					iWarningOffset = -55;
				} else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
				{
					iWarningOffset = -35;
				} else if (classMap.iZoom < 16)
				{
					iWarningOffset = -20;
				}

				let bIsFlag = false;
				// Create the flags.
				//
				// OBS! When continues order it should be an order, if not an error.
				switch (aObjectList[i]['status'])
				{
					case 'ring': // No order, create a ring.
						{
							iWarningOffset = getWarningOffset(iWarningOffset);
							
							let sImage = (aObjectList[i]['validcont'] === 'T') ? "img/cottage_green.svg" : nss_red_ring(g_bColorBlind);
							iconStyle = create_iconstyle(sImage, iconScale);
						}
						break;
						
					case 'ring-orange': // Not paid snowplow.
						{
							iWarningOffset = getWarningOffset(iWarningOffset);
							
							iconStyle = create_iconstyle("img/cottage_orange.svg", iconScale);
						}
						break;

					case 'ring-extra': // No order, extra ploving.
						{
							let iMinOld = parseInt(aObjectList[i]['minold']); // Days the order_service_status_log entry is.

							if (classMap.iZoom >= 18)
							{
								iWarningOffset = 10;
							}
							else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
							{
								iWarningOffset = 5;
							}
							else if (classMap.iZoom < 16)
							{
								//iWarningOffset = -5;
							}
							let sImage = null;
							if (aObjectList[i]['validcont'] === 'T')
							{
								if (iMinOld >{{@one_week_in_minutes}}) // One week.
								{
									sImage = "img/cottage_green.svg"; // Show the normal icon.
								}
								else if (iMinOld >{{@24_hours_in_minutes}}) // 24 hours
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
								sImage = nss_red_flag(g_bColorBlind);
							}
							iconStyle = create_iconstyle(sImage, iconScale);
						}
						break;

					case 'ring-multi':
						{
							if (classMap.iZoom >= 18)
							{
								iWarningOffset = -30;
							} else if (classMap.iZoom >= 16 && classMap.iZoom < 18)
							{
								iWarningOffset = -20;
							} else if (classMap.iZoom < 16)
							{
								//iWarningOffset = -10;
							}
							let sImage = (aObjectList[i]['validcont'] === 'T') ? "img/cottage_grey.svg" : "img/cottage_grey.svg";
							iconStyle = create_iconstyle(sImage, iconScale);
						}
						break;

					case 'red': // Red flag.
					case 'green': // Green flag.
					case 'blue': // Blue flag.
					case 'orange': // Orange flags.
						bIsFlag = true;
						iconStyle = getIconStyle(iObjectTypeId, aObjectList[i]['valuetype'], sServiceValue, iconScale, iRotation, aObjectList[i]['continues'], aObjectList[i]['status'], sFlagType);
						break;

					default: // Just skip.
						break;
				}
				if (iconStyle && iconFeature)
				{
					{{@if:is_snowplow}}
					let aStyleList = [];
				//	 aStyleList = [];

					aStyleList.push(iconStyle); // Add the icon style.

					if (g_bArrivalTime)
					{
						// If arrival time set the arrival time as a number on the flag 1-Morning, 2-Afternoon, 3-Eavning, 4-Night.
						switch (aObjectList[i]['status'])
						{
							case 'green':
							case 'blue':
							case 'orange':
							case 'red':
								if (sArrivalTime.length > 0)
								{
									var textStyle = create_textstyle_arrival(sArrivalTime);
									aStyleList.push(textStyle);
								}
								break;
						}
					}
					else
					{
						// If arrival time is not used, mark the flag as a 'A' for Arrival.
						if (sArrivalTime.length > 0)
						{
							var textStyle = create_textstyle_arrival("A");
							aStyleList.push(textStyle);
						}
					}

					if (g_bColorBlind)
					{
						var ch = "";
						switch (aObjectList[i]['status'])
						{
							case 'orange':
								ch = "O";
								break;

							case 'red':
								ch = "R";
								break;

							case 'green':
								ch = "G";
								break;

							case 'blue':
								ch = "B";
								break;
						}
						if (ch.length > 0)
						{
							var textStyle = create_textstyle_colorblind(ch);
							if (textStyle)
								aStyleList.push(textStyle);
						}
					}

					// Only for normal orders not continues.
					if (aObjectList[i].orderlist.length > 0 && g_bShowDateAboveFlag && bIsFlag && aObjectList[i]['continues'] !== 'T')
					{
						if (aObjectList[i].orderlist[0].dateto.length >= 10)
						{
							// Validate the date.
							let textStyle = create_textstyle_dateto(aObjectList[i].orderlist[0].dateto);
							if (textStyle)
								aStyleList.push(textStyle);
						}
					}

					switch (aObjectList[i]['status'])
					{
						case 'ring-multi':
							if (iObjectTypeId ==={{@object_type_parking}})
							{
								let textStyleMulti = create_textstyle_multi_parking();
								aStyleList.push(textStyleMulti); // Add the multi text icon.
							} else
							{
								let textStyleMulti = create_textstyle_multi();
								aStyleList.push(textStyleMulti); // Add the multi text icon.
							}
							break;

						case 'green':
						case 'blue':
						case 'orange':
						case 'red':
						case 'ring':
						case 'ring-orange':
						case 'ring-extra':
							break;
					}
					if ((sMessage && sMessage.length > 2) || (sMessageOrd && sMessageOrd.length > 2))
					{
						let textStyle = create_textstyle_warning(iWarningOffset);
						aStyleList.push(textStyle);
					}
					if (classMap.bHouseNo)
					{
						let sHouseNo = get_houseno(aObjectList[i]['objname']);
						let textStyle = create_textstyle_houseno(sHouseNo);
						aStyleList.push(textStyle);
					}
					iconFeature.setStyle(aStyleList); // Set the style.
					
					{{@else:is_snowplow}}
					
					let aStyleList = [];
					// aStyleList = [];

					aStyleList.push(iconStyle); // Add the icon style.

					if (g_bColorBlind)
					{
						var ch = "";
						switch (aObjectList[i]['status'])
						{
							case 'orange':
								ch = "O";
								break;

							case 'red':
								ch = "R";
								break;

							case 'green':
								ch = "G";
								break;

							case 'blue':
								ch = "B";
								break;
						}
						if (ch.length > 0)
						{
							var textStyle = create_textstyle_colorblind(ch);
							if (textStyle)
								aStyleList.push(textStyle);
						}
					}
					if (classMap.bHouseNo)
					{
						let sHouseNo = get_houseno(aObjectList[i]['objname']);
						let textStyle = create_textstyle_houseno(sHouseNo);
						aStyleList.push(textStyle);
					}
					
					iconFeature.setStyle(aStyleList); // Set the style.

					//iconFeature.setStyle(aStyleList); // Set the style.
					{{@end-if:is_snowplow}}

					// Update the list.
					classMap.iconFeatureList.push(iconFeature);
			
					classMap.iconFeatureListWithoutStyle.push(iconFeatureForCluster);
				

					
					
				}
			}
			// Pull all the flags onto the map.
			classMap.vectorFlagSource.addFeatures(classMap.iconFeatureList);
			classMap.clusterVectorFlagSource.addFeatures(classMap.iconFeatureListWithoutStyle);
		
		/*	
			classMap.vectorFlagSource.getFeatures().forEach(feature=>{
				console.log("getvectorFlagSourceKEYS: ",feature.getKeys());
			}) */
		//	console.log(classMap.vectorFlagSource.getFeatures().length)

			classMap.clusterForVectorFlagSource = new ol.source.Cluster({
				name:"clusterForVectorFlagSource",
				distance:100,
				//minDistance:parseInt(20,10),
				source:classMap.clusterVectorFlagSource,
		/*		geometryFunction: function(feature) {
					// use the feature's geometry as the clustering geometry
				//	console.log("feature-cluster: ",feature.get("count"));
				//zoomlevel 15 ustunde cluster i uygulama diyoruz
					if (classMap.map.getView().getZoom() > 16){
						return null;
					}else{
					//cluster uygulandiginda default features larin kendi style lari kaldirilsin
				
						return feature.getGeometry();
						
					}
					
				}, */
				
			})

		//	console.log("classMap.clusterForVectorFlagSource: ",classMap.clusterForVectorFlagSource);
		//	let bIsZoomLevelLessThen15 = false;

		/*	function arrangeClusterByZoomLevel(){
				console.log("arrangeClusterByZoomLevel");
				let source = null;
				if(classMap.map.getView().getZoom() < 18)
				{
					console.log("bIsZoomLevelLessThen15:  ",bIsZoomLevelLessThen15);
					//classMap.vectorFlagSource.getFeatures().every(feature=>feature.getStyle()) ||
					source = classMap.clusterForVectorFlagSource
					//Bu isi cozuyor ama maliyetli, performansi cok etkiliyor..
				 /*  if( !bIsZoomLevelLessThen15  )
					{
						console.log("TEsttttt");
						classMap.vectorFlagSource.getFeatures().forEach(feature=>{
								feature.setStyle(undefined)
						})
						
					} */

		/*			bIsZoomLevelLessThen15 = true;
					
				}else {
				
					source = classMap.vectorFlagSource
				}
				return source;
			} */


			
			const styleCache = {};
			
			 classMap.clusterFlagLayer = new ol.layer.Vector({ // Layer for the flags.
					//source: arrangeClusterByZoomLevel(), //617.satrrdaki classMap.map.getView().on() ile resolution degismesinde tetiklenen eventi yorum satiri yapmadan once burasi calisiyordu
					source: classMap.clusterForVectorFlagSource,//
					
				//	source:classMap.vectorFlagSource,
				//	maxResolution: 20,
					style: clusterStyle
					
				});

			 classMap.vectorFlagLayer = new ol.layer.Vector({
				source: classMap.vectorFlagSource,
				})	


				function clusterStyle (clusterFeature) {
			//	console.log("clusterStyle start");//cluster aktif oldugunda zoom-level a gore burasi surekli calisiyor dolayisi ile burda tum features lari donudurup setStyle i undefined cok mantikli bir is olmaz..zaten performans diye birsey kalmaz
				if(Array.isArray(clusterFeature.get('features')))
				{
			//	console.log("clusterStyle has clusterFeature.get('features')");

						const size = clusterFeature.get('features').length;
						let style = styleCache[size];

					if(size == 1){
					var selectedFeature = clusterFeature.get('features')[0];

					if (!style) {
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
					//	style = aStyleList;
				//	console.log("selectedFeaturesKeys: ",selectedFeature.get("objectid"))

			// Bunu kesinlikle calistirma bu cok agirlastiriyor mahvefiyor	
		/*		classMap.vectorFlagSource.getFeatures().forEach(feature=>{
						//console.log("getvectorFlagSourceKEYS: ",feature.getKeys());
					//	console.log("feature: ",feature.get("objectid"))
						if(selectedFeature.get("objectid") == feature.get("objectid"))
						{
							style = feature.getStyle();
						
						//	feature.setStyle(undefined); //..Bu patlatiyor bu sekilde olmaz
							
						}

					}) */
					//selectedFeature.setStyle(undefined); Bunu kullanirsak cluster icinde feature 1 olunca default yani bos bir point gosterir ama hic kullanmazsak style i hic gostermez... gostermek istemezsek hic kullanmayacagiz
					
					}
					else { 
						if (!style) {
						if(size > 300)	clusterFeature.getGeometry().setCoordinates([829082.0210344432, 8201686.945177869]);
						
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

					styleCache[size] = style;
					return style;
				}
					
			}



			classMap.map.on("click", (e)=>{
				console.log("event-coordinate: ", e.coordinate);
				classMap.clusterFlagLayer.getFeatures(e.pixel).then((clickedFeatures) => {
				if (clickedFeatures.length) {
				  // Get clustered Coordinates
				  const features = clickedFeatures[0].get('features');
				  //console.log("features-length: ",features.length);
				 
				if(Array.isArray(features)){
					features.forEach(item=>{
					console.log("name::: ",item.getKeys())
					
					})
					
					//  console.log("munfeatures2:")
					if (features.length > 1) {
						const extent = ol.extent.boundingExtent(
						features.map((r) => r.getGeometry().getCoordinates())
						);
						classMap.map.getView().fit(extent, {duration: 3500, padding: [100, 100, 100, 100]});
					}
					
				} 
				}
			  });
			})

	
			
			//vectorFlagLayer
			console.log("zoom-level: ",classMap.map.getView().getZoom());
		/*	classMap.map.on('moveend', function(event) {
			var zoomLevel = classMap.map.getView().getZoom();
			console.log('New zoom level: ' + zoomLevel); */
			//Zoomlevel 15 in altina dusunce sadece clustersource aktif oluyor ve vector source style ini undefined yapiyoruz nama burda cluster icindeki clusterFeature.get("features").length de length can not read properties oluyor onu da cozduk bu sekil hallolsa da her zoom level hareketi en az 20 kez tetikleniyor bu event ve her mouse hareketinde 20 kez tum features lar forEach ile donduruluyor bu surdurulemez baska bir cozum bulmak gerek
		/*	if(zoomLevel < 15) {
			classMap.vectorFlagSource.getFeatures().forEach(feature=>{
				feature.setStyle(undefined)
			})
			} */
			// Perform any necessary actions based on the new zoom level
		/*	}); */


			
	

		
		} catch (err)
		{
			console.log("ERROR: " + err.message);
		}
	}


	//Burda yapamazsin cunku bu map olusumu tamamen asenkrondur burda map i alamayiz cunku map i olusturan datalar biraz gec geliyor...bizim createFlagLayer methodu icinde calisma zorunlulugumuz var... ok.. 
//	console.log("classMap.map-outsideofCreateFlagLayer: ",classMap.map.getLayers());


	function get_houseno(sObjectName)
	{
		let sHouseNo = "";
		let aWords = sObjectName.split(" ");
		for (let i = 0; i < aWords.length; i++)
		{
			switch (aWords[i].substr(0, 1))
			{
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					sHouseNo = aWords[i];
					break;

				default:
					break;
			}
		}
		return (sHouseNo);
	}

	// Returns the seconds.
	function getTimeStamp()
	{
		let timenow = Math.floor(Date.now() / 1000); // Allways update first time.
		return (timenow);
	}

	function reportPositionToServer(oCoord)
	{
		// UPDATE the other on the map.
		//
		let iTimeElapse = (getTimeStamp() - classMap.timestampLastUpdatePos);

		if ((classMap.lastLon !== oCoord.longitude || classMap.lastLat !== oCoord.latitude) && iTimeElapse > g_iUpdateFleetInterval)
		{
			let speedkm = Math.floor((oCoord.speed * 18) / 5);

			// Save the position.
			classMap.lastLon = oCoord.longitude;
			classMap.lastLat = oCoord.latitude;
			classMap.lastHeading = oCoord.heading;
			classMap.lastAltitude = oCoord.altitude;
			classMap.lastSpeed = oCoord.speed;
			classMap.lastAccuracy = oCoord.accuracy;
			classMap.lastAltitudeAccuracy = oCoord.altitudeAccuracy;

			classMap.timestampLastUpdatePos = getTimeStamp();

			if (g_iPositionCount === 1)
			{
				let sData =
						  "INIT;" +
						  PROVIDER_ID + ";" +
						  USER_ID + ";" +
						  classMap.lastLon + ";" +
						  classMap.lastLat + ";" +
						  classMap.lastHeading + ";" +
						  classMap.lastAltitude + ";" +
						  speedkm + ";" +
						  oCoord.timestamp + ";" +
						  classMap.lastAccuracy + ";" +
						  classMap.lastAltitudeAccuracy + ";" +
						  classMap.sServiceTag;

				updatePosition(sData);
			}
			else
			{
				//Send data on Websocket
				let sData =
						  "POS;" +
						  PROVIDER_ID + ";" +
						  USER_ID + ";" +
						  classMap.lastLon + ";" +
						  classMap.lastLat + ";" +
						  classMap.lastHeading + ";" +
						  classMap.lastAltitude + ";" +
						  speedkm + ";" +
						  oCoord.timestamp + ";" +
						  classMap.lastAccuracy + ";" +
						  classMap.lastAltitudeAccuracy + ";" +
						  classMap.sServiceTag;

				updatePosition(sData);
			}
		}
	}

	//
	// Validate the position.
	function validatePosition(dLon, dLat, iAccuracy)
	{
		if (dLon === 0 && dLat === 0)
			return (false);

		if (iAccuracy > 40) // Meters
			return (false);

		return (true);
	}

	function setMyPosition(position)
	{
		let iUserId = USER_ID;

		// Check all values for null values.
		let iSpeed = (typeof position.coords.speed === 'undefined') ? 0 : (isNaN(position.coords.speed) ? 0 : position.coords.speed);
		let iHeading = (typeof position.coords.heading === 'undefined') ? 0 : (isNaN(position.coords.heading) ? 0 : position.coords.heading);
		let iAltitude = (typeof position.coords.altitude === 'undefined') ? 0 : (isNaN(position.coords.altitude) ? 0 : position.coords.altitude);
		let iAccuracy = (typeof position.coords.accuracy === 'undefined') ? 0 : (isNaN(position.coords.accuracy) ? 0 : position.coords.accuracy);
		let iAltitudeAccuracy = (typeof position.coords.altitudeAccuracy === 'undefined') ? 0 : (isNaN(position.coords.altitudeAccuracy) ? 0 : position.coords.altitudeAccuracy);
		let dLon = (typeof position.coords.longitude === 'undefined') ? 0 : (isNaN(position.coords.longitude) ? 0 : position.coords.longitude);
		let dLat = (typeof position.coords.latitude === 'undefined') ? 0 : (isNaN(position.coords.latitude) ? 0 : position.coords.latitude);
		let sTimeCoord = (position.coords.timestamp) ? position.coords.timestamp : "";

		if (!validatePosition(dLon, dLat, iAccuracy))
		{
			return (false); // Get out the coordinates are not ok.
		}

		// Save the accuracy and the heading.
		g_dHeading = position.coords.heading;
		g_dAccuracy = position.coords.accuracy;
		g_dSpeed = position.coords.speed;

		var oCoord = {
			longitude: dLon,
			latitude: dLat,
			accuracy: iAccuracy,
			altitude: iAltitude,
			altitudeAccuracy: iAltitudeAccuracy,
			heading: iHeading, // In degrees 0-360,
			speed: iSpeed,
			timestamp: sTimeCoord
		};

		//
		// Adding position for my own car.
		//
		if (!classMap.myPosition)
		{
			classMap.myPosition = {
				deviceId: g_myDeviceId,
				UserId: parseInt(iUserId),
				longitude: oCoord.longitude,
				latitude: oCoord.latitude,
				accuracy: parseInt(oCoord.accuracy),
				timestamp: null,
				feature: null
			};
		}
		g_myLastPos = ol.proj.transform([parseFloat(oCoord.longitude), parseFloat(oCoord.latitude)], 'EPSG:4326', 'EPSG:3857');

		var point = new ol.geom.Point(g_myLastPos);

		if (classMap.myPosition.feature)
		{
			// Move to new position
			classMap.myPosition.feature.setGeometry(point);
		} else
		{
			// Set the my position icon.
			var positionFeature = new ol.Feature({
				geometry: point
			});
			positionFeature.setStyle([classMap.iconStyleMe, classMap.textStyleMe]);

			// Put the new feature into the array.
			classMap.myPosition.feature = positionFeature;

			// Update the timestamp in seconds.
			classMap.myPosition.timestamp = getTimeStamp();

			// Move to new position
			classMap.myPosition.feature.setGeometry(point);

			// Add the feature.
			classMap.vectorPositonSource.addFeature(classMap.myPosition.feature);
		}
		//
		// Do not move the map when the popup is active.
		if (classMap.trackMode && classMap.bOkClickMap && classMap.bDeviceOrientation)
		{
			// Set the position at the center of the map
			classMap.view.setCenter(g_myLastPos);
		}
		// Report the position to the server, if it is time to report.

		reportPositionToServer(oCoord);
	}

	function removeMarker(ixPos)
	{
		// If found remove the feature / icon.
		if (ixPos >= 0)
		{
			if (classMap.positionList[ixPos].feature)
				classMap.vectorPositonSource.removeFeature(classMap.positionList[ixPos].feature);

			// Remove the element from the array.
			classMap.positionList.splice(ixPos, 1);
		}
	}

	function createMapPosition(iUserId, lon, lat, sDeviceId, Accuracy, sName, isMe)
	{
		var positionFeature = null;

		var oPosList = { deviceId: sDeviceId, UserId: parseInt(iUserId), longitude: lon, latitude: lat, accuracy: Accuracy, timestamp: getTimeStamp(), name: sName, feature: null};

		// Inser the item into the array and update the index.
		var ixPos = classMap.positionList.push(oPosList) - 1;

		if (!isMe)
		{
			// Set the icon position.
			positionFeature = new ol.Feature({
				geometry: new ol.geom.Point(ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857'))
			});

			classMap.textStyleOther = new ol.style.Style({
				text: new ol.style.Text({
					text: sName,
					font: 'bold 10px sans-serif',
					offsetY: 0,
					offsetX: 0,
					fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
					stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
				}),
				zIndex: 10
			});

			positionFeature.setStyle([classMap.iconStyleOther, classMap.textStyleOther]);

			// Put the new feature into the array.
			classMap.positionList[ixPos].feature = positionFeature;

			// Add the feature.
			classMap.vectorPositonSource.addFeature(classMap.positionList[ixPos].feature);

			// Update the timestamp.
			classMap.positionList[ixPos].timestamp = getTimeStamp();
		}
		return (ixPos);
	}

	// Display position for other.
	function setMapPosition(lon, lat, sDeviceId, ixPos)
	{
		if (lon === 0 && lat === 0)
			return (false);

		// Only change if the Session ID match.
		if (classMap.positionList[ixPos].deviceId === sDeviceId)
		{
			// Check if we have this set from before, just update the position.
			if (classMap.positionList[ixPos].feature) {
				// Set the new geometry
				classMap.positionList[ixPos].feature.setGeometry(new ol.geom.Point(ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857')));
			}
		}
		return (true);
	}

	//
	// Positin on and off
	function toggleTrackMode()
	{
		classMap.trackMode = !classMap.trackMode;

		if (classMap.trackMode)
		{
			// Reset the show buttons button.
			$("#button_remove").text("Skjul knapper");
			g_bToggleHideButtons = false;

			hideButtons();

			// Turn on compass function.
			classMap.bDeviceOrientation = true; // Rotate map
		} else
		{
			showButtons();

			// Turn off compass function.
			classMap.bDeviceOrientation = false; // Do not rotate map.
		}
	}

	function hideButtons()
	{
		$("#tooggleTrackMode").text("Posisjon er PÅ");

		$("#button_toggle_showall").hide();
		// Hide the buttons.
		if (g_bAreaDropdown)
		{
			$("#select_area_toggle").hide();
		} else
		{
			for (let i = 0; i < classMap.aPolygonList.length; i++)
			{
				$("#area_button_" + classMap.aPolygonList[i].id).hide();
			}
		}
		$("#button_remove").hide();
		$("#my-position").hide();
		$("#service_templates").hide();
		$("#search_ownerobject").hide();
		$("#toggle_compass").show();

		// The day buttons
		for (let i = 0; i < 7; i++)
		{
			$("#btn-" + i).hide();
		}
	}

	function showButtons()
	{
		$("#tooggleTrackMode").html("Posisjon er AV");

		$("#button_toggle_showall").show();
		if (g_bAreaDropdown)
		{
			$("#select_area_toggle").show();
		}
		else
		{
			for (let i = 0; i < classMap.aPolygonList.length; i++)
			{
				$("#area_button_" + classMap.aPolygonList[i].id).show();
			}
		}
		$("#button_remove").show();
		$("#my-position").show();
		$("#service_templates").show();
		$("#search_ownerobject").show();
		$("#toggle_compass").hide();

		// The day buttons
		for (var i = 0; i < 7; i++)
		{
			$("#btn-" + i).show();
		}
	}

	function buttonHideButtons()
	{
		$("#button_remove").text("Vis knapper");

		$("#button_toggle_showall").hide();
		// Hide the buttons.
		if (g_bAreaDropdown)
		{
			$("#select_area_toggle").hide();
		} else
		{
			for (let i = 0; i < classMap.aPolygonList.length; i++)
			{
				$("#area_button_" + classMap.aPolygonList[i].id).hide();
			}
		}
		$("#service_templates").hide();
		$("#search_ownerobject").hide();
		$("#toggle_compass").show();

		// The day buttons
		for (let i = 0; i < 7; i++)
		{
			$("#btn-" + i).hide();
		}
	}

	function buttonShowButtons()
	{
		$("#button_remove").text("Skjul knapper");

		$("#button_toggle_showall").show();
		if (g_bAreaDropdown)
		{
			$("#select_area_toggle").show();
		}
		else
		{
			for (let i = 0; i < classMap.aPolygonList.length; i++)
			{
				$("#area_button_" + classMap.aPolygonList[i].id).show();
			}
		}
		$("#service_templates").show();
		$("#search_ownerobject").show();
		$("#toggle_compass").hide();

		// The day buttons
		for (let i = 0; i < 7; i++)
		{
			$("#btn-" + i).show();
		}
	}

	function showArea(iAreaId)
	{
		for (var i = 0; i < classMap.aPolygonList.length; i++)
		{
			if (parseInt(classMap.aPolygonList[i].id) === parseInt(iAreaId))
			{
				// Create a style.
				var style = new ol.style.Style({
					stroke: new ol.style.Stroke({
						color: '#3300ff',
						width: 2
					}),
					fill: new ol.style.Fill({
						color: [90, 90, 90, 0]
					})
				});
				// Set the style for the feature.
				classMap.aPolygonList[i].feature.setStyle(style);

				// Create a new source with current feature.
				var vectorSource = new ol.source.Vector({
					features: [classMap.aPolygonList[i].feature]
				});
				var extent = vectorSource.getExtent();
				classMap.map.getView().fit(extent, classMap.map.getSize());
			} else
			{
				// Reset the style.
				classMap.aPolygonList[i].feature.setStyle(classMap.defaultStyle);
			}
		}
	}

	function toggleShowAll()
	{
		g_bShowAllAreas = !g_bShowAllAreas;

		if (g_bShowAllAreas)
		{
			// Change color on the buttons
			$("#button_toggle_showall").removeClass("nss_btn_primary");
			$("#button_toggle_showall").addClass("nss_btn_info");

			// Reload all.
			$.ajax({
				type: 'post',
				url: 'ajax_update_flags.php',
				data: {
					gettype: "getall",
					date: classMap.sDateToShow,
					showall: classMap.iShowAll,
					servicetemplateid: g_iSelectedServiceTemplateId,
					providerid: PROVIDER_ID,
					renting_provider_id: g_iRentingProviderId,
					areaid: 0, // Show all.
					logpos: g_iLastLogPos,
					mode: g_iServiceMode
				},
				error: function () {
					console.log("Feil: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");
				},
				success: function (sJsonRet) {
					//console.log(sJsonRet);
					let oRet = JSON.parse(sJsonRet); // Apiret
					if (oRet.bRet)
					{
						classMap.aFlags = oRet.aData.data;

						// Draw all the cottages.
						createFlagLayer(classMap.aFlags);
					} else
					{
						nss_message('danger', oRet.sMess);
					}
				}
			});
		}
		else
		{
			$("#button_toggle_showall").removeClass("nss_btn_info");
			$("#button_toggle_showall").addClass("nss_btn_primary");

			// Reload all.
			$.ajax({
				type: 'post',
				url: 'ajax_update_flags.php',
				data: {
					date: classMap.sDateToShow,
					showall: classMap.iShowAll,
					servicetemplateid: g_iSelectedServiceTemplateId,
					providerid: PROVIDER_ID,
					renting_provider_id: g_iRentingProviderId,
					areaid: g_iSelectedAreaId, // Show all.
					logpos: g_iLastLogPos,
					mode: g_iServiceMode,
					gettype: "getall"
				},
				error: function () {
					console.log("Feil: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");
				},
				success: function (sJsonRet) {
					//console.log(sJsonRet);
					let oRet = JSON.parse(sJsonRet); // Apiret
					if (oRet.bRet)
					{
						classMap.aFlags = oRet.aData.data;

						// Draw all the cottages.
						createFlagLayer(classMap.aFlags);
					} else
					{
						nss_message('danger', oRet.sMess);
					}
				}
			});
		}
	}

	//
	function initTrackingMode()
	{
		if (navigator.geolocation)
		{
			let options = getBrowserOptions(true);

			try
			{
				// Browser report position when the item is moved.
				g_iWathPosId = navigator.geolocation.getCurrentPosition(geolocationSuccess, geolocationError, options);
			} catch (err)
			{
				nss_message("danger", "FEIL! Geoloaction not working: " + err.message);
			}
		} else
		{
			nss_message("danger", "FEIL! Geolocation is not supported for this browser.");
		}
	}

	function updatePosition(oData)
	{
		$.ajax({
			type: 'post',
			url: 'ajax_tracklog.php',
			data: {
				act: 'create',
				data: oData
			},
			error: function () {
				console.log("FEIL: En feil oppstod ved kall til ajax_trakclog.php, forsøk på nytt.");
			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let oRet = JSON.parse(sJsonRet);

				if (oRet['e'] > 0)
				{
					nss_message("danger", "ERROR in update_position: " + Ret['m']);
				}
			}
		});
	}

	function OnButtonMyPosition()
	{
		if (g_myLastPos)
		{
			// Set default zoom for my position.
			classMap.view.setZoom(17);

			// Set my position at the center of the map
			classMap.view.setCenter(g_myLastPos);
		} else
		{
			nss_message("danger", "Posisjonen er ikke oppdatert ennå, du må først 'Slå på posisjon' vent til den oppdaterer seg. Så kan denne knappen brukes.");
		}
	}

	function OnClickAreaButton(iAreaId, bSnowPlow)
	{
		let iLastSelectedAreaId = g_iSelectedAreaId;
		g_iSelectedAreaId = iAreaId;

		if (iLastSelectedAreaId > 0)
		{
			// Change color on the buttons
			$("#area_button_" + iLastSelectedAreaId).removeClass("nss_btn_info");
			$("#area_button_" + iLastSelectedAreaId).addClass((bSnowPlow) ? "nss_btn_danger" : "nss_btn_primary");
		}
		if (g_iSelectedAreaId > 0)
		{
			$("#area_button_" + g_iSelectedAreaId).removeClass((bSnowPlow) ? "nss_btn_danger" : "nss_btn_primary");
			$("#area_button_" + g_iSelectedAreaId).addClass("nss_btn_info");
		}
		moveToArea(iAreaId);

		// Update the number of orders.
		updateAreaTotal(iAreaId);
	}

	function update_num_orders(aNumOrders)
	{
		// Update all the day buttons
		for (let i = 0; i < 7; i++)
		{
			let iNumTot = aNumOrders[i].numtot;
			let iNumArea = aNumOrders[i].numarea;
			let sNumText = (g_bMapShowAreaOrderTotal) ? iNumArea + "/" + iNumTot : iNumTot + "";

			$("#numorder-" + i).text(sNumText);
		}
	}

	// Updates the total orders on the day buttons.
	function updateAreaTotal(iAreaId)
	{
		$.ajax({
			type: 'post',
			url: 'ajax_gateway.php',
			data: {
				_class: 'ajax_orders',
				_func: 'get_numorders',
				startdate: classMap.sDateStart,
				servicetemplateid: g_iSelectedServiceTemplateId,
				providerid: PROVIDER_ID,
				areaid: iAreaId,
				servicetag: classMap.sServiceTag
			},
			error: function () {
				console.log("FEIL: En feil oppstod ved kall til ajax_orders, forsøk på nytt.");
			},
			success: function (sJsonRet) {
				//console.log(sJsonRet);
				let aNumOrders = JSON.parse(sJsonRet); // Apiret
				if (aNumOrders.length > 0)
				{
					update_num_orders(aNumOrders);
				}
			}
		});
	}

	function moveToArea(iAreaId)
	{
		if (g_bShowAllAreas)
		{
			// Draw all the flags.
			createFlagLayer(classMap.aFlags);

			// Show always all areas.
			showArea(iAreaId);
		} else
		{
			// Update the map and draw the new area if only display one area.
			$.ajax({
				type: 'post',
				url: 'ajax_update_flags.php',
				data: {
					date: classMap.sDateToShow,
					showall: classMap.iShowAll,
					servicetemplateid: g_iSelectedServiceTemplateId,
					providerid: PROVIDER_ID,
					renting_provider_id: g_iRentingProviderId,
					areaid: (g_bShowAllAreas) ? 0 : g_iSelectedAreaId,
					logpos: g_iLastLogPos,
					mode: g_iServiceMode,
					gettype: "getall"
				},
				error: function () {
					console.log("FEIL: En feil oppstod ved kall til ajax_update_flags.php, forsøk på nytt.");
				},
				success: function (sJsonRet) {
					//console.log(sJsonRet);
					let oRet = JSON.parse(sJsonRet); // Apiret
					if (oRet.bRet)
					{
						classMap.aFlags = oRet.aData.data;

						// Draw all the cottages.
						createFlagLayer(classMap.aFlags);

						// Show the areas.
						showArea(iAreaId);
					} else
					{
						nss_message('danger', oRet.sMess);
					}
				}
			});
		}
	}

	function OnChangeArea()
	{
		var iSelectedArea = $("#select_areaid").val();

		moveToArea(iSelectedArea);
	}

	function OnButtonRemoveButtons()
	{
		g_bToggleHideButtons = !g_bToggleHideButtons;
		if (g_bToggleHideButtons)
			buttonHideButtons();
		else
			buttonShowButtons();
	}

	function OnClickChangeMap()
	{

	}

	function OnClickMyPage()
	{
		if (g_iWathPosId)
			navigator.geolocation.clearWatch(g_iWathPosId);

		// Stop the timer.
		if (classMap.oTimer)
			clearInterval(classMap.oTimer);
		classMap.oTimer = null;

		nss_post("admin_menu.php", { act: 'default'});
	}

	//
	// module:ol/interaction/DragRotate~DragRotate
	// module:ol/interaction/DoubleClickZoom~DoubleClickZoom
	// module:ol/interaction/DragPan~DragPan
	// module:ol/interaction/PinchRotate~PinchRotate
	// module:ol/interaction/PinchZoom~PinchZoom
	// module:ol/interaction/KeyboardPan~KeyboardPan
	// module:ol/interaction/KeyboardZoom~KeyboardZoom
	// module:ol/interaction/MouseWheelZoom~MouseWheelZoom
	// module:ol/interaction/DragZoom~DragZoom
	//
	function freezeMap()
	{
		if (!classMap.bTogglePan) // Pan is off and also device orientation.
		{
			//
			// Change the Pan settings.
			classMap.map.getInteractions().forEach(function (interaction) {
				if (interaction instanceof ol.interaction.DragPan) {
					interaction.setActive(true); // Turn off the no pan.
				}
			}, this);
		} else
		{
			classMap.bDeviceOrientation = false; // Do not rotate map.
		}

		/*
		 //
		 // Change the Pan settings.
		 classMap.map.getInteractions().forEach(function(interaction) {
		 if (interaction instanceof ol.interaction.DragPan) {
		 interaction.setActive(false);
		 }
		 if (interaction instanceof ol.interaction.DragRotate) {
		 interaction.setActive(false);
		 }
		 if (interaction instanceof ol.interaction.DragZoom) {
		 interaction.setActive(false);
		 }
		 }, this);
		 * 
		 */
	}

	function unFreezeMap()
	{
		if (!classMap.bTogglePan) // Pan is off
		{
			//
			// Change the Pan settings.
			classMap.map.getInteractions().forEach(function (interaction) {
				if (interaction instanceof ol.interaction.DragPan) {
					interaction.setActive(false); // Turn on the no pan.
				}
			}, this);
		}
		else
		{
			classMap.bDeviceOrientation = true; // allow rotation of the map.
		}
		/*
		 //
		 // Change the Pan settings.
		 classMap.map.getInteractions().forEach(function(interaction) {
		 if (interaction instanceof ol.interaction.DragPan) {
		 interaction.setActive(true);
		 }
		 if (interaction instanceof ol.interaction.DragRotate) {
		 interaction.setActive(true);
		 }
		 if (interaction instanceof ol.interaction.DragZoom) {
		 interaction.setActive(true);
		 }
		 }, this);
		 * 
		 */
	}

	//
	// Turn off Pan and Trackmode.
	function onClickTogglePan()
	{
		classMap.bTogglePan = !classMap.bTogglePan;

		if (classMap.bTogglePan)
		{
			// Change class.
			$("#button_freeze").removeClass("nss_btn_warning");
			$("#button_freeze").addClass("nss_btn_danger");

			// Set the button text
			$("#button_freeze").text("Frys kart er AV");

			// Turn on compass function.
			classMap.bDeviceOrientation = true; // Rotate map
		} else
		{
			// Change class
			// 
			$("#button_freeze").removeClass("nss_btn_danger");
			$("#button_freeze").addClass("nss_btn_warning");

			// Set the button text
			$("#button_freeze").text("Frys kart er PÅ");

			// Turn on compass function.
			classMap.bDeviceOrientation = false; // Do not rotate map.
		}

		//
		// Change the Pan settings.
		classMap.map.getInteractions().forEach(function (interaction) {
			if (interaction instanceof ol.interaction.DragPan) {
				interaction.setActive(classMap.bTogglePan);
			}
		}, this);
	}
	/*
	 function getOverlayOffsets(mapInstance, overlay)
	 {
	 const overlayRect = overlay.getElement().getBoundingClientRect();
	 const mapRect = mapInstance.getTargetElement().getBoundingClientRect();
	 const margin = 15;
	 // if (!ol.extent.containsExtent(mapRect, overlayRect)) //could use, but need to convert rect to extent
	 const offsetLeft = overlayRect.left - mapRect.left;
	 const offsetRight = mapRect.right - overlayRect.right;
	 const offsetTop = overlayRect.top - mapRect.top;
	 const offsetBottom = (overlayRect.bottom===overlayRect.top) ? (mapRect.bottom - (overlayRect.bottom + 553)) : (mapRect.bottom - overlayRect.bottom);
	 //console.log('offsets', offsetLeft, offsetRight, offsetTop, offsetBottom);
		 
	 const delta = [0, 0];
	 if (offsetLeft < 0) {
	 // move overlay to the right
	 delta[0] = margin - offsetLeft;
	 } else if (offsetRight < 0) {
	 // move overlay  to the left
	 delta[0] = -(Math.abs(offsetRight) + margin);
	 }
	 if (offsetTop < 0) {
	 // will change the positioning instead of the offset to move overlay down.
	 delta[1] = margin - offsetTop;
	 } else if (offsetBottom < 0) {
	 // move overlay up - never happens if bottome-center is default.
	 delta[1] = -(Math.abs(offsetBottom) + margin);
	 }
	 return (delta);
	 }
	 */
	/*
	 function moveOverlayInsideMap(coordinate)
	 {
	 //classMap.popup.setPosition(coordinate);
	 classMap.popup.setOffset([0, 0]); // restore default
	 classMap.popup.setPositioning('bottom-right'); // restore default
	 //classMap.popup.set('autopan', true, false); //only need to do once.
	 classMap.popup.setPosition(coordinate);
	 const delta = getOverlayOffsets(classMap.map, classMap.popup);
		 
	 if (delta[1] > 0)
	 {
	 classMap.popup.setPositioning('bottom-center');
	 }
	 //classMap.popup.setOffset(delta);	
	 const size = classMap.map.getSize();
	 const overlayRect = classMap.popup.getElement().getBoundingClientRect();
		 
	 // Move the popover inside the page.
	 classMap.view.centerOn(coordinate, size, [ overlayRect.x+parseInt(delta[0]), overlayRect.y+parseInt(delta[1]) ]);
	 }
	 */
	//
	// Update the feature.
	function updateFlagFeature(feature, sNewStatus, iObjectTypeId)
	{
		let sValueType = feature.get('valuetype');
		let sServiceValue = feature.get('servicevalue');
		let sContinues = feature.get('continues');

		let iRotation = 0;
		let iconScale = classMap.iFlagSize;
		let sFlagType = "1"; // Normal.

		// Change for the 
		let iconStyle = getIconStyle(iObjectTypeId, sValueType, sServiceValue, iconScale, iRotation, sContinues, sNewStatus, sFlagType);
		if (iconStyle)
		{
			let sMessage = feature.get("message");
			let sMessageOrd = feature.get("messageord");
			let iIx = feature.get("ix"); // Get the index.
			//
			// Set the status in the global list.
			classMap.aFlags[iIx].status = sNewStatus;

			if ((sMessage && sMessage.length > 2) || (sMessageOrd && sMessageOrd.length > 2))
			{
				let textStyle = new ol.style.Style({
					text: new ol.style.Text({
						text: '\uf071',
						font: '18px FontAwesome',
						offsetY: -30,
						offsetX: 0,
						fill: new ol.style.Fill({ color: 'rgb(0,0,0)'}),
						stroke: new ol.style.Stroke({ color: 'rgb(255,255,255)', width: 1})
					}),
					zIndex: 2
				});
				feature.setStyle([iconStyle, textStyle]);
			} else
			{
				feature.setStyle(iconStyle);
			}
			// Change status in the array.
			feature.setProperties({ status: sNewStatus});
		}
	}

</script>
<!-- Map buttons GG777 -->
<script type="text/javascript" src="js/nss_util.js"></script>
{{@command:split}}
<div id="map" class="map"></div>
<div id="position-layer"></div>
<div id="popup"></div>
<div id="areaname"></div>
<div class="nss_map_knapperad">
	{{@if:is_service_mode_plower}}
		<button class="nss_btn_danger mb-1" href="#" onclick="OnClickMyPage();">Min side</button>
		{{@if:is_toggle_pan}}
			<a id="button_freeze" class="nss_btn_danger mb-1" style="position:fixed; left:10px; bottom:12px; margin:12px; padding:10px;" href="#" onclick="onClickTogglePan();">Frys kart er AV</a>
		{{@end-if:is_toggle_pan}}
		<button id="tooggleTrackMode" class="nss_btn_primary mb-1" onclick="toggleTrackMode();">Posisjon er PÅ</button>
		<button class="nss_btn_primary mb-1" id="my-position" onclick="OnButtonMyPosition();">Min pos.</button>
		<button class="nss_btn_primary mb-1" id="button_remove" onclick="OnButtonRemoveButtons();">Skjul knapper</button>
		{{@if:is_show_all_areas}}
			<button class="nss_btn_primary mb-1" id="button_toggle_showall" name="button_toggle_showall" onclick="toggleShowAll();">Alle</button>
		{{@end-if:is_show_all_areas}}
		{{@if:is_area_dropdown}}
			<div class="nss_map_select mt-1 mb-1" id="select_area_toggle" >
				<select class="select" data-mdb-filter="true" id="select_areaid" onchange="OnChangeArea();">
					{{@loop:servicearealist}}
					<option value="{{@servicearealist:id}}">{{@servicearealist:name}}</option>
					{{@end-loop:servicearealist}}
				</select>
			</div>
		{{@else:is_area_dropdown}}
			{{@loop:servicearealist}}
				<button class="nss_btn_danger mb-1" id="area_button_{{@servicearealist:id}}" name="area_button_{{@servicearealist:id}}" onclick="OnClickAreaButton({{@servicearealist:id}}, true);">{{@servicearealist:name}}</button>
			{{@end-loop:servicearealist}}
		{{@end-if:is_area_dropdown}}
		{{@if:is_plower_search}}
			<span id="search_ownerobject">
				<div id="search_ownerobject_container" class="input-group form-outline autocomplete nss_map_input">
					<span><i class="fa fa-search p-2" aria-hidden="true"></i></span>
					<input class="form-control" placeholder="Finn person eller hytte" value="" style="display: inline;" >
				</div>
			</span>
		{{@end-if:is_plower_search}}
		{{@if:is_show_day_buttons}}
		<div class="nss_map_day_btn">
			{{@loop:daybuttonlist}}
			   <button id="btn-{{@daybuttonlist:day}}" class="{{@daybuttonlist:class}} nss_map_day_btn_list" onclick="OnReloadFlags('{{@daybuttonlist:date}}',{{@daybuttonlist:day}});">{{@daybuttonlist:todaynum}}&nbsp;(<span id="numorder-{{@daybuttonlist:day}}">{{@daybuttonlist:numorders}}</span>)<br><div class="map-button-weekdays">{{@daybuttonlist:dayname}}</div></button>
			{{@end-loop:daybuttonlist}}
		</div>
		{{@end-if:is_show_day_buttons}}
	{{@else:is_service_mode_plower}} 
		<button class="nss_btn_danger mb-1" style="margin-top: -5px; height: 10px; min-width: 100px; "href="#" onclick="OnClickMyPage();">Min side</button>												
		{{@if:is_show_all_areas}}
			<button class="nss_btn_primary mb-1" id="button_toggle_showall" name="button_toggle_showall" onclick="toggleShowAll();">Alle</button>
		{{@end-if:is_show_all_areas}}
		{{@if:is_area_dropdown}}
		<span class="nss_map_select mb-1" id="select_area_toggle">
			<select class="select" id="select_areaid" onchange="OnChangeArea();" >
				{{@loop:servicearealist}}
				<option value="{{@servicearealist:id}}" >{{@servicearealist:name}}</option>
				{{@end-loop:servicearealist}}
			</select>
		</span>
		{{@else:is_area_dropdown}}
			{{@loop:servicearealist}}
				<button class="nss_btn_primary mb-1" id="area_button_{{@servicearealist:id}}" name="area_button_{{@servicearealist:id}}" onclick="OnClickAreaButton({{@servicearealist:id}}, false);">{{@servicearealist:name}}</button>
			{{@end-loop:servicearealist}}
		{{@end-if:is_area_dropdown}}
		{{@if:is_admin_search}}
			<span id="search_ownerobject">
				<div id="search_ownerobject_container" class="input-group form-outline autocomplete nss_map_input">
					<span><i class="fa fa-search p-2" aria-hidden="true"></i></span>
					<input class="form-control"  placeholder="Finn person eller hytte" value="" >
				</div>
			</span>
		{{@end-if:is_admin_search}}
		{{@if:is_show_day_buttons}}
		<div class="nss_map_day_btn">
			{{@loop:daybuttonlist}}
			<button id="btn-{{@daybuttonlist:day}}" class="{{@daybuttonlist:class}} nss_map_day_btn_list" onclick="OnReloadFlags('{{@daybuttonlist:date}}',{{@daybuttonlist:day}});">{{@daybuttonlist:todaynum}}&nbsp;(<span id="numorder-{{@daybuttonlist:day}}">{{@daybuttonlist:numorders}}</span>)<br><div class="map-button-weekdays">{{@daybuttonlist:dayname}}</div></button>
			{{@end-loop:daybuttonlist}}
		</div>
		{{@end-if:is_show_day_buttons}}
	{{@end-if:is_service_mode_plower}}
</div>

<div id="domMessage" style="display:none;">
	<h1>Vent...<img src="img/loading.gif"></h1>
</div>