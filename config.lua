local A, L = ...

local mediapath = "Interface\\AddOns\\" .. A .. "\\media\\"
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

-- Register your custom media with LSM if available
if LSM then
  LSM:Register("statusbar", "Skullflower", mediapath .. "Skullflower")
  LSM:Register("statusbar", "Skullflower3", mediapath .. "Skullflower3")
  LSM:Register("font", "Expressway", mediapath .. "Expressway.ttf")
end

L.cfg = {
  pos = {a1 = "CENTER", a2 = "CENTER", af = "UIParent", x = 0, y = -251},
  bar = {
    height = 16,
    width = 210,
    texture = LSM and LSM:Fetch("statusbar", "Skullflower3") or mediapath .. "Skullflower3"
  },
  
  cp = {
    enabled = true,
    height = 16,
    texture = LSM and LSM:Fetch("statusbar", "Skullflower") or mediapath .. "Skullflower",
    pos = {a1 = "LEFT", a2 = "LEFT", af = "energyBarBg", x = 0, y = -18},
    spacing = 2,
    chargedColour = {66 / 255, 164 / 255, 245 / 255, 1}
  },

  text = {
    font = LSM and LSM:Fetch("font", "Expressway") or mediapath .. "Expressway.ttf",
    size = 15,
    pos = {a1 = "TOP", a2 = "TOP", af = "energyBar", x = 0, y = 7}
  },

  colors = {
    bg = {0 / 255, 0 / 255, 0 / 255, 1},
    mana = {0 / 255, 190 / 255, 230 / 255, 1},
    rage = {102 / 255, 65 / 255, 65 / 255, 1},
    focus = {230 / 255, 140 / 255, 60 / 255, 1},
    energy = {246 / 255, 222 / 255, 32 / 255, 1},
    runicpower = {0 / 255, 190 / 255, 230 / 255, 1},
    lunarpower = {65 / 255, 65 / 255, 65 / 255, 1},
    maelstrom = {0 / 255, 127 / 255, 255 / 255, 1},
    insanity = {65 / 255, 65 / 255, 65 / 255, 1},
    fury = {65 / 255, 65 / 255, 65 / 255, 1},
    pain = {65 / 255, 65 / 255, 65 / 255, 1}
  },

  specs = {
    -- Rogue
    [259] = { -- Assassination
      finishOffset = 2,
      cpColours = {
        ["standard"] = {1, 0.76, 0},
        ["finish"] = {0.78, 0, 0.22},
        ["last"] = {0.56, 0.05, 0.25},
      },
    },
    [260] = { -- Outlaw
      finishOffset = 3,
      cpColours = {
        ["standard"] = {1, 0.76, 0},
        ["finish"] = {0.78, 0, 0.22},
        ["last"] = {0.56, 0.05, 0.25},
      },
    },
    [261] = { -- Subtlety
      finishOffset = 2,
      cpColours = {
        ["standard"] = {1, 0.76, 0},
        ["finish"] = {0.78, 0, 0.22},
        ["last"] = {0.56, 0.05, 0.25},
      },
    },
  }
}
