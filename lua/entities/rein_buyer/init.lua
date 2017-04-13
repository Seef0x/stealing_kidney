AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize( )
	
	self:SetModel( "models/gman_high.mdl" ) -- <-- LE MODEL DE VOTRE NPC
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	self:SetMaxYawSpeed( 90 )

		local buyerText = ents.Create("rein_buyer_text");
		buyerText:SetPos(self:GetPos() + Vector(0, 0, 72));
		buyerText:SetParent(self);
		buyerText:Spawn();
	
end

function ENT:OnTakeDamage()
	return false --<-- SI TRUE ALORS VOTRE NPC PREND DES DEGATS
end 


function ENT:AcceptInput(name, activator, caller)	
	if (!self.nextUse or CurTime() >= self.nextUse) then
		if (name == "Use" and caller:IsPlayer() and (caller:GetNWInt("player_money_kidney") == 0)) then		
			caller:SendLua("local tab = {Color(127,0,0,255), [[Acheteur d'Organes: ]], Color(255,255,255), [["..table.Random(rein_buyer_Salesman_Nobuyer).."]] } chat.AddText(unpack(tab))");
			timer.Simple(0.25, function() self:EmitSound(table.Random(rein_buyer_Salesman_Nobuyer_Sound), 100, 100) end);
		elseif (name == "Use") and (caller:IsPlayer()) and (caller:GetNWInt("player_money_kidney") > 0) then
			caller:addMoney(caller:GetNWInt("player_money_kidney"));
			caller:SendLua("local tab = {Color(127,0,0,255), [[Acheteur d'Organes: ]], Color(255,255,255), [["..table.Random(rein_buyer_Salesman_Gotbuyer)..", voici vos ]], Color(128, 255, 128), [["..caller:GetNWInt("player_money_kidney").."$.]] } chat.AddText(unpack(tab))");
			caller:SetNWInt("player_money_kidney", 0);
			if (rein_buyer_MakeWanted) then
				caller:wanted(nil, "Vente d'Organes");
			end;
		end;
		self.nextUse = CurTime() + 1;
	end;
end;