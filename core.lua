local A, L = ...
local cfg = L.cfg

local abs, maxCp, min = math.abs, math.maxCp, math.min

local powerType
local energyBarBg, energyBar, energyBarText

local pixelSize
local function calculatePixelSize()
  local physicalWidth, physicalHeight = GetPhysicalScreenSize()
  local UIScale = UIParent:GetEffectiveScale()
  pixelSize = 768 / physicalHeight / UIScale
end

local function SnapToPixel(value)
  return math.floor(value / pixelSize + 0.5) * pixelSize
end

local backdrop_tab = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\Buttons\\ChatFrameBackground",
  tile = false,
  tileSize = 0,
  edgeSize = 1,
  insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local powerColors = {
  [0] = cfg.colors.mana,
  [1] = cfg.colors.rage,
  [2] = cfg.colors.focus,
  [3] = cfg.colors.energy,
  [6] = cfg.colors.runicpower,
  [8] = cfg.colors.lunarpower,
  [11] = cfg.colors.maelstrom,
  [13] = cfg.colors.insanity,
  [17] = cfg.colors.fury,
  [18] = cfg.colors.pain
}

-- ENERGY BAR
local drawBarFrame = CreateFrame("Frame")
drawBarFrame:RegisterEvent("PLAYER_LOGIN")
drawBarFrame:SetScript(
  "OnEvent",
  function()
    -- initialize, has to be done after log in to get correct scaling
    powerType = UnitPowerType("player")
    calculatePixelSize()

    -- background
    energyBarBg = CreateFrame("Frame", "energyBarBg", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    energyBarBg:SetHeight(SnapToPixel(cfg.bar.height))
    energyBarBg:SetWidth(SnapToPixel(cfg.bar.width))
    energyBarBg:SetPoint(cfg.pos.a1, cfg.pos.af, cfg.pos.a2, SnapToPixel(cfg.pos.x), SnapToPixel(cfg.pos.y))
    energyBarBg:SetBackdrop(backdrop_tab)
    energyBarBg:SetBackdropColor(unpack(cfg.colors.bg))
    energyBarBg:SetBackdropBorderColor(0, 0, 0, 1)

    -- bar
    energyBar = CreateFrame("StatusBar", "energyBar", energyBarBg, BackdropTemplateMixin and "BackdropTemplate")
    energyBar:SetStatusBarTexture(cfg.bar.texture)
    energyBar:SetPoint("TOPLEFT", energyBarBg, "TOPLEFT", SnapToPixel(1), SnapToPixel(-1))
    energyBar:SetPoint("BOTTOMRIGHT", energyBarBg, "BOTTOMRIGHT", SnapToPixel(-1), SnapToPixel(1))
    local powerColor = powerColors[powerType]
    energyBar:SetStatusBarColor(unpack(powerColor))
    -- text
    energyBarText = energyBar:CreateFontString(nil, "OVERLAY")
    energyBarText:SetFont(cfg.text.font, cfg.text.size, "THINOUTLINE")
    energyBarText:SetPoint(
      cfg.text.pos.a1,
      cfg.text.pos.af,
      cfg.text.pos.a2,
      SnapToPixel(cfg.text.pos.x),
      SnapToPixel(cfg.text.pos.y)
    )
    energyBarText:SetJustifyH("RIGHT")

    energyBar:SetScript(
      "OnUpdate",
      function(self, elapsed)
        self:SetMinMaxValues(
          0,
          UnitPowerMax("player", powerType),
          true and Enum.StatusBarInterpolation.ExponentialEaseOut or nil
        )
        self:SetValue(UnitPower("player", powerType), true and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)
      end
    )

    energyBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    energyBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    energyBar:RegisterEvent("UNIT_AURA")
    energyBar:RegisterEvent("UNIT_POWER_FREQUENT")
    energyBar:SetScript(
      "OnEvent",
      function(self, event, ...)
        energyBarText:SetText(UnitPower("player"))
      end
    )
    energyBar:Show()
  end
)

-- CPS
local maxCp, current, chargedIndices
local cpArray = {}

local cpColors = {
  [1] = {r = 1, g = 0.76, b = 0},
  [2] = {r = 1, g = 0.76, b = 0},
  [3] = {r = 1, g = 0.76, b = 0},
  [4] = {r = 1, g = 0.76, b = 0},
  [5] = {r = 0.78, g = 0, b = 0.22},
  [6] = {r = 0.56, g = 0.05, b = 0.25},
  [7] = {r = 0.56, g = 0.05, b = 0.25}
}

local function calculateCpWidth(maxCp, width, spacing)
  local totalSpacing = (maxCp - 1) * spacing
  local availableWidth = width - totalSpacing
  return availableWidth / maxCp
end

local function positionCpArray(cpArray, maxCp)
  for i = 1, maxCp do
    local cpBarBg = cpArray[i]
    if i == 1 then
      cpBarBg:SetPoint(
        cfg.cp.pos.a1,
        cfg.cp.pos.af,
        cfg.cp.pos.a2,
        SnapToPixel(cfg.cp.pos.x),
        SnapToPixel(cfg.cp.pos.y)
      )
    else
      cpBarBg:SetPoint("LEFT", cpArray[i - 1], "RIGHT", SnapToPixel(cfg.cp.spacing), 0)
    end
  end
end

local function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function setCurrentCpState(current, max, chargedIndices)
  for i = 1, max do
    cpArray[i]:SetAlpha(i <= current and 1 or 0.3)
    if chargedIndices then
      if contains(chargedIndices, i) then
        cpArray[i]:GetChildren():SetStatusBarColor(unpack(cfg.cp.chargedColour))
      else
        cpArray[i]:GetChildren():SetStatusBarColor(cpColors[i].r, cpColors[i].g, cpColors[i].b)
      end
    else
      cpArray[i]:GetChildren():SetStatusBarColor(cpColors[i].r, cpColors[i].g, cpColors[i].b)
    end
  end
end

local function prepareCpFrames(maxCp) -- only create missing ones, avoids recreating on every redraw
  for i = #cpArray + 1, maxCp do
    local cpBarBg = CreateFrame("Frame", "cpBarBg", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    cpBarBg:SetHeight(SnapToPixel(cfg.cp.height))
    cpBarBg:SetBackdrop(backdrop_tab)
    cpBarBg:SetBackdropColor(unpack(cfg.colors.bg))
    cpBarBg:SetBackdropBorderColor(unpack(cfg.colors.bg))

    local cpBar = CreateFrame("StatusBar", "cpBar", cpBarBg, BackdropTemplateMixin and "BackdropTemplate")
    cpBar:SetStatusBarTexture(cfg.cp.texture)
    cpBar:SetPoint("TOPLEFT", cpBarBg, "TOPLEFT", SnapToPixel(1), SnapToPixel(-1))
    cpBar:SetPoint("BOTTOMRIGHT", cpBarBg, "BOTTOMRIGHT", SnapToPixel(-1), SnapToPixel(1))
    cpBar:SetStatusBarColor(cpColors[i].r, cpColors[i].g, cpColors[i].b)
    cpBar:SetMinMaxValues(0, 1)
    cpBar:SetValue(1)
    table.insert(cpArray, cpBarBg)
  end

  local totalWidth = SnapToPixel(cfg.bar.width)
  local gapSize = SnapToPixel(cfg.cp.spacing)
  local cpWidth = calculateCpWidth(maxCp, totalWidth, gapSize)

  for i = 1, maxCp do
    cpArray[i]:SetWidth(cpWidth)
    cpArray[i]:Show()
  end

  -- hide inactive ones, that exceed current allowed talented max
  for i = maxCp + 1, #cpArray do
    cpArray[i]:Hide()
  end

  -- reposition all
  positionCpArray(cpArray, maxCp)
end

local function updateCurrentCp()
  current = UnitPower("player", Enum.PowerType.ComboPoints)
end

local function updateMaxCp()
  maxCp = UnitPowerMax("player", Enum.PowerType.ComboPoints)
end

local function updateChargedCp()
  chargedIndices = GetUnitChargedPowerPoints("player")
end

local function updateAllCpState()
  updateMaxCp()
  updateCurrentCp()
  updateChargedCp()
end

local function hasCp()
  return UnitPowerMax("player", Enum.PowerType.ComboPoints) > 0
end

drawCpFrame = CreateFrame("Frame")
drawCpFrame:RegisterEvent("PLAYER_LOGIN")
drawCpFrame:SetScript(
  "OnEvent",
  function()
    if cfg.cp.enabled == false or not hasCp() then
      return
    end
    updateAllCpState()
    prepareCpFrames(maxCp)
    setCurrentCpState(current, maxCp, chargedIndices)

    local controller = CreateFrame("Frame")
    controller:RegisterEvent("UNIT_POWER_UPDATE")
    controller:RegisterEvent("UNIT_POWER_POINT_CHARGE")
    controller:SetScript(
      "OnEvent",
      function(self, event, unit, powerType)
        if (event == "UNIT_POWER_UPDATE") then
          if unit == "player" and powerType == "COMBO_POINTS" then
            updateCurrentCp()
            setCurrentCpState(current, maxCp, chargedIndices)
          end
        end
        if (event == "UNIT_POWER_POINT_CHARGE") then
          if unit == "player" then
            updateChargedCp()
            setCurrentCpState(current, maxCp, chargedIndices)
          end
        end
      end
    )

    -- RECALC CPS ON CHANGE
    local recalcFrame = CreateFrame("Frame")
    recalcFrame:RegisterEvent("UNIT_MAXPOWER")
    recalcFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    recalcFrame:SetScript(
      "OnEvent",
      function(self, event, unit, powerType)
        if unit == "player" and powerType == "COMBO_POINTS" then
          updateAllCpState()
          prepareCpFrames(maxCp)
          setCurrentCpState(current, maxCp, chargedIndices)
        end
      end
    )
  end
)
