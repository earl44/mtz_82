_=[[                             toggleAnimParts.lua
--------------------------------------------------------------------------------------------------------------------
Author: Sven777b (ICQ#95176001)

Version 1.0 - 12.04.2010 
Version 1.3 - 19.04.2010
Version 1.4 - 30.07.2011
Version 1.5 - 11.08.2011

frei verwendbar - keine erlaubnis nötig  |  free for use - no permission needed.
Modifikationen erst nach Rücksprache!    |  modifications only with my permission.

Hinweis: das Kopieren von Sourcecode ist strafbar nach UrhG §2.1
--------------------------------------------------------------------------------------------------------------------

Fahrzeug XML:

<animParts>
  <animPart index="1" id="dachfenster" showHelp="true" rotMin="0 0 0" rotMax="15 0 0" moveTime="3" />
  <animPart index="2" id="fenster_links" transMin="0 0 0" transMax="0 0.4 0" moveTime="3" />
  <animPart index="3" id="fenster_rechts" scaleMin="1 0.5 1" scaleMax="1 1 1" moveTime="3" />
  <animPart index="4" id="ventilator" permRotAxis="3" moveTime="0.1" />
  <animPart index="5" id="rulDrehkoerper" permRotAxis="2" moveTime="0.1" listenTo="beaconLightsActive" />
  <animPart index="6" id="Heckklappe" rotMin="0 0 0" rotMax="15 0 0" moveTime="8" isMovingTool="true" />
</animParts>

=================================================================
id : frei vergebener Name - ist gleichzeitig Bezeichner für l10n Text und InputBinding
showHelp : true/false - Hilfetext anzeigen oder nicht
rotMin/rotMax : rotation auf 3 Achsen
transMin/transMax : bewegung auf 3 Achsen
scaleMin/scaleMax : skalierung auf 3 Achsen - alles kombinierbar
moveTime : Laufzeit in Sekunden in der die Bewegung abgeschlossen wird.
autoReturn : true/false - wenn true, dann kehrt die Animation zurück sobald der Knopf losgelassen wird.
permRotAxis : 1-3 - rotiert das Objekt permanent um die angegebene Achse. moveTime definiert dabei die Zeit für eine 360° Umdrehung.
listenTo : übergeht das InputBinding und reagiert stattdessen auf die angegebene Variable. So kann man eine Bewegung zum Beispiel ans Licht koppeln
isMovingTool : true/false - wenn true wird das zugehörige movingTool aktualisiert um so eine Kollision oder Zylinder mit zu bewegen. 
=================================================================

moddesc:
Abschnitt <specializations> : <specialization name="Fenster" className="toggleAnimatedParts" filename="toggleAnimatedParts.lua"/> 
Abschnitt <vehicleTypes> : <specialization name="Fenster"/>

(für jedes InputBinding sollte ein passender Text in l10n angelegt werden welcher auch als Hilfetext dient)
<l10n>
   <text name="dachfenster">
      <de>Dachfenster</de>
      <en>roofwindow</en>
   </text>
</l10n>

(die InputBindings müssen ebenfalls definiert werden)
<inputBindings>
  <input name="dachfenster" key1="KEY_5" button="" />
  <input name="fenster_links" key1="KEY_6" button="" />
  <input name="fenster_rechts" key1="KEY_7" button="" />
</inputBindings>
]]

toggleAnimatedParts = {};

function toggleAnimatedParts.prerequisitesPresent(specializations)
    return true;
end;

function toggleAnimatedParts:load(savegame)
	self.toggle = SpecializationUtil.callSpecializationsFunction("toggle");
	self.animParts = {};
	local c = 0;
	while true do
		local baseString = string.format("vehicle.animParts.animPart(%d)#",c);
		local index = getXMLString(self.xmlFile,baseString.."index");
		local id = getXMLString(self.xmlFile,baseString.."id");
		local listenTo = getXMLString(self.xmlFile,baseString.."listenTo");
		if index == nil or id == nil or (InputBinding[id] == nil and listenTo == nil) then
			break;
		end;
		local part = {};
		part.index = Utils.indexToObject(self.components, index);
		part.id = id;
		part.listenTo = listenTo;
		
		local rotMin = getXMLString(self.xmlFile,baseString.."rotMin");
		local rotMax = getXMLString(self.xmlFile,baseString.."rotMax");
		if rotMin ~= nil and rotMax ~= nil then
			local x,y,z = Utils.getVectorFromString(rotMin);
			part.rotMin = {math.rad(Utils.getNoNil(x,0)),math.rad(Utils.getNoNil(y,0)),math.rad(Utils.getNoNil(z,0))};
			local x,y,z = Utils.getVectorFromString(rotMax);
			part.rotMax = {math.rad(Utils.getNoNil(x,0)),math.rad(Utils.getNoNil(y,0)),math.rad(Utils.getNoNil(z,0))};
		end;
		
		local transMin = getXMLString(self.xmlFile,baseString.."transMin");
		local transMax = getXMLString(self.xmlFile,baseString.."transMax");
		if transMin ~= nil and transMax ~= nil then
			local x,y,z = Utils.getVectorFromString(transMin);
			part.transMin = {Utils.getNoNil(x,0),Utils.getNoNil(y,0),Utils.getNoNil(z,0)};
			local x,y,z = Utils.getVectorFromString(transMax);
			part.transMax = {Utils.getNoNil(x,0),Utils.getNoNil(y,0),Utils.getNoNil(z,0)};
		end;
		
		local scaleMin = getXMLString(self.xmlFile,baseString.."scaleMin");
		local scaleMax = getXMLString(self.xmlFile,baseString.."scaleMax");
		if scaleMin ~= nil and scaleMax ~= nil then
			local x,y,z = Utils.getVectorFromString(scaleMin);
			part.scaleMin = {Utils.getNoNil(x,1),Utils.getNoNil(y,1),Utils.getNoNil(z,1)};
			local x,y,z = Utils.getVectorFromString(scaleMax);
			part.scaleMax = {Utils.getNoNil(x,1),Utils.getNoNil(y,1),Utils.getNoNil(z,1)};
		end;
		
		local permRotAxis = getXMLInt(self.xmlFile,baseString.."permRotAxis");
		if permRotAxis ~= nil then
			if permRotAxis >= 1 and permRotAxis <= 3 then
				part.permRotAxis = permRotAxis;
			end;
		end;
		
		part.moveTime = Utils.getNoNil(getXMLFloat(self.xmlFile,baseString.."moveTime"),1)*1000;
		part.helpText = Utils.getNoNil(getXMLBool(self.xmlFile, baseString.."showHelp"),false);
		part.autoReturn = Utils.getNoNil(getXMLBool(self.xmlFile, baseString.."autoReturn"),false);
		part.isMovingTool = Utils.getNoNil(getXMLBool(self.xmlFile, baseString.."isMovingTool"),false);
		part.toMax = false;
		part.move = false;
		table.insert(self.animParts,part);
		c=c+1;
	end;
	self.isSelectable = true;
end;

function toggleAnimatedParts:delete()
end;

function toggleAnimatedParts:mouseEvent(posX, posY, isDown, isUp, button)
end;

function toggleAnimatedParts:keyEvent(unicode, sym, modifier, isDown)
end;

function toggleAnimatedParts:update(dt)
	if self:getIsActiveForInput() then
		for nr,part in ipairs(self.animParts) do
			if not part.autoReturn then
				if InputBinding.hasEvent(InputBinding[part.id]) then
					self:toggle(nr,not part.toMax); 
				end;
			else
				if InputBinding.isPressed(InputBinding[part.id]) then
					if not part.toMax then
						self:toggle(nr,true); 
					end;
				else
					if part.toMax then
						self:toggle(nr,false); 
					end;
				end;
			end;
		end;
	end;
	if self:getIsActive() then
		for _,part in ipairs(self.animParts) do
			if part.listenTo ~= nil then
				if self[part.listenTo] then
					part.toMax = true;
					part.move = true;
				else
					part.toMax = false;
				end;
			end;
				
			if part.move then
				part.move = false;
				if part.rotMin ~= nil then
					local curRot = {getRotation(part.index)};
					local newRot = Utils.getMovedLimitedValues(curRot, part.rotMax, part.rotMin, 3, part.moveTime, dt, not part.toMax);
					setRotation(part.index, unpack(newRot));
					for i=1,3 do
						if math.abs(newRot[i]-curRot[i]) > 0.001 then
							part.move = true;
						end;
					end;
				end;
				if part.transMin ~= nil then
					local curTrans = {getTranslation(part.index)};
					local newTrans = Utils.getMovedLimitedValues(curTrans, part.transMax, part.transMin, 3, part.moveTime, dt, not part.toMax);
					setTranslation(part.index, unpack(newTrans));
					for i=1,3 do
						if math.abs(newTrans[i]-curTrans[i]) > 0.001 then
							part.move = true;
						end;
					end;
				end;
				if part.scaleMin ~= nil then
					local curScale = {getScale(part.index)};
					local newScale = Utils.getMovedLimitedValues(curScale, part.scaleMax, part.scaleMin, 3, part.moveTime, dt, not part.toMax);
					setScale(part.index, unpack(newScale));
					for i=1,3 do
						if math.abs(newScale[i]-curScale[i]) > 0.001 then
							part.move = true;
						end;
					end;
				end;
				if part.permRotAxis ~= nil then
					local spd = ((2*math.pi) / part.moveTime) * dt;
					local newRot = {0,0,0};
					newRot[part.permRotAxis] = spd;
					rotate(part.index, unpack(newRot));
					part.move = part.toMax;
				end;
				if part.isMovingTool then
					self:setMovingToolDirty(part.index);
				end;
			end;
		end;
	end;
end;

function toggleAnimatedParts:updateTick(dt)
end;

function toggleAnimatedParts:draw()
	if self:getIsActiveForInput() then
		for _,part in ipairs(self.animParts) do
			if part.helpText then
				g_currentMission:addHelpButtonText(g_i18n:getText(part.id), InputBinding[part.id]);
			end;
		end;
	end;
end;

function toggleAnimatedParts:toggle(id,state,nes)
	toggleAnimEvent.sendEvent(self,id,state,nes);
	self.animParts[id].toMax = state;
	self.animParts[id].move = true;
end;

function toggleAnimatedParts:readStream(streamId, connection)
	for nr,part in ipairs(self.animParts) do
		local state = streamReadBool(streamId);
		self:toggle(nr,state,true);
	end;
end;
		
	
function toggleAnimatedParts:writeStream(streamId, connection)
	for nr,part in ipairs(self.animParts) do
		streamWriteBool(streamId,part.toMax);
	end;
end;

toggleAnimEvent = {};
toggleAnimEvent_mt = Class(toggleAnimEvent, Event);
InitEventClass(toggleAnimEvent, "toggleAnimEvent");

function toggleAnimEvent:emptyNew()
    local self = Event:new(toggleAnimEvent_mt);
    self.className="toggleAnimEvent";
    return self;
end;

function toggleAnimEvent:new(object, id, state)
		local self = toggleAnimEvent:emptyNew()
		self.object = object;
		self.id = id;
		self.state = state;
		return self;
end;

function toggleAnimEvent:readStream(streamId, connection)
    self.object = networkGetObject(streamReadInt32(streamId));
		self.id  = streamReadInt8(streamId);
    self.state = streamReadBool(streamId);
    self:run(connection);
end;

function toggleAnimEvent:writeStream(streamId, connection)
    		streamWriteInt32(streamId, networkGetObjectId(self.object));
		streamWriteInt8(streamId, self.id);
		streamWriteBool(streamId, self.state);
end;

function toggleAnimEvent:run(connection)
	self.object:toggle(self.id,self.state, true);
  if not connection:getIsServer() then
      g_server:broadcastEvent(toggleAnimEvent:new(self.object, self.id, self.state), nil, connection, self.object);
  end;	
end;

function toggleAnimEvent.sendEvent(vehicle, id, state, nes)
	if nes == nil or nes == false then
		if g_server ~= nil then
			g_server:broadcastEvent(toggleAnimEvent:new(vehicle, id, state), nil, nil, vehicle);
		else
			g_client:getServerConnection():sendEvent(toggleAnimEvent:new(vehicle, id, state));
		end;
	end;
end;
