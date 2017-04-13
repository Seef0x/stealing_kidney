AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");


function ENT:Initialize()
	self:SetModel("models/gibs/antlion_gib_large_3.mdl");
	self:SetMaterial("models/props_pipes/Pipesystem01a_skin3");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetPos(self:GetPos()+Vector(0, 0, 32));
	self:GetPhysicsObject():SetMass(50);
	self:SetModelScale( self:GetModelScale() * .25, 0 )
	self:DrawShadow( false );

	local price = math.random(Prix_du_rein_min,Prix_du_rein_max);

	self:SetNWInt("price", price);


  
end;

function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("rein_kidney");
	ent:SetPos(trace.HitPos + trace.HitNormal * 8);
	ent:Spawn();
	ent:Activate();
 
	return ent;
end;


function ENT:Use(activator, caller)

	local curTime = CurTime();
		if (!self.nextUse or curTime >= self.nextUse) then
				activator:SetNWInt("player_money_kidney", activator:GetNWInt("player_money_kidney")+(self:GetNWInt("price")));
				activator:SendLua("local tab = {Color(255,255,255), [[Vous avez prit un]],  Color(127, 0, 0), [[ rein ]], Color(255,255,255),[[d'une valeur de ]], Color(128, 255, 128), [["..math.Round(self:GetNWInt("price")).."$.]], Color(255, 255, 255), [[]] } chat.AddText(unpack(tab))");
				activator:SendLua("local tab = {Color(255,255,255), [[Allez voir l']],  Color(127, 0, 0), [[Acheteur d'Organes ]], Color(255,255,255),[[pour vendre vos reins ]], Color(128, 255, 128) } chat.AddText(unpack(tab))");
				self:Remove();
			self.nextUse = curTime + 1;
		end;
end;