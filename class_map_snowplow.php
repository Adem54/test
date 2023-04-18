<?php
//
// class_map - SNOWPLOW
//
require_once "../dep/class_util.php";
require_once "../dep/class_log.php";
require_once "../dep/class_texts.php";
require_once "../map/class_map_basic.php";
require_once "../custom/class_custom_service.php";
require_once "../depDL/class_DL_predefined_texts.php";

final class class_map extends class_map_basic
{
	function __construct(bool $bMapReadOnly, $sMapType=self::MAP_TYPE_NORMAL) {
		parent::__construct($bMapReadOnly, $sMapType);
	}

	public function allowToOrder(): bool
	{
		$sAllowOrder = class_util::getSetting(class_DL_settings::SETTING_MAP_SNOWPLOW_ALLOW_TO_ORDER);
		$bAllow = (strcasecmp($sAllowOrder, "YES") == 0);

		return ($bAllow);
	}

	//
	// mapClick - snowplow 
	public function mapClick(string $sServiceTag): string
	{
		ob_start();
		?>
		<script>

		function setOrderStatus(iStatus, sNewStatus, iObjectId, aOrderIdList, bLogEvent, bSendSms, bEmergencyChecked)
		{
			for (let i = 0; i < classMap.iconFeatureList.length; i++)
			{
				let iFeatureObjectId = parseInt(classMap.iconFeatureList[i].get('objectid'));

				if (iFeatureObjectId===parseInt(iObjectId))
				{
					let feature = classMap.iconFeatureList[i];
					let sSmsText = $("#input_text_message").val();
					let iObjectTypeId = feature.get('objecttypeid');

					// Update the database status.
					$.ajax({
						type: 'post',
						url: 'ajax_set_order_status.php',
						data: {
							status: iStatus,
							objecttypeid: iObjectTypeId,
							orderidlist: aOrderIdList,
							servicetemplateid: g_iSelectedServiceTemplateId,
							smstext: sSmsText,
							logevent: (bLogEvent)?1:0,
							sendsms: (bSendSms)?1:0,
							emergency: (bEmergencyChecked)?1:0
						},
						error: function () {
							nss_alert('Feil',"Forsøk på nytt.");
						},
						success: function (sJsonRet) {
							//console.log(sJsonRet);
							let aRet = JSON.parse(sJsonRet);
							if (aRet.bRet)
							{
								//let sNewStatus = 'green';
								let aObjectList = aRet.aData;

								//
								// Update the feature.
								updateFlagFeature(feature, sNewStatus, iObjectTypeId);

								//
								// Set status for the rest of the objects.
								for (let iObj=0; iObj<aObjectList.length; iObj++)
								{
									let iCurrObjectId = parseInt(aObjectList[iObj]);
									if (iFeatureObjectId===iCurrObjectId) // Done before.
										continue; // Just skip.

									// Loop through all the features to find the object.
									for (let i = 0; i < classMap.iconFeatureList.length; i++)
									{
										let iTempObjectId = parseInt(classMap.iconFeatureList[i].get('objectid'));
										if (iTempObjectId===iCurrObjectId)
										{				
											let feature = classMap.iconFeatureList[i];
											let iObjectTypeId = feature.get('objecttypeid');

											updateFlagFeature(feature, sNewStatus, iObjectTypeId);
										}
									}
								}
							}
							else
							{
								nss_alert('Feil',"Forsøk på nytt.");
							}
						}
					});
					break; // Get out of the loop.
				}
			}
		}

		function OnButtonFinishedAdmin(iObjectId, aOrderIdList)
		{
			let bEmergencyChecked = false;
			if (classMap.bPlowingEmergency)
				bEmergencyChecked = $("#check_emergency").is(':checked');
			
			console.log("Hallo");
			
			nss_confirm_3button(
				'Advarsel',
				'<b>Sette status på ordre, du kan velge mellom følgende:</b><br><br>'+
					'1) Godkjenn på vanlig måte, ordren blir registrert og det sendes en sms, klikk "Godkjenn".<br><br>'+
					'2) Bare endre status, flagget blir grønt men ingen registrering eller SMS. klikk "Ingen SMS".<br><br>'+
					'Bruk avbryte knappen for ingen endring.',
				"Godkjenn",
				"Ingen SMS",
				"Avbryt",
				function() {
					OnButtonFinished(iObjectId, aOrderIdList,true,true,bEmergencyChecked);
				},
				function() {
					OnButtonFinished(iObjectId, aOrderIdList,false,false,bEmergencyChecked);
				},
				function() {
					// Just terminate.
				}
			);
 
			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonFinishedNormal(iObjectId, aOrderIdList)
		{
			let bEmergencyChecked = false;
			if (classMap.bPlowingEmergency)
				bEmergencyChecked = $("#check_emergency").is(':checked');
			
			OnButtonFinished(iObjectId, aOrderIdList, true, true, bEmergencyChecked);
		}

		//
		// Mark the object as finished.
		function OnButtonFinished(iObjectId, aOrderIdList, bLogEvent, bSendSms, bEmergencyChecked)
		{
			setOrderStatus(ORDER_STATUS_FINISHED,'green',iObjectId, aOrderIdList, bLogEvent, bSendSms, bEmergencyChecked);
			
			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonFinishedNotAdmin(iObjectId, aOrderIdList)
		{
			nss_confirm_3button(
				'Advarsel',
				'<b>Sette status på ordre, du kan velge mellom følgende:</b><br><br>'+
					'1) Godkjenn på vanlig måte, ordren blir registrert og det sendes en sms, klikk "Godkjenn".<br><br>'+
					'2) Bare endre status, flagget blir blått men ingen SMS blir sendt. klikk "Ingen SMS".<br><br>'+
					'Bruk avbryte knappen for ingen endring.',
				"Godkjenn",
				"Ingen SMS",
				"Avbryt",
				function() {
					OnButtonFinishedNot(iObjectId, aOrderIdList,true,true);
				},
				function() {
					OnButtonFinishedNot(iObjectId, aOrderIdList,true,false);
				},
				function() {
					// Just terminate.
				}
			);
			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonFinishedNotNormal(iObjectId, aOrderIdList)
		{
			OnButtonFinishedNot(iObjectId, aOrderIdList, true, true);
		}

		//
		// Set status to finished but it is not plowed.
		function OnButtonFinishedNot(iObjectId, aOrderIdList, bLogEvent, bSendSms)
		{
			setOrderStatus(ORDER_STATUS_FINISHED_NOT, 'blue', iObjectId, aOrderIdList, bLogEvent, bSendSms, false);
			
			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonReactivateNotAdmin(iObjectId, aOrderIdList)
		{
			OnButtonReactivate(iObjectId, aOrderIdList, true, false);
		}

		function OnButtonReactivateNotNormal(iObjectId, aOrderIdList)
		{
			OnButtonReactivate(iObjectId, aOrderIdList, true, false);
		}

		//
		// Set status back to ordered.
		function OnButtonReactivateNot(iObjectId, aOrderIdList, bLogEvent, bSendSms)
		{
			setOrderStatus(ORDER_STATUS_ORDERED, 'red', iObjectId, aOrderIdList, bLogEvent, bSendSms, false);

			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonReactivateAdmin(iObjectId, aOrderIdList)
		{
			nss_confirm_3button(
				'Advarsel',
				'<b>Sette status på ordre, du kan velge mellom følgende:</b><br><br>'+
				'1) Feillevering på vanlig måte, ordren blir registrert og det sendes en sms, klikk "Feillevering".<br><br>'+
				'2) Bare feillevering, flagget blir rødt men ingen registrering eller SMS. klikk "Ingen SMS".<br><br>'+
				'Bruk avbryte knappen for ingen endring.',
				"Feillevering",
				"Ingen SMS",
				"Avbryt",
				function() {
					OnButtonReactivate(iObjectId, aOrderIdList, true, true);
				},
				function() {
					OnButtonReactivate(iObjectId, aOrderIdList, true, false);
				},
				function() {
					// Just terminate.
				}
			);
			OnButtonDestroyPopup(); // Destroy the popup.
		}

		function OnButtonReactivateNormal(iObjectId, aOrderIdList)
		{
			OnButtonDestroyPopup(); // Remove the popup.

			nss_confirm_yesno(
				'Advarsel',
				"<b>Du er nå i ferd med å endre status tilbake til bestilt.</b><br><br>Dette medfører at det vil gå en SMS til hytteeier med beskjed om at foregående SMS var feil",
				'Ja',
				'Nei',
				function () {
					OnButtonReactivate(iObjectId, aOrderIdList, true, true);
				},
				function () {
					
				}
			);
		}

		function OnButtonReactivate(iObjectId, aOrderIdList, bLogEvent, bSendSms)
		{
			let sSmsText = $("#input_text_message").val();
			
			OnButtonDestroyPopup(); // Destroy the popup.

			for (let i = 0; i < classMap.iconFeatureList.length; i++)
			{
				let iFeatureObjectId = parseInt(classMap.iconFeatureList[i].get('objectid'));

				if (iFeatureObjectId===parseInt(iObjectId))
				{
					let feature = classMap.iconFeatureList[i];
					let iObjectTypeId = feature.get('objecttypeid');

					$.ajax({
						type: 'post',
						url: 'ajax_set_order_status.php',
						data: {
							status: ORDER_STATUS_FINISHED_WRONG,
							objecttypeid: iObjectTypeId,
							orderidlist: aOrderIdList,
							servicetemplateid: g_iSelectedServiceTemplateId,
							smstext: sSmsText,
							logevent: (bLogEvent)?1:0,
							sendsms: (bSendSms)?1:0

						},
						error: function () {
							console.log("Feil: En feil oppstod ved kall til ajax_set_order_status.php, forsøk på nytt.");
						},
						success: function (aJsonRet) {
							let aRet = JSON.parse(aJsonRet);

							if (aRet.bRet)
							{
								let sNewStatus = 'red';
								let aObjectList = aRet.aData;

								//
								// Update the feature.
								updateFlagFeature(feature, sNewStatus, iObjectTypeId);
								//
								// Set status for the rest of the objects.
								for (let iObj=0; iObj<aObjectList.length; iObj++)
								{
									let iCurrObjectId = parseInt(aObjectList[iObj]);
									if (iFeatureObjectId===iCurrObjectId) // Done before.
										continue; // Just skip.

									// Loop through all the features to find the object.
									for (let i = 0; i < classMap.iconFeatureList.length; i++)
									{
										let iTempObjectId = parseInt(classMap.iconFeatureList[i].get('objectid'));
										if (iTempObjectId===iCurrObjectId)
										{				
											let feature = classMap.iconFeatureList[i];
											let iObjectTypeId = feature.get('objecttypeid');

											updateFlagFeature(feature, sNewStatus, iObjectTypeId);
										}
									}
								}
							}
							else
							{
								nss_alert('Feil',"Forsøk på nytt.");
							}
						}
					});
					break; // Get out of the loop.
				}
			}
		}
		
		function clearAreaNameTimeout()
		{
			if (g_timeoutAreaName)
			{
				window.clearTimeout(g_timeoutAreaName);
				g_timeoutAreaName = null;
				// Remove the area name.
				$("#areaname").css("display", "none");
			}
		}

		function mapClick(evt)
		{
			if (classMap.bOkClickMap) // Check if inside popup.
			{

				classMap.clusterFlagLayer.getFeatures(evt.pixel).then((clickedFeatures) => 
				{
					console.log("clickedFeaturesSSSSSS-SNOWPLOW: ",clickedFeatures);
					let feature = classMap.map.forEachFeatureAtPixel(evt.pixel,
					function (feature, layer) {
						return feature;
					},
					{
						layerFilter:function(oLayer)
						{
						
							
							if(oLayer.get("name") == "polygonLayer")
							{
								if (clickedFeatures.length && clickedFeatures.length > 0) 
								{
									
									let isClusterInsidePolygonLayer = oLayer.getSource().getFeaturesAtCoordinate(evt.coordinate);
								//	console.log("isClusterInsidePolygonLayer: ",isClusterInsidePolygonLayer); 
									if(isClusterInsidePolygonLayer && isClusterInsidePolygonLayer.length > 0)
									{
										
										console.log("isClusterInsidePolygonLayer && isClusterInsidePolygonLayer.length > 0");
										return (oLayer.get("name") !== "clusterLayer" && oLayer.get("name") !== "polygonLayer");
									}else{
										console.log("isClusterInsidePolygonLayer && isClusterInsidePolygonLayer.length < 0");

										return oLayer.get("name") !== "clusterLayer";
									}
								
								}else{
									return oLayer.get("name") !== "clusterLayer" ;
								} 
							}
								
							
							
						}
					}
				);	
							

				if (feature)
				{
					let sGarBru = " (" + feature.get('garbru') + ")";

					let iMainObjectId = feature.get("objectid");
					let isIcon = feature.get("isicon");
					let sObjNameGarBru = feature.get('objname')+sGarBru;
					let sObjName = feature.get('objname');
					let aOrderIdList = feature.get('orderidlist');
					let bIsOrder = feature.get('isorder');
					let bIsValidContract = (feature.get('validcont') === 'T') ? true : false;
					let sValueType = feature.get('valuetype');
					//let sServiceValue = feature.get('servicevalue');
					let sMessage = feature.get("message");
					let sMessageOrd = feature.get("messageord");
					let sServiceTypeText = feature.get('servicename');
					let sObjectStatus = feature.get("status");
					let aOrderList = feature.get('orderlist');
					let iLogStatusId = parseInt(feature.get('logstatusid'));
					//let sLogStatus = feature.get('logstatus');
					let iLogStatusMinOld = parseInt(feature.get("minold"));
					let sTimeFinished = feature.get("timefinished");
					
					// Check if this feature is a icon feature and not a polygon.
					if (isIcon)
					{
						let geometry = feature.getGeometry();
						let coord = geometry.getCoordinates();
						classMap.popup.setPosition(coord);
						
						let sObjectName = "";

						classMap.bOkClickMap = false; // Inside popup do not popup more.
						//classMap.map.un('click', mapClick);

						//classMap.popup.getElement().popover('show');
						classMap.popup.getElement().style.display = '';
						
						//
						// Freeze the map.
						freezeMap();

						let sInputHidden = "";
						let sInputImage = '<div class="nss_popup_margin" id="object_images" style="display: none; width: 100%;"></div>';
						let sInputComment = "";

						<?php
						// This is a readonly user.
						if ( !$this->m_bMapReadOnly)
						{
							?>
							sInputHidden += '<div id="sms_picture_buttons" class="gy-2 col-sm-12 d-flex justify-content-between mb-3" style="padding: 0px;">';
							sInputHidden += '<button class="nss_btn_primary" style="margin-top: 0.3em;" onclick="OnClickHideEvent();" title="Lage en sak på en hendelse.">Hendelse</button>';
							
							sInputComment += '<div class="gy-2 nss_popup_margin" id="create_event" style="display: none;">';
							sInputComment += '<div><input id="event_message_on_sms" type="checkbox">&nbsp;&nbsp;Send melding</div><div style="height: 10px;"></div>';
							<?php
							$DB = new class_dbpdo();
							$iProviderId = class_util::getProviderId();

							// Show a dropdown with some values from a table, if any.
							$aPreDefTexts = class_DL_predefined_texts::get_all_provider_servicetag_trans($DB, $iProviderId, $sServiceTag);
							if (count($aPreDefTexts)>0)
							{
								?>
								sInputComment += '<div><select id="predefined_text_field" class="select form-control" onchange="onChangeTexts();"><option value="0">-- Velg melding --</option>';
								<?php
								foreach ($aPreDefTexts as $aText)
								{
									?>
									sInputComment += '<option value="<?php echo $aText['message'];?>"><?php echo $aText['message'];?></option>';
									<?php
								}
								?>
								sInputComment += '</select></div>';
								<?php
							}
							?>
							sInputComment +=
								'<div class="gy-2 nss_popup_margin" id="text_message">'+
								'<textarea class="form-control" rows="4" id="input_text_message" name="input_text_message"></textarea>'+
								'</div>'+
								'<div id="text_buttons">';

							let aMobileList = [];
							for (let iObject=0; iObject<aOrderList.length; iObject++)
							{
								let sMobile = aOrderList[iObject].mobile;
								aMobileList.push(sMobile);
							}

							let sMobileList = "";
							for (let i=0; i<aMobileList.length; i++)
							{
								if (sMobileList.length > 0)
									sMobileList += ",";
								sMobileList += "'"+aMobileList[i]+"'";
							}
							if (bIsOrder)
							{
								sInputComment += '<button type="button" class="nss_btn_primary mt-3 mb-3" onclick="OnButtonCreateEvent('+iMainObjectId+','+aOrderIdList.toString()+','+sMobileList+',\'<?php echo class_VL_service_template_types::SERVICETAG_SNOWPLOW_SEASON;?>\');">Lagre hendelse</button>';
							}
							else
							{
								sInputComment += '<button type="button" class="nss_btn_success mt-3 mb-3" onclick="OnButtonCreateEvent('+iMainObjectId+',\'\','+sMobileList+',\'<?php echo class_VL_service_template_types::SERVICETAG_SNOWPLOW_SEASON;?>\');">Lagre hendelse</button>';
							}
							sInputComment += '</div>';
							sInputComment += '</div>'; // The outher div.
							<?php
							if (class_VL_modules::is_module(class_VL_modules::MODULE_OBJECT_IMAGES))
							{
								?>
								sInputHidden += '<button class="nss_btn_primary pull-right nss_distance" style="margin-top: 0.3em;" onclick="OnClickShowImages('+iMainObjectId+');" title="Bilder av hytta.">Vis bilder</button>';
								<?php
							}
							?>
							sInputHidden += '</div>';
							<?php
						}
						?>

						if (bIsOrder)
						{
							let sStatus = ORDER_STATUS_ORDERED;
							
							// Create the discription.
							let sTempDesc = '<table><tbody>';

							for (let iObject=0; iObject<aOrderList.length; iObject++)
							{
								//let sAddress = aOrderList[iObject].objname; //feature.get('objname') + sGarBru;
								let sObjectName = ((aOrderList[iObject].objname)?aOrderList[iObject].objname:sObjName);
								//let iObjectId = aOrderList[iObject].objectid; // feature.get("objectid");
								let sFirstName = aOrderList[iObject].firstname; // feature.get('firstname');
								let sLastName = aOrderList[iObject].lastname; // feature.get('lastname');
								//let sCountryCode = feature.get('countrycode'); // Mobile is included countrycode
								let sMobile = aOrderList[iObject].mobile; //feature.get('mobile');
								let sDateFrom = aOrderList[iObject].datefrom; //feature.get('datefrom');
								let sDateTo = aOrderList[iObject].dateto; //feature.get('dateto');
								let sServiceValue = aOrderList[iObject].servicevalue;
								let sArrivalTime = aOrderList[iObject].arrivaltime;
								let bValidDate = true;
								
								//
								// Check if the dates are valid.
								if (sDateFrom==='99.99.9999' || sDateFrom==='00.00.0000')
									bValidDate = false;
								if (sDateTo==='99.99.9999' || sDateTo==='00.00.0000')
									bValidDate = false;

								// Change status from color to value.
								switch (sObjectStatus)
								{
									case 'green':
										sStatus = ORDER_STATUS_FINISHED;
										break;

									case 'blue':
										sStatus = ORDER_STATUS_FINISHED_NOT;
										break;

									case 'red':
										sStatus = ORDER_STATUS_ORDERED;
										break;

									default:
										break;
								}

								sTempDesc += '<tr><td colspan="2"><b>'+sObjectName+'</b></td></tr>';
								sTempDesc += 
									'<tr><td>Navn:&nbsp;</td><td>'+sFirstName+' '+sLastName+'</td></tr>'+
									'<tr><td>Mobil:&nbsp;</td><td>'+sMobile+'</td></tr>';

								if (bValidDate)
									sTempDesc += '<tr><td style="color: red; font-weight: bold;">Tjeneste:&nbsp;</td><td style="color: red; font-weight: bold;">'+sServiceTypeText+'</td></tr>';
								
								// Set the last plowed.
								if (sTimeFinished && sTimeFinished.length>0)
								{
									sTempDesc += "<tr><td>Sist brøytet&nbsp;&nbsp;</td><td>"+sTimeFinished+"</td></tr>";
								}

								if (sArrivalTime.length>0 && bValidDate && g_bArrivalTime)
									sTempDesc += '<tr><td style="color: red; font-weight: bold;">Ankomsttid:&nbsp;</td><td style="color: red; font-weight: bold;">'+sArrivalTime+'</td></tr>';

								if (sValueType === '<?php echo class_VL_service_template_types::VALUETYPE_PARKING;?>')
								{
									let iNumPark = parseInt(sServiceValue);
									if (!isNaN(iNumPark))
									{
										sTempDesc += "<tr><td style='color: red; font-weight: bold;'>Parkeringer:&nbsp;</td><td style='color: red; font-weight: bold;'>"+iNumPark+"</td></tr>";
									}
									sTempDesc +=
										"<tr><td>Fra:&nbsp;</td><td>"+nss_sqldate2dispdate(sDateFrom)+"</td></tr>"+
										"<tr><td>Til:&nbsp;</td><td>"+nss_sqldate2dispdate(sDateTo)+"</td></tr>";
								}
								else if (bValidDate)
								{
									sTempDesc += 
										"<tr><td>Fra:&nbsp;</td><td>"+nss_sqldate2dispdate(sDateFrom)+"</td></tr>" +
										"<tr><td>Til:&nbsp;</td><td>"+nss_sqldate2dispdate(sDateTo)+"</td></tr>";
								}
								sTempDesc += '<tr><td colspan="2">&nbsp;</td></tr>';
							}
							sTempDesc += "</tbody></table>";

							let bEmergency = false;
							let sButtonAction = "None";
							let sButtonCancel = '<button type="button" class="nss_btn_danger pull-right nss_distance nss_map_popup_card_close_btn" " onclick="OnButtonDestroyPopup();">X</button>';
							let sButtonFiniNot = "";
							let sDescription = '<div>'+sTempDesc+'</div>';

							if (sMessage && sMessage.length > 2)
								sDescription += "<span style='color: red;'><b>"+sMessage+"</b></span>";
							if (sMessageOrd && sMessageOrd.length>2)
								sDescription += "<div style='color: red;'><b>"+sMessageOrd+"</b></div>";
							sDescription += "<br>";

							if (sStatus === ORDER_STATUS_FINISHED || sStatus === ORDER_STATUS_FINISHED_NOT)
							{
								let sMessageText = "Setter ordren tilbake til status bestilt.";
								
								if (IS_SERVICE_MODE) // Plower
								{
									if (IS_PLOWER_USE_ADMIN_CHANGE_ORDER_STATUS)
									{
										if (sStatus === ORDER_STATUS_FINISHED_NOT)
										{
											sButtonFiniNot = '&nbsp;<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonReactivateNotAdmin('+
												iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Tilbakestill</button>&nbsp;';
										}

										sButtonAction = '<button type="button" class="nss_btn_danger" title='+sMessageText+' onclick="OnButtonReactivateAdmin('+
										  iMainObjectId + ',[' + aOrderIdList.toString() + ']);">&nbsp;Feillevering&nbsp;</button>';
									}
									else
									{
										if (sStatus === ORDER_STATUS_FINISHED_NOT)
										{
											sButtonFiniNot = '&nbsp;<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonReactivateNotNormal('+
												iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Tilbakestill</button>&nbsp;';
										}

										sButtonAction = '<button type="button" class="nss_btn_danger" title='+sMessageText+' onclick="OnButtonReactivateNormal('+
										  iMainObjectId + ',[' + aOrderIdList.toString() + ']);">&nbsp;Feillevering&nbsp;</button>';
									}
								}
								else // Admin mode
								{
									if (IS_ADMIN_TO_CHANGE_ORDER_STATUS)
									{
										if (sStatus === ORDER_STATUS_FINISHED_NOT)
										{
											sButtonFiniNot = '&nbsp;<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonReactivateNotAdmin('+
												iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Tilbakestill</button>&nbsp;';
										}
										sButtonAction = '<button type="button" class="nss_btn_danger" title='+sMessageText+' onclick="OnButtonReactivateAdmin('+
										  iMainObjectId + ',[' + aOrderIdList.toString() + ']);">&nbsp;Feillevering&nbsp;</button>';
									}
									else
									{
										if (sStatus === ORDER_STATUS_FINISHED_NOT)
										{
											sButtonFiniNot = '&nbsp;<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonReactivateNotNormal('+
												iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Tilbakestill</button>&nbsp;';
										}
										sButtonAction = '<button type="button" class="nss_btn_danger" title='+sMessageText+' onclick="OnButtonReactivateNormal('+
											  iMainObjectId + ',[' + aOrderIdList.toString() + ']);" disabled>&nbsp;Feillevering&nbsp;</button>';
									}
								}
							}
							else if (sStatus === ORDER_STATUS_ORDERED || sStatus === ORDER_STATUS_REORDERED || sStatus === ORDER_STATUS_REORDERED_NO_SMS)
							{
								let sMessageText = "Setter ordren til ferdig utført.";
								
								bEmergency = true;
								
								if (IS_SERVICE_MODE) // Plower
								{
									if (IS_PLOWER_USE_ADMIN_CHANGE_ORDER_STATUS)
									{
										sButtonFiniNot = '<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" style="margin-top: 0.3em; margin-bottom: 0.6em" onclick="OnButtonFinishedNotAdmin('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);">'+classMap.sBlueBottonText+'</button>&nbsp;';
										
										sButtonAction = '<button type="button" class="nss_btn_success" title='+sMessageText+' onclick="OnButtonFinishedAdmin('+
											  iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Ferdig</button>';
									}
									else
									{
										sButtonFiniNot = '<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonFinishedNotNormal('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);">'+classMap.sBlueBottonText+'</button>&nbsp;';

										sButtonAction = '<button type="button" class="nss_btn_success" title='+sMessageText+' onclick="OnButtonFinishedNormal('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Ferdig</button>';
									}
								}
								else
								{
									if (IS_ADMIN_TO_CHANGE_ORDER_STATUS) // Only if this setting.
									{
										sButtonFiniNot = '<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonFinishedNotAdmin('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);">'+classMap.sBlueBottonText+'</button>&nbsp;';
										
										sButtonAction = '<button type="button" class="nss_btn_success" title='+sMessageText+' onclick="OnButtonFinishedAdmin('+
											  iMainObjectId + ',[' + aOrderIdList.toString() + ']);">Ferdig</button>';
									}
									else
									{
										sButtonFiniNot = '<button type="button" class="nss_btn_primary nss_map_tilbakestill_btn_adj" onclick="OnButtonFinishedNotNormal('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);" disabled>'+classMap.sBlueBottonText+'</button>&nbsp;';

										sButtonAction = '<button type="button" class="nss_btn_success" title='+sMessageText+' onclick="OnButtonFinishedNormal('+
											iMainObjectId + ',[' + aOrderIdList.toString() + ']);" disabled>Ferdig</button>';
									}
								}
							}
							let sButtonOrderCancel = '<div id="button_order_cancel" class="col-sm-12" style="padding: 0px;">'+sButtonAction+'</div>';

							let sEmergencyText = "";
							if (bEmergency && classMap.bPlowingEmergency)
								sEmergencyText = '<div style="height: 30px; margin-top: 5px;"><input type="checkbox" id="check_emergency">&nbsp;<span style="color: red; font-weight: bold;">Utrykning</span></div>';

							// Add a possibility for a comment in this dialog. Add a check for sending this comment to the cottage owner.
							//$('.popover-title').html(sObjNameGarBru);
							//$('.popover-title').show();
							//$('.popover-content').html(sButtonOrderCancel + sButtonFiniNot + sEmergencyText + sDescription + sInputHidden + sInputComment + sInputImage);
							classMap.popup.getElement().innerHTML = '<div class="nss_map_popup_card"><h4>' + sObjNameGarBru + '</h4>' + sButtonCancel + sButtonOrderCancel + sButtonFiniNot + sEmergencyText + sDescription + sInputHidden + sInputComment + sInputImage + '</div>';
							
							//moveOverlayInsideMap(evt.coordinate);
						}
						else // This is not ordered.
						{
							let iCountObjects = aOrderList.length;
							let sDescription = "";

							let sTempDesc = '<table><tbody>';
							
							//
							// Loop through all the objects.
							for (let iObject=0; iObject < iCountObjects; iObject++)
							{
								let iObjectId = aOrderList[iObject].object_id;
								let sObjectName = ((aOrderList[iObject].objname)?aOrderList[iObject].objname:sObjName);
								//let sAddress = (aOrderList[iObject].address)?aOrderList[iObject].address:"";
								let sName = aOrderList[iObject].firstname+" "+aOrderList[iObject].lastname;
								//let sEmail = feature.get("email");
								//let iObjectId = parseInt(aOrderList[iObject].objectid);
								//let sCountryCode = feature.get("countrycode");
								let sMobile = aOrderList[iObject].mobile;
								let sDateFrom = aOrderList[iObject].datefrom;
								let sDateTo = aOrderList[iObject].dateto;
								let sServiceValue = aOrderList[iObject].servicevalue;
								
								sTempDesc += '<tr><td colspan="2"><b>'+sObjectName+'</b></td></tr>';
								sTempDesc += '<tr><td>Eier&nbsp;&nbsp;</td><td>'+sName+'</td></tr><tr><td>Mobil&nbsp;&nbsp;</td><td>'+sMobile+'</td></tr>';

								if (!bIsValidContract)
								{
									sTempDesc += "<tr><td colspan='2' style='color: blue; font-weight: bold;'>Ingen gyldig kontrakt, kan ikke bestille</td></tr>";
								}
								else
								{
									<?php
									$bAllowOrder = ((!$this->m_bMapReadOnly) and	// If not readonly map.
										$this->m_sMapType==self::MAP_TYPE_NORMAL and // And map type is normal.
										$this->allowToOrder()); // And the setting allow to order is set.

									// If not readonly and more than one object (possible apartment)
									if ($bAllowOrder)
									{
										?>
										if (iCountObjects > 1) // If apartment.
											sTempDesc += '<tr><td colspan="2"><button type="button" class="nss_btn_success pull-left" style="margin-bottom: 0.3em; margin-right: 0.3em;" onclick="OnButtonPlaceOrder(' + iObjectId + ',' + iCountObjects + ',\'' + sObjectName + '\');" title="Her kan du legge til en bestilling for denne hytteeieren.">Bestill</button></td></tr>';
										<?php
									}
									?>
								}
							}
							// Set the last plowed.
							if (sTimeFinished && sTimeFinished.length>0)
							{
								sTempDesc += "<tr><td>Sist brøytet&nbsp;&nbsp;</td><td>"+sTimeFinished+"</td></tr>";
							}
							sTempDesc += '<tr><td colspan="2">&nbsp;</td></tr>';
							sTempDesc += "</tbody></table>"; // Finsihed table.

							
							if (sMessage && sMessage.length > 2)
								sTempDesc += "<div style='color: red;'><b>"+sMessage+"</b></div>";
							if (sMessageOrd && sMessageOrd.length > 2)
								sTempDesc += "<div style='color: red;'><b>"+sMessageOrd+"</b></div>";

							sDescription += '<div>'+sTempDesc+'</div><br>';

							let sButtonOrder = '<span class="pull-left">&nbsp;</span>';
							let sButtonCancel = "";
							let sButtonExtra1 = "";
							let sButtonExtra2 = "";

							// If an valid contract and not ordered, and only one object pr. address.
							if (bIsValidContract && !bIsOrder && iCountObjects === 1)
							{
								<?php
								// Only allow snowplovers personal to order when this is on, or when delivering firewood.
								$b1 = (!$this->m_bMapReadOnly);
								$b2 = $this->m_sMapType==self::MAP_TYPE_NORMAL;
								$b3 = $this->allowToOrder();

								$bAllowOrder = ((!$this->m_bMapReadOnly) and	// If not readonly map.
									$this->m_sMapType==self::MAP_TYPE_NORMAL and // And map type is normal.
									$this->allowToOrder()); // And the setting allow to order is set.

								if ($bAllowOrder)
								{
									?>
									if (iCountObjects > 1) // More than one.
										sButtonOrder = '<span class="pull-left">&nbsp;</span>';
									else
										sButtonOrder = '<button type="button" class="nss_btn_success pull-left" onclick="OnButtonPlaceOrder('+iMainObjectId+','+iCountObjects+',\''+sObjNameGarBru+'\');" title="Her kan du legge til en bestilling for denne hytteeieren.">Bestill</button>';

									switch (sObjectStatus)
									{
										case 'ring':
										case 'ring-extra':
											sButtonExtra1 = '<button type="button" class="nss_btn_primary" onclick="OnButtonCreateExtra('+iMainObjectId+');" title="Her kan du markere gjennombrøyting.">Gjennombrøyting</button>';
											break;
									}
									if (sObjectStatus==='ring-extra' && iLogStatusMinOld<=<?php echo class_util::TIME_24_HOURS;?>) // 24 hours
									{
										sButtonExtra2 = '<button type="button" class="nss_btn_danger" onclick="OnButtonDeleteExtra('+iLogStatusId+','+iLogStatusMinOld+');" title="Her kan du slette gjennombrøytingen.">Slette siste gjennombrøyting</button>';
									}
									<?php
								}
								?>
							}
							sButtonCancel = '<button type="button" class="nss_btn_danger pull-right nss_distance nss_map_popup_card_close_btn" onclick="OnButtonDestroyPopup();" title="Klikk her når du er ferdig med denne popup boksen.">X</button>';

							let sTableButtons = '<table>';
							sTableButtons += '<tr style="height: 50px;" class="d-flex justify-content-between"><td>' + sButtonOrder + '</td></tr>';
							if (sButtonExtra1.length>0)
								sTableButtons += '<tr style="height: 50px;"><td colspan="2">' + sButtonExtra1 + '</td></tr>';
							if (sButtonExtra2.length>0)
								sTableButtons += '<tr style="height: 50px;"><td colspan="2">' + sButtonExtra2 + '</td></tr>';
							sTableButtons += '</table>';

							//$('.popover-title').html(sObjNameGarBru);
							//$('.popover-title').show();
							//$('.popover-content').html(sTableButtons + sDescription + sInputHidden + sInputComment + sInputImage);
							classMap.popup.getElement().innerHTML = '<div class="nss_map_popup_card"><h4>' + sObjNameGarBru + '</h4>' + sButtonCancel + sTableButtons + sDescription + sInputHidden + sInputComment + sInputImage + '</div>';
							
							//moveOverlayInsideMap(evt.coordinate);
						}
						clearAreaNameTimeout();
					}
					else // Not an icon, it is a area show the areaname.
					{
						let sName = feature.get('areaname');

						clearAreaNameTimeout();

						classMap.overlayAreaName.setPosition(evt.coordinate);
						$("#areaname").html('<div style="height:relative; padding-left:10px; padding-right: 10px; padding-top:5px; padding-bottom:5px; background-color: #A8C1BF; opacity:0.7; border: 2px solid #5a827f;">'+
							sName+'</div>');
						$("#areaname").css("display", "block");
						//document.body.style.cursor = feature ? 'pointer' : '';

						g_timeoutAreaName = window.setTimeout(timeoutAreaName, 2000);
					}
				}
				else
				{
					clearAreaNameTimeout();
				}
			 });
			}
			else
			{
				if (classMap.bRemovePopup)
					OnButtonDestroyPopup(); // Destroy the popup.
			}
		}
		</script>
		<?php
		$sScript = ob_get_clean();
		
		return ($sScript);
	}

	//
	// Place snowplow order.
	public function OnButtonPlaceOrder(class_dbpdo $DB, int $iProviderId, string $sServiceTag): string
	{
		$sValueType = class_VL_service_template_types::VALUETYPE_NONE;

		$aRowsTemplate = class_DL_service_templates::get_service_template_by_provider_and_servicetag_trans($DB, $iProviderId, $sServiceTag);
		if (count($aRowsTemplate) > 0)
			$sValueType = $aRowsTemplate[0]['valuetype'];

		//$sUnityText = class_custom_service::get_unity_text($iProviderId, $sValueType, false);
		
		ob_start();
		?>
		<script>
		function OnButtonDeleteExtra(iStatusLogId, iLogStatusMinOld)
		{
			classMap.bOkClickMap = true; // Ok to click the map.
			//$(classMap.element).popover('destroy');
			//classMap.popup.getElement().popover('destroy');
			classMap.popup.getElement().style.display = 'none';

			if (iLogStatusMinOld<=120)
			{
				nss_confirm_yesno(
					'Slette gjennombrøyting?',
					'Vil du slette gjennombrøytinge for denne hytta? Det medfører at det trekkes fra en brøyting på denne hytta, det sendes ingen sms eller melding.',
					'Ja',
					'Nei',
					function () {
						//
						// UnFreeze The Map.
						unFreezeMap();
			
						//
						// Call ajax to set the order_service_status_log to EXTRA plowing.
						$.ajax({
							type: 'post',
							url: 'ajax_gateway.php',
							data: {
								_class: 'ajax_order_service_status_log',
								_func: 'delete_status',
								statuslogid: iStatusLogId
							},
							error: function (sError) {
								console.log(sError);
							},
							success: function (sJsonText) {
								//console.log(sJsonText);
								// Then create a <select and show the days as a drop down. The same shall be used when ordering from the users.
								let oRet = JSON.parse(sJsonText);

								if (oRet.bRet)
								{
									nss_message('success', oRet.sMess);

									let oToday = new Date();

									let sCurrDate = nss_date2sqldate(oToday);

									// Reload flags.
									OnReloadFlags(sCurrDate, 0);
								}
							}
						});
					},
					function () {
						//
						// UnFreeze The Map.
						unFreezeMap();
					}
				);
			}
			else
			{
				nss_alert("Slette gjennombrøyting?",'Du kan ikke slette denne gjennombrøytingen, den er mer enn to timer gammel. Sletting må gjøres i administratorpanelet.');
			}
		}

		function OnButtonCreateExtra(iObjectId)
		{
			classMap.bOkClickMap = true; // Ok to click the map.
			//classMap.popup.getElement().popover('destroy');
			classMap.popup.getElement().style.display = 'none';
			
			//
			// UnFreeze the map.
			unFreezeMap();

			//
			// Call ajax to set the order_service_status_log to EXTRA plowing.
			$.ajax({
				type: 'post',
				url: 'ajax_gateway.php',
				data: {
					_class: 'ajax_order_service_status_log',
					_func: 'create_status',
					objectid: iObjectId,
					providerid: <?php echo $iProviderId;?>,
					orderid: 0,
					userid: <?php echo class_util::getUserId();?>,
					status: ORDER_STATUS_FINISHED_EXTRA,
					valuetype: "",
					servicevalue: "",
					servicetag: SERVICETAG_SNOWPLOW_SEASON,
					timefinished: ""
				},
				error: function (sError) {
					console.log(sError);
				},
				success: function (sJsonText) {
					//console.log(sJsonText);
					// Then create a <select and show the days as a drop down. The same shall be used when ordering from the users.
					let oRet = JSON.parse(sJsonText);
					
					if (oRet.bRet)
					{
						nss_message('success', oRet.sMess);
						
						let oToday = new Date();

						let sCurrDate = nss_date2sqldate(oToday);

						// This date must e checked if using the button to change date.
						OnReloadFlags(sCurrDate, 0);
						let iId = oRet.aData.id;
					}
				}
			});
		}
		
		//
		// Place an order for the cottage that was clicked.
		function OnButtonPlaceOrder(iObjectId, iCountObjects, sObjectName)
		{
			classMap.bOkClickMap = true; // Ok to click the map.

			//classMap.popup.getElement().popover('destroy');
			classMap.popup.getElement().style.display = 'none';

			// Check for combined types like apartment or parking. For the moment it is not allowed to order. Because it is a bit complicated.
			// Has to be done at a later stage.
			if (iCountObjects > 1)
			{
				nss_alert('Bestilling',"Bestilling kan foreløpig ikke gjøres i kartet på leiligheter og parkeringer. Bestillinger kan gjøres på vanlig måte i administrasjonen.");

				//
				// UnFreeze The Map.
				unFreezeMap();

				return (true);
			}
			else
			{
				// Call an ajax to get the next valid days max X days.
				$.ajax({
					type: 'post',
					url: 'ajax_get_valid_order_periode.php',
					data: {
						act: 'get_valid_weeks',
						objectid: iObjectId
					},
					error: function (sRet) {
						//
						// UnFreeze The Map.
						unFreezeMap();
					},
					success: function (sJsonText) {
						//console.log(sJsonText);
						// Then create a <select and show the days as a drop down. The same shall be used when ordering from the users.
						let oRet = JSON.parse(sJsonText);
						let aDays = oRet.aData;
						let iNumDays = 0;
						
						let sHtml = '<input type="hidden" name="input_datefrom" id="input_datefrom" value="' + aDays[0].days[0].year + '-' + trail0(aDays[0].days[0].month, 2) + '-' + trail0(aDays[0].days[0].day, 2) + '" />';

						sHtml += '<select name="input_dateto" id="input_dateto" class="select">';
						
						//console.log(aDays[0].days);
						// NOTO == Not ordered.
						for (let i = 0; i < 7 && aDays[0].days[i].status === 'NOTO'; i++)
						{
							iNumDays++;
							let sDispDate = trail0(aDays[0].days[i].day, 2) + '.' + trail0(aDays[0].days[i].month, 2) + '.' + aDays[0].days[i].year;
							let sDate = aDays[0].days[i].year + '-' + trail0(aDays[0].days[i].month, 2) + '-' + trail0(aDays[0].days[i].day, 2);

							sHtml += '<option value="' + sDate + '">' + ' ' + sDispDate + ' ' + aDays[0].days[i].dayname + '</option>';
						}
						sHtml += '</select>';
						
						if (iNumDays>0)
						{
							nss_confirm_yesno(
								'Lage en ny ordre ?',
								'<b>Vil du lage en ny ordre for ' + sObjectName + '<br>fra og med i dag, til og med</b><br><br>' + sHtml,
								'Ja',
								'Nei',
								function () {
									let sDateTo = $("#input_dateto").val();
									let sDateFrom = $("#input_datefrom").val();

									//
									// UnFreeze The Map.
									unFreezeMap();

									// Check if malformed date to.
									if (sDateTo.length===0)
										sDateTo = sDateFrom;

									$.ajax({
										type: 'post',
										url: 'ajax_create_order.php',
										data: {
											act: 'default',
											servicetemplateid: g_iSelectedServiceTemplateId, // If more than one service it is in top of the map.
											objectid: iObjectId,
											datefrom: sDateFrom,
											dateto: sDateTo,
											lateorder: 'T' // Mark as late order, always order from today.
										},
										error: function (sRet) {
											//console.log("FEIL: En feil oppstod ved kall til ajax_send_order_sms.php, forsøk på nytt.");

											nss_alert('Feil!', sRet, function () {
												// Update the flags.
												doUpdateFlags(false);
											});
										},
										success: function (sJsonText) {
											//console.log(sJsonText);
											let aRet = JSON.parse(sJsonText);
											if (parseInt(aRet.err) === 0)
											{
												nss_message('success', aRet.mess);

												let oToday = new Date();

												let sCurrDate = nss_date2sqldate(oToday);

												// This date must be checked if using the button to change date.
												OnReloadFlags(sCurrDate, 0);
											}
											else
											{
												nss_message('danger', aRet.mess);
											}
										}
									});
								},
								function () {
									//
									// UnFreeze The Map.
									unFreezeMap();
								}
							);
						}
						else
						{
							alert("Ingen dager som kan brukes.");
						}
					}
				});
			}
		}
		</script>
		<?php
		$sScript = ob_get_clean();
		
		return ($sScript);
	}
}
