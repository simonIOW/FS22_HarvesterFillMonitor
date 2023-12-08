----------------------------------------------------------------------------
-- @Author: ViperGTS96------------------------------------------------------
----------------------------------------------------------------------------
--------------------"The simplest design is the best design." --------------
----------------------------------------------------------------------------
--- BugFix version: simonIOW -----------------------------------------------
----------------------------------------------------------------------------

HarvesterFillMonitor = {};
local modDescFile = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
HarvesterFillMonitor.title = getXMLString(modDescFile, "modDesc.title.en");
HarvesterFillMonitor.author = getXMLString(modDescFile, "modDesc.author");
HarvesterFillMonitor.version = getXMLString(modDescFile, "modDesc.version");
delete(modDescFile);
HarvesterFillMonitor.workerText = "";
HarvesterFillMonitor.vehicleText = "";
HarvesterFillMonitor.fillLevelText = "";

function HarvesterFillMonitor:draw()
	if not g_gui:getIsGuiVisible() then
		if g_currentMission.hud.isVisible then
			local i = 1;
			for _, vehicle in pairs(g_currentMission.vehicles) do
				if vehicle.spec_combine ~= nil then
					local rootVehicle = vehicle:getRootVehicle();
					if rootVehicle:getIsAIActive() and vehicle.totalFillCap ~= nil then
						local uiScale = g_gameSettings:getValue("uiScale");
						local textSize = 0.018*uiScale;
						local name = HarvesterFillMonitor.vehicleText;
						local isEntered = false;
						
						local rootHelper = "";
						
						if rootVehicle:getCurrentHelper() ~= nil then
							rootHelper = rootVehicle:getCurrentHelper().name;
						end;
						
						if rootHelper ~= "" then
							if rootVehicle ~= g_currentMission.controlledVehicle then 
								name = HarvesterFillMonitor.workerText.." ("..rootHelper..")";
							else
								isEntered = true;
							end;
							
							local fuelLevel, fuelCapacity = SpeedMeterDisplay.getVehicleFuelLevelAndCapacity(rootVehicle);
							
							local vehicleName = rootVehicle:getName().." ("..rootHelper..")";
							
							local fuelPerc = math.floor((fuelLevel/fuelCapacity)*100);
							
							
							local renderString = vehicleName.." - "..HarvesterFillMonitor.fillLevelText.." : "..MathUtil.clamp(vehicle.totalFillCap,0.0,100.0).."%".." Fuel : "..MathUtil.clamp(fuelPerc,0.0,100.0).."%";
							local x = 0.99;
							local y = (0.8-(textSize/2))-(i*(textSize*1.5));
							local oX = textSize * HUDTextDisplay.SHADOW_OFFSET_FACTOR;
							setTextBold(false);
							setTextColor(0,0,0,1);
							setTextAlignment(RenderText.ALIGN_RIGHT);
							renderText(x+oX,(y+textSize)-oX, textSize, renderString);
							local textColor = {1,1,1,1};
							if isEntered then textColor = {0,1,0,1}; end;
							if vehicle.totalFillCap >= 80 or fuelPerc <w 20 then textColor = {1,0.5,0,1}; end;
							if vehicle.totalFillCap >= 90 or fuelPerc < 10 then textColor = {1,0,0,1}; end;
							setTextColor(unpack(textColor));
							renderText(x,y+textSize, textSize, renderString);
							i=i+1;
						end;
					end;
				end;
			end;
		end;
	end;
end;

function HarvesterFillMonitor:loadMap(savegame)
	HarvesterFillMonitor.workerText = g_i18n:getText("ui_helper");
	HarvesterFillMonitor.vehicleText = g_i18n:getText("typeDesc_combine");
	HarvesterFillMonitor.fillLevelText = g_i18n:getText("info_fillLevel");
	HarvesterFillMonitor.vehicleText = string.upper(string.sub(HarvesterFillMonitor.vehicleText,0,1))..string.sub(HarvesterFillMonitor.vehicleText,2);
	--if HarvesterFillMonitor.vehicleText == "Harvester" then HarvesterFillMonitor.vehicleText = "Combine"; end; --English only
	print(HarvesterFillMonitor.title.." : v"..HarvesterFillMonitor.version.." by "..HarvesterFillMonitor.author.." activated");
end;

function HarvesterFillMonitor:getFillLevel(vehicle)

	local fillCap = vehicle:getFillUnitCapacity(vehicle.spec_combine.fillUnitIndex);
	local fillLvl = vehicle:getFillUnitFillLevel(vehicle.spec_combine.fillUnitIndex);
	if fillCap > 9999999 then fillCap = 0; end;
	local attachedImplements = vehicle:getAttachedImplements();
	if attachedImplements ~= nil then
		for _, attachable in pairs(attachedImplements) do
			if attachable.object ~= nil then
				if attachable.object.spec_dischargeable ~= nil then
					local dischargeNode = attachable.object.spec_dischargeable.currentDischargeNode;
					fillCap = fillCap + attachable.object:getFillUnitCapacity(dischargeNode.fillUnitIndex);
					fillLvl = fillLvl + attachable.object:getFillUnitFillLevel(dischargeNode.fillUnitIndex);
				end;
			end;
		end;
	end;
	if fillCap <= 0 then return nil; end;
	return math.floor((fillLvl/fillCap)*100);
end;

function HarvesterFillMonitor:update(dt)

	for _, vehicle in pairs(g_currentMission.vehicles) do
		if vehicle.spec_combine ~= nil then
			local rootVehicle = vehicle:getRootVehicle();
			if rootVehicle:getIsAIActive() then
				vehicle.totalFillCap = HarvesterFillMonitor:getFillLevel(vehicle);
			elseif vehicle.totalFillCap ~= nil then
				vehicle.totalFillCap = nil;
			end;
		end;
	end;

end;

addModEventListener(HarvesterFillMonitor);
