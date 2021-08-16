local DRUID_MACRO_HELPER_NAME_START = "dmhStart";
local DRUID_MACRO_HELPER_NAME_RESET = "dmhReset";
local DRUID_MACRO_HELPER_NAME_END = "dmhEnd";
local DRUID_MACRO_HELPER_NAME_POT = "dmhPot";
local DRUID_MACRO_HELPER_NAME_HS = "dmhHs";
local DRUID_MACRO_HELPER_NAME_SAPPER = "dmhSap";
local DRUID_MACRO_HELPER_NAME_SUPER_SAPPER = "dmhSuperSap";
local DRUID_MACRO_HELPER_ITEM_SHORTCUTS = {
  ["pot"] = 13446,
  ["potion"] = 13446,
  ["hs"] = 20520,
  ["rune"] = 20520,
  ["seed"] = 20520,
  ["sapper"] = 10646,
  ["supersapper"] = 23827,
  ["drums"] = 13180,
  ["holywater"] = 13180
};
local DRUID_MACRO_HELPER_LOC_IGNORED = { "SCHOOL_INTERRUPT", "DISARM", "PACIFYSILENCE", "SILENCE", "PACIFY" };
local DRUID_MACRO_HELPER_LOC_SHIFTABLE = { "ROOT" };
local DRUID_MACRO_HELPER_LOC_STUN = { "STUN", "STUN_MECHANIC", "FEAR", "CHARM", "CONFUSE", "POSSESS" };
SLASH_DRUID_MACRO_HELPER1 = "/dmh";
SLASH_DRUID_MACRO_HELPER2 = "/druidmacro";

local function DruidMacroLocStun()
	local i = C_LossOfControl.GetActiveLossOfControlDataCount();
	while (i > 0) do
		local locData = C_LossOfControl.GetActiveLossOfControlData(i);
    if (tContains(DRUID_MACRO_HELPER_LOC_STUN, locData.locType)) then
			return 1;
		end
		i = i - 1;
	end
	return 0;
end

local function DruidMacroLocShiftable()
  if DruidMacroLocStun() > 0 then
    -- Not removable by powershifting if also stunned
    return 0;
  end
	local i = C_LossOfControl.GetActiveLossOfControlDataCount();
	while (i > 0) do
		local locData = C_LossOfControl.GetActiveLossOfControlData(i);
    if (tContains(DRUID_MACRO_HELPER_LOC_SHIFTABLE, locData.locType)) then
			return 1;
		end
		i = i - 1;
	end
	return 0;
end

local function DruidItemIds(itemNamesOrIds)
  local itemIds = {};
  for i in ipairs(itemNamesOrIds) do
    local itemName = strlower(itemNamesOrIds[i]);
    if DRUID_MACRO_HELPER_ITEM_SHORTCUTS[itemName] then
      tinsert(itemIds, DRUID_MACRO_HELPER_ITEM_SHORTCUTS[itemName]);
    else
      tinsert(itemIds, itemNamesOrIds[i]);
    end
  end
  return itemIds;
end

function DruidShifter(spellId, ...)
  local preventShift = GetSpellCooldown(spellId) + DruidMacroLocStun();
  local manaCost = 580;
  local manaCostTable = GetSpellPowerCost(spellId);
  if (manaCostTable) then
    for i in ipairs(manaCostTable) do
      if (manaCostTable[i].type == 0) then
        manaCost = manaCostTable[i].cost;
      end
    end
  end
  local itemIds = {...};
  for i in ipairs(itemIds) do
    preventShift = preventShift + GetItemCooldown(itemIds[i]);
  end
  return (preventShift > 0) or (UnitPower("player",0)<manaCost);
end

function DruidEnergy(spellId, maxEnergy)
  local preventShift = GetSpellCooldown(spellId) + DruidMacroLocStun();
  local manaCost = 580;
  local manaCostTable = GetSpellPowerCost(spellId);
  if (manaCostTable) then
    for i in ipairs(manaCostTable) do
      if (manaCostTable[i].type == 0) then
        manaCost = manaCostTable[i].cost;
      end
    end
  end
  if (not maxEnergy) then
    maxEnergy = 30;
  end
  return (preventShift > 0) or (UnitPower("player",0)<manaCost) or
    ((UnitPower("player",3)>maxEnergy) and DruidMacroLocShiftable() == 0);
end

local function DruidMacroSlash(action, ...)
  local params = {...};
  if (action == "") or (action == "help") then
    print("|cffff0000DruidMacroHelper|r Available commands:");
    print("|cffffff00/dmh start|r Disable autoUnshift if player is stunned, on gcd or out of mana");
    print("|cffffff00/dmh end|r Enable autoUnshift again");
    print("|cffffff00/dmh stun|r Disable autoUnshift if stunned");
    print("|cffffff00/dmh cd <itemId|itemShortcut>[ <itemId|itemShortcut> ...]|r Disable autoUnshift if items are on cooldown, player is stunned, on gcd or out of mana");
    print("|cffffff00/dmh energy <maxEnergy>|r Disable autoUnshift if above given energy value, player is stunned, on gcd or out of mana");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_START.."|r Change actionbar based on the current form. (includes /dmh start)");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_RESET.."|r Change actionbar back to 1.");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_END.."|r Change back to form based on the current bar. (includes /dmh end)");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_POT.."|r Disable autoUnshift if not ready to use a potion");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_HS.."|r Disable autoUnshift if not ready to use a healthstone");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_SAPPER.."|r Disable autoUnshift if not ready to use a sapper");
    print("|cffffff00/click "..DRUID_MACRO_HELPER_NAME_SUPER_SAPPER.."|r Disable autoUnshift if not ready to use a super sapper");
  elseif (action == "stun") then
    -- Disable autoUnshift if stunned
    if DruidMacroLocStun()>0 then
      SetCVar("autoUnshift", 0);
    end
  elseif (action == "cd") then
    -- Disable autoUnshift if items are on cooldown, player is stunned, on gcd or out of mana
    local itemIds = DruidItemIds(params);
    if DruidShifter(768, unpack(itemIds)) then
      SetCVar("autoUnshift", 0);
    end
  elseif (action == "energy") then
    -- Disable autoUnshift if above given energy value, player is stunned, on gcd or out of mana
    local energyMax = tonumber(params[1]);
    if DruidEnergy(768, energyMax) then
      SetCVar("autoUnshift", 0);
    end
  elseif (action == "start") then
    -- Disable autoUnshift if player is stunned, on gcd or out of mana
    if DruidShifter(768) then
      SetCVar("autoUnshift", 0);
    end
  elseif (action == "end") then
    -- Enable autoUnshift again
    SetCVar("autoUnshift", 1);
  end
end

SlashCmdList["DRUID_MACRO_HELPER"] = function(parameters)
  DruidMacroSlash(strsplit(" ", parameters));
end;

do
    local b = _G[DRUID_MACRO_HELPER_NAME_START] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_START, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/changeactionbar [noform]1;[form:1]2;[form:3]3;[form:4]4;[form:5]5;6;\n/dmh start');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_RESET] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_RESET, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/changeactionbar 1');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_END] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_END, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/use [bar:2]!Dire Bear Form;[bar:3]!Cat Form;[bar:4]!Travel Form\n/click '..DRUID_MACRO_HELPER_NAME_RESET..'\n/dmh end');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_POT] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_POT, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/dmh cd pot\n/dmh start');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_HS] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_HS, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/dmh cd hs\n/dmh start');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_SAPPER] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_SAPPER, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/dmh cd sapper\n/dmh start');
end
do
    local b = _G[DRUID_MACRO_HELPER_NAME_SUPER_SAPPER] or CreateFrame('Button', DRUID_MACRO_HELPER_NAME_SUPER_SAPPER, nil, 'SecureActionButtonTemplate,SecureHandlerBaseTemplate');
    b:SetAttribute('type', 'macro');
    b:SetAttribute('macrotext', '/dmh cd supersapper\n/dmh start');
end
