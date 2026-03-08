-------------------------------------------------------------------------------
--  EllesmereUIBasics.lua
--  Quality-of-life features: crosshair overlay
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local EBL = EllesmereUI.Lite.NewAddon(ADDON_NAME)
ns.EBL = EBL

local crosshairFrame
local floor, tonumber = math.floor, tonumber
local strupper, strsub, strgsub, strmatch = string.upper, string.sub, string.gsub, string.match

local defaults = {
	profile = {
		crosshairEnabled = false,
		crosshairStyle = "cross",
		crosshairHex = "FFFFFF",
		crosshairUseClassColor = true,
		crosshairScale = 2,
		crosshairRing = "ring_normal",
		crosshairThickness = 2,
		crosshairLength = 10,
		crosshairGap = 3,
		crosshairShowDot = false,
		crosshairStrata = "HIGH",
	},
}

local RING_TEXTURES = {
	ring_thin = "Interface\\AddOns\\EllesmereUIBasics\\Media\\ring_thin.tga",
	ring_light = "Interface\\AddOns\\EllesmereUIBasics\\Media\\ring_light.tga",
	ring_normal = "Interface\\AddOns\\EllesmereUIBasics\\Media\\ring_normal.tga",
	ring_heavy = "Interface\\AddOns\\EllesmereUIBasics\\Media\\ring_heavy.tga",
	ring_thick = "Interface\\AddOns\\EllesmereUIBasics\\Media\\ring_thick.tga",
}

local function GetClassColor()
	local class = select(2, UnitClass("player"))
	local color = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
	return color.r, color.g, color.b
end

local function HexToRGB(hex)
	hex = strupper(strgsub(hex or "FFFFFF", "#", ""))
	if not strmatch(hex, "^[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") then
		hex = "FFFFFF"
	end
	return tonumber(strsub(hex, 1, 2), 16) / 255,
		tonumber(strsub(hex, 3, 4), 16) / 255,
		tonumber(strsub(hex, 5, 6), 16) / 255
end

local function CreateCrosshairFrame()
	crosshairFrame = CreateFrame("Frame", "EUI_Basics_Crosshair", UIParent)
	crosshairFrame:SetSize(200, 200)
	crosshairFrame:SetPoint("CENTER", UIParent, "CENTER")
	crosshairFrame:SetFrameLevel(100)
	crosshairFrame:Hide()
	crosshairFrame:EnableMouse(false)

	crosshairFrame.circle = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.circle:SetPoint("CENTER")
	crosshairFrame.circle:SetDesaturated(true)

	crosshairFrame.crossTop = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.crossTop:SetPoint("BOTTOM", crosshairFrame, "CENTER", 0, 0)
	crosshairFrame.crossTop:SetTexture("Interface\\Buttons\\WHITE8X8")

	crosshairFrame.crossBottom = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.crossBottom:SetPoint("TOP", crosshairFrame, "CENTER", 0, 0)
	crosshairFrame.crossBottom:SetTexture("Interface\\Buttons\\WHITE8X8")

	crosshairFrame.crossLeft = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.crossLeft:SetPoint("RIGHT", crosshairFrame, "CENTER", 0, 0)
	crosshairFrame.crossLeft:SetTexture("Interface\\Buttons\\WHITE8X8")

	crosshairFrame.crossRight = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.crossRight:SetPoint("LEFT", crosshairFrame, "CENTER", 0, 0)
	crosshairFrame.crossRight:SetTexture("Interface\\Buttons\\WHITE8X8")

	crosshairFrame.dot = crosshairFrame:CreateTexture(nil, "OVERLAY")
	crosshairFrame.dot:SetPoint("CENTER")
	crosshairFrame.dot:SetDesaturated(true)
end

local function ApplyCrosshair()
	if not crosshairFrame then
		return
	end

	local p = EBL.db.profile
	if not p or not p.crosshairEnabled then
		crosshairFrame:Hide()
		return
	end

	local scale = p.crosshairScale or 1
	local thickness = (p.crosshairThickness or 1) * 2
	local useClassColor = p.crosshairUseClassColor
	local hex = p.crosshairHex or "FFFFFF"
	local r, g, b

	if useClassColor then
		r, g, b = GetClassColor()
	else
		r, g, b = HexToRGB(hex)
	end
	local a = 1

	local style = p.crosshairStyle or "cross"
	local ring = p.crosshairRing or "ring_normal"
	local showDot = p.crosshairShowDot
	local length = p.crosshairLength or 10
	local gap = p.crosshairGap or 3

	crosshairFrame:SetScale(scale)
	crosshairFrame:SetFrameStrata(p.crosshairStrata or "HIGH")
	crosshairFrame:Show()

	local size = 40

	-- Circle uses ring texture
	local ringTex = RING_TEXTURES[ring] or RING_TEXTURES.ring_normal
	crosshairFrame.circle:SetTexture(ringTex)
	crosshairFrame.circle:SetSize(size, size)
	crosshairFrame.circle:SetVertexColor(r, g, b, a)

	-- Cross lines with gap
	crosshairFrame.crossTop:SetSize(thickness, length)
	crosshairFrame.crossTop:SetPoint("BOTTOM", crosshairFrame, "CENTER", 0, gap)
	crosshairFrame.crossTop:SetVertexColor(r, g, b, a)

	crosshairFrame.crossBottom:SetSize(thickness, length)
	crosshairFrame.crossBottom:SetPoint("TOP", crosshairFrame, "CENTER", 0, -gap)
	crosshairFrame.crossBottom:SetVertexColor(r, g, b, a)

	crosshairFrame.crossLeft:SetSize(length, thickness)
	crosshairFrame.crossLeft:SetPoint("RIGHT", crosshairFrame, "CENTER", -gap, 0)
	crosshairFrame.crossLeft:SetVertexColor(r, g, b, a)

	crosshairFrame.crossRight:SetSize(length, thickness)
	crosshairFrame.crossRight:SetPoint("LEFT", crosshairFrame, "CENTER", gap, 0)
	crosshairFrame.crossRight:SetVertexColor(r, g, b, a)

	-- Dot uses its own texture
	local dotSize = 18
	local dotTex = "Interface\\AddOns\\EllesmereUIBasics\\Media\\dot"
	crosshairFrame.dot:SetTexture(dotTex)
	crosshairFrame.dot:SetSize(dotSize, dotSize)
	crosshairFrame.dot:SetVertexColor(r, g, b, a)

	crosshairFrame.circle:Hide()
	crosshairFrame.crossTop:Hide()
	crosshairFrame.crossBottom:Hide()
	crosshairFrame.crossLeft:Hide()
	crosshairFrame.crossRight:Hide()
	crosshairFrame.dot:Hide()

	if style == "circle" then
		crosshairFrame.circle:Show()
	elseif style == "cross" then
		crosshairFrame.crossTop:Show()
		crosshairFrame.crossBottom:Show()
		crosshairFrame.crossLeft:Show()
		crosshairFrame.crossRight:Show()
	end

	if showDot then
		crosshairFrame.dot:Show()
	end
end

function EBL:OnInitialize()
	self.db = EllesmereUI.Lite.NewDB("EllesmereUIBasicsDB", defaults)

	_G._EBL_AceDB = self.db
	_G._EBL_ApplyCrosshair = ApplyCrosshair
end

function EBL:OnEnable()
	if not _EllesmereUI_MinimapRegistered and EllesmereUI and EllesmereUI.CreateMinimapButton then
		EllesmereUI.CreateMinimapButton()
	end

	if not crosshairFrame then
		CreateCrosshairFrame()
	end
	ApplyCrosshair()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", ApplyCrosshair)
end
