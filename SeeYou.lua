local EventFrame
local TimeElapsed = 0;
local iconNameToPlayerName = {}; -- iconName -> playerName
local playerNameToIconName = {}; -- playerName -> iconName
local iconMap = {}; -- iconName -> frame
local visibleNameplates = {} -- playerName -> nameplate

do
	function OnStartup()
		iconsAlloc()
		-- // starting OnUpdate()
		EventFrame:SetScript("OnUpdate", function(self, elapsed)
			TimeElapsed = TimeElapsed + elapsed;
			if (TimeElapsed >= 0.5) then
				OnUpdate();
				TimeElapsed = 0;
			end
		end);
	
		EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
		EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
		
		SLASH_SEEYOU1 = '/sy';
		SlashCmdList["SEEYOU"] = function(msg, editBox)
			print("Hello World!")
			if (msg == "1") then
				local playerName = UnitName("target")
				if (not playerName) then
					print ("error on pin icon")
					return
				end
				
				pinIcon(playerName, "1")
				print("Done")
			end
			if (msg == "2") then
				local playerName = UnitName("target")
				if (not playerName) then
					print ("error on pin icon")
					return
				end
				
				pinIcon(playerName, "2")
				print("Done")
			end
		end
	end
end

function pinIcon(playerName, iconName)
	if (not playerName or not iconName) then
		print("playerName is nil")
		return
	end

	if iconNameToPlayerName[iconName] == playerName then
		iconMap[iconName]:Hide()
		iconNameToPlayerName[iconName] = nil -- unpin
		playerNameToIconName[playerName] = nil
	else
		iconNameToPlayerName[iconName] = playerName
		playerNameToIconName[playerName] = iconName
		iconMap[iconName]:Show()
	end
	print(iconNameToPlayerName[iconName])
end

function iconsAlloc()
	local f1 = CreateFrame("Frame", nil, UIParent)
	f1:SetFrameStrata("BACKGROUND")
	f1:SetWidth(25) -- Set these to whatever height/width is needed 
	f1:SetHeight(25) -- for your Texture

	local t1 = f1:CreateTexture(nil, "BACKGROUND")
	t1:SetTexture("Interface\\AddOns\\SeeYou\\icons\\indicator1.tga", 0.5)
	t1:SetAllPoints(f1)
	f1.texture = t1
	iconMap["1"] = f1
	
	local f2 = CreateFrame("Frame", nil, UIParent)
	f2:SetFrameStrata("BACKGROUND")
	f2:SetWidth(25) -- Set these to whatever height/width is needed 
	f2:SetHeight(25) -- for your Texture

	local t2 = f2:CreateTexture(nil, "BACKGROUND")
	t2:SetTexture("Interface\\AddOns\\SeeYou\\icons\\indicator2.tga", 0.5)
	t2:SetAllPoints(f2)
	f2.texture = t2
	iconMap["2"] = f2
end

EventFrame = CreateFrame("Frame");
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
EventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		playerEnteringWorld();
	elseif (event == "NAME_PLATE_UNIT_ADDED") then
		nameplateUnitAdded(...);
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		nameplateUnitRemoved(...);
	end
end);

function playerEnteringWorld()
	OnStartup();
end

function nameplateUnitAdded(...)
	local unitID = ...;
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID);
	local unitName = UnitName(unitID);
	local playerIcon = playerNameToIconName[unitName]
	if (playerIcon) then
		iconMap[playerIcon]:Show()
	end
	
	if (not nameplate or not unitName) then
		print("nameplateUnitAdded error")
	end
	
	visibleNameplates[unitName] = nameplate
end

function nameplateUnitRemoved(...)
	local unitID = ...;
	local unitName = UnitName(unitID);
	visibleNameplates[unitName] = nil
	local playerIcon = playerNameToIconName[unitName]
	if (playerIcon) then
		iconMap[playerIcon]:Hide()
	end
end

function OnUpdate()
	for i, playerName in pairs(iconNameToPlayerName) do
		local icon = iconMap[i]
		if (not icon) then
			print("icon is nil")
			return
		end
		
		nameplate = visibleNameplates[playerName]
		if (not nameplate) then -- is not visible
			return
		end
		
		icon:SetPoint("BOTTOM", nameplate, "TOP", 0, 0)
		--icon:Show()
		--print("OnUpdate", playerName)
	end
end