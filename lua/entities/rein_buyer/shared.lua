ENT.Base = "base_ai";
ENT.Type = "ai";
ENT.PrintName		= "Buyer";
ENT.Category 		= "DESANTARP Stealing Kidney";
ENT.Author			= "Skyyrize";
ENT.Spawnable			= true;
ENT.AdminSpawnable		= true;
ENT.AutomaticFrameAdvance = true 

function ENT:SetAutomaticFrameAdvance(bUsingAnim) 
	self.AutomaticFrameAdvance = bUsingAnim 
end
