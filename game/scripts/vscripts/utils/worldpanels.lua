WORLDPANELS_VERSION = "0.81"

local haStoI = {[0]="center", [1]="left", [2]="right"}
local haItoS = {center=0, left=1, right=2}
local vaStoI = {bottom=0, center=1, top=2}
local vaItoS = {[0]="bottom", [1]="center", [2]="top"}

if not WorldPanels then
  WorldPanels = class({})
end

local UpdateTable = function(wp)
  local idString = wp.idString
  local pt = wp.pt
  local pids = wp.pids
  for i=1,#pids do
    local pid = pids[i]
    local ptName = "worldpanels_" .. pid

    if not PlayerTables:TableExists(ptName) then
      PlayerTables:CreateTable(ptName, {[idString]=pt}, {pid})
    else
      PlayerTables:SetTableValue(ptName, idString, pt)
    end
  end
end

function WorldPanels:start()
  self.initialized = true

  self.entToPanels = {}
  self.worldPanels = {}
  self.nextID = 0

end

function WorldPanels:CreateWorldPanelForAll(conf)
  local pids = {}
  for i=0,DOTA_MAX_TEAM_PLAYERS do
    if PlayerResource:IsValidPlayer(i) then
      pids[#pids+1] = i;
    end
  end

  return WorldPanels:CreateWorldPanel(pids, conf)
end

function WorldPanels:CreateWorldPanelForTeam(team, conf)
  local count = PlayerResource:GetPlayerCountForTeam(team)
  local pids = {}
  for i=1,count do
    pids[#pids+1] = PlayerResource:GetNthPlayerIDOnTeam(team, i)
  end

  return WorldPanels:CreateWorldPanel(pids, conf)
end

function WorldPanels:CreateWorldPanel(pids, conf)
  --{position, entity, offsetX, offsetY, hAlign, vAlign, entityHeight, edge, duration, data}
  -- duration?
  if type(pids) == "number" then
    pids = {pids}
  end

  local ent = conf.entity
  local ei = conf.entity
  if ent and type(ent) == "number" then
    ei = ent
    ent = EntIndexToHScript(ent)
  elseif ent and ent.GetEntityIndex then
    ei = ent:GetEntityIndex() 
  end

  local pt = {
    layout =            conf.layout,
    position =          conf.position,
    entity =            ei,
    offsetX =           conf.offsetX,
    offsetX =           conf.offsetY,
    entityHeight =      conf.entityHeight,
    edge =              conf.edgePadding,
    data =              conf.data,
  }

  if conf.horizontalAlign then pt.hAlign = haStoI[conf.horizontalAlign] end
  if conf.verticalAlign   then pt.vAlign = vaStoI[conf.verticalAlign] end

  local idString = tostring(self.nextID)

  local wp = {
    id =                self.nextID,
    idString =          idString,
    pids =              pids,
    pt =                pt,
  }

  function wp:SetPosition(pos)
    self.pt.entity = nil
    self.pt.position = pos
    UpdateTable(self)
  end

  function wp:SetEntity(entity)
    local ei = entity
    if entity and not type(entity) == "number" and entity.GetEntityIndex then
      ei = entity:GetEntityIndex() 
    end

    self.pt.entity = ei
    self.pt.position = nil
    UpdateTable(self)
  end

  function wp:SetHorizontalAlign(hAlign)
    self.pt.hAlign = haStoI[hAlign]
    UpdateTable(self)
  end

  function wp:SetVerticalAlign(vAlign)
    self.pt.vAlign = vaStoI[vAlign]
    UpdateTable(self)
  end

  function wp:SetOffsetX(offX)
    self.pt.offsetX = offX
    UpdateTable(self)
  end

  function wp:SetOffsetY(offY)
    self.pt.offsetY = offY
    UpdateTable(self)
  end

  function wp:SetEntityHeight(height)
    self.pt.entityHeight = height
    UpdateTable(self)
  end

  function wp:SetEdgePadding(edge)
    self.pt.edge = edge
    UpdateTable(self)
  end

  function wp:SetData(data)
    self.pt.data = data
    UpdateTable(self)
  end

  function wp:Delete()
    for j=1,#self.pids do
      local pid = self.pids[j]
      PlayerTables:DeleteTableKey("worldpanels_" .. pid, self.idString)
    end
  end

  if conf.duration then
    pt.endTime = GameRules:GetGameTime() + conf.duration
    Timers:CreateTimer(conf.duration,function()
      wp:Delete()
    end)
  end

  UpdateTable(wp)

  if ei then
    self.entToPanels[ent] = self.entToPanels[ent] or {}
    table.insert(self.entToPanels[ent], wp)
  end

  self.worldPanels[self.nextID] = wp
  self.nextID = self.nextID + 1
  return wp
end

if not WorldPanels.initialized then WorldPanels:start() end