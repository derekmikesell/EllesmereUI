local ADDON_NAME = ...

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_LOGIN")

	if not EllesmereUI or not EllesmereUI.RegisterModule then
		return
	end

	local strupper, strgsub, strmatch, strsub = string.upper, string.gsub, string.match, string.sub
	local floor = math.floor

	local function HexToRGB(hex)
		hex = strupper(strgsub(hex or "0CD29D", "#", ""))
		if not strmatch(hex, "^[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") then
			hex = "0CD29D"
		end
		return tonumber(strsub(hex, 1, 2), 16) / 255,
			tonumber(strsub(hex, 3, 4), 16) / 255,
			tonumber(strsub(hex, 5, 6), 16) / 255
	end

	local function RGBToHex(r, g, b)
		return string.format("%02X%02X%02X", floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5))
	end

	local db
	local function DB()
		if not db then
			db = _G._EBL_AceDB
		end
		return db and db.profile
	end

	local function IsCircleStyle()
		local p = DB()
		local style = p and p.crosshairStyle or "circle"
		return style == "circle"
	end

	local function IsCrossStyle()
		local p = DB()
		local style = p and p.crosshairStyle or "circle"
		return style == "cross"
	end

	local function BuildBasicsPage(pageName, parent, yOffset)
		local W = EllesmereUI.Widgets
		local y = yOffset
		local row, _, h

		-- CROSSHAIR section
		_, h = W:SectionHeader(parent, "CROSSHAIR", y)
		y = y - h

		-- Enable Crosshair ---- Use Class Color
		row, h = W:DualRow(parent, y, {
			type = "toggle",
			text = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairEnabled
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairEnabled = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
				EllesmereUI:RefreshPage()
			end,
		}, {
			type = "toggle",
			text = "Use Class Color",
			disabled = function()
				local p = DB()
				return p and not p.crosshairEnabled
			end,
			disabledTooltip = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairUseClassColor
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairUseClassColor = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
				EllesmereUI:RefreshPage()
			end,
		})
		y = y - h

		-- Inline color swatch on Use Class Color (right side)
		do
			local rgn = row._rightRegion
			local swatch = EllesmereUI.BuildColorSwatch(rgn, rgn:GetFrameLevel() + 5, function()
				local p = DB()
				if not p then
					return 1, 1, 1, 1
				end
				local r, g, b = HexToRGB(p.crosshairHex)
				return r, g, b, 1
			end, function(r, g, b, a)
				local p = DB()
				if not p then
					return
				end
				p.crosshairHex = RGBToHex(r, g, b)
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end, false, 20)
			swatch:SetPoint("RIGHT", rgn._lastInline or rgn._control, "LEFT", -12, 0)
			rgn._lastInline = swatch
			local function UpdateSwatch()
				local p = DB()
				if not p or not p.crosshairEnabled then
					swatch:SetAlpha(0.15)
					swatch:Disable()
					swatch._disabledTooltip = "Enable Crosshair"
				elseif p.crosshairUseClassColor then
					swatch:SetAlpha(0.15)
					swatch:Disable()
					swatch._disabledTooltip = "Disable Use Class Color"
				else
					swatch:SetAlpha(1)
					swatch:Enable()
					swatch._disabledTooltip = nil
				end
			end
			UpdateSwatch()
			EllesmereUI.RegisterWidgetRefresh(UpdateSwatch)
		end

		-- Style dropdown ---- Scale
		_, h = W:DualRow(parent, y, {
			type = "dropdown",
			text = "Style",
			values = { circle = "Circle", cross = "Cross" },
			order = { "circle", "cross" },
			disabled = function()
				local p = DB()
				return p and not p.crosshairEnabled
			end,
			disabledTooltip = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairStyle or "circle"
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairStyle = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
				EllesmereUI:RefreshPage()
			end,
		}, {
			type = "slider",
			text = "Scale",
			min = 0.5,
			max = 1.5,
			step = 0.1,
			disabled = function()
				local p = DB()
				return p and not p.crosshairEnabled
			end,
			disabledTooltip = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairScale or 1
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairScale = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		})
		y = y - h

		-- Show Dot toggle ---- Ring Texture
		row, h = W:DualRow(parent, y, {
			type = "toggle",
			text = "Show Dot",
			disabled = function()
				local p = DB()
				return p and not p.crosshairEnabled
			end,
			disabledTooltip = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairShowDot
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairShowDot = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		}, {
			type = "dropdown",
			text = "Ring Texture",
			values = {
				ring_thin = "Thin",
				ring_light = "Light",
				ring_normal = "Normal",
				ring_heavy = "Heavy",
				ring_thick = "Thick",
			},
			order = { "ring_thin", "ring_light", "ring_normal", "ring_heavy", "ring_thick" },
			disabled = function()
				local p = DB()
				return p and (not p.crosshairEnabled or not IsCircleStyle())
			end,
			disabledTooltip = "Select Circle style",
			getValue = function()
				local p = DB()
				return p and p.crosshairRing or "ring_normal"
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairRing = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		})
		y = y - h

		-- Cross Thickness ---- Cross Length
		row, h = W:DualRow(parent, y, {
			type = "slider",
			text = "Cross Thickness",
			min = 1,
			max = 10,
			step = 1,
			disabled = function()
				local p = DB()
				return p and (not p.crosshairEnabled or not IsCrossStyle())
			end,
			disabledTooltip = "Select Cross style",
			getValue = function()
				local p = DB()
				return p and p.crosshairThickness or 3
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairThickness = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		}, {
			type = "slider",
			text = "Cross Length",
			min = 5,
			max = 20,
			step = 1,
			disabled = function()
				local p = DB()
				return p and (not p.crosshairEnabled or not IsCrossStyle())
			end,
			disabledTooltip = "Select Cross style",
			getValue = function()
				local p = DB()
				return p and p.crosshairLength or 20
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairLength = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		})
		y = y - h

		-- Cross Gap
		row, h = W:DualRow(parent, y, {
			type = "slider",
			text = "Cross Gap",
			min = 0,
			max = 20,
			step = 1,
			disabled = function()
				local p = DB()
				return p and (not p.crosshairEnabled or not IsCrossStyle())
			end,
			disabledTooltip = "Select Cross style",
			getValue = function()
				local p = DB()
				return p and p.crosshairGap or 8
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairGap = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		}, {
			type = "dropdown",
			text = "Frame Strata",
			values = {
				BACKGROUND = "Background",
				LOW = "Low",
				MEDIUM = "Medium",
				HIGH = "High",
				DIALOG = "Dialog",
				FULLSCREEN = "Fullscreen",
				FULLSCREEN_DIALOG = "Fullscreen Dialog",
				TOOLTIP = "Tooltip",
			},
			order = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" },
			disabled = function()
				local p = DB()
				return p and not p.crosshairEnabled
			end,
			disabledTooltip = "Enable Crosshair",
			getValue = function()
				local p = DB()
				return p and p.crosshairStrata or "HIGH"
			end,
			setValue = function(v)
				local p = DB()
				if not p then
					return
				end
				p.crosshairStrata = v
				if _G._EBL_ApplyCrosshair then
					_G._EBL_ApplyCrosshair()
				end
			end,
		})
		y = y - h

		_, h = W:Spacer(parent, y, 20)
		y = y - h
	end

	-- Register the module
	EllesmereUI:RegisterModule("EllesmereUIBasics", {
		title = "Basics",
		description = "Basic quality of life features.",
		pages = { "Basics" },
		buildPage = function(pageName, parent, yOffset)
			if pageName == "Basics" then
				return BuildBasicsPage(pageName, parent, yOffset)
			end
		end,
		onReset = function()
			local dbObj = _G._EBL_AceDB
			if dbObj and dbObj.ResetProfile then
				dbObj:ResetProfile()
			end
			if _G._EBL_ApplyCrosshair then
				_G._EBL_ApplyCrosshair()
			end
		end,
	})
end)
