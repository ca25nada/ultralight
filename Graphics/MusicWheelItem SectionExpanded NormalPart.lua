return Def.ActorFrame {
	Def.Actor{
		Name="GroupMesageController_Exp";
		SetMessageCommand=function(self,params)
			if params.HasFocus and not params.Song then
				focusIdx = params.Index
				local displayText = params.SongGroup;
				local sectionCount = self:GetParent():GetParent():GetChild("SectionCount");
				local songs = 0;
				if sectionCount then
					songs = sectionCount:GetText();
				end;

				MESSAGEMAN:Broadcast("SectionText", { Text = displayText, Count = tonumber(songs) });
			end;
		end;
	};

	-- background stuff
	--Def.Quad{
	--	Name="Horizontal";
	--	InitCommand=cmd(x,48;y,16;zoomto,SCREEN_CENTER_X,32;diffuse,color("1,1,1,0.175");blend,Blend.Add;vertalign,bottom;fadeleft,0.25;faderight,0.5);
	--};
	--Def.Quad{
	--	Name="Vertical";
	--	InitCommand=cmd(x,48;y,16;zoomto,SCREEN_CENTER_X,32;diffuse,color("1,1,1,0.05");blend,Blend.Add;vertalign,bottom;fadetop,0.85;);
	--};

	-- light stuff
	--[[
	Def.Quad{
		InitCommand=cmd(draworder,101;x,-80;zoomto,8,24;diffuse,HSVA(0,0.3,1,0.5);diffusebottomedge,HSVA(0,0.3,0.925,1));
	};
	Def.Quad{
		InitCommand=cmd(draworder,101;x,-80;zoomto,8,24;blend,Blend.Add;diffusealpha,0.25);
		OnCommand=cmd(diffuseshift;effectcolor1,color("1,1,1,1");effectcolor2,color("1,1,1,0.3"););
	};
	--]]
	-- bottom line
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,-15;zoomto,330,2;diffuse,color("#ffffff"));
	};
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,16;zoomto,330,2;diffuse,color("#ffffff"));
	};
	---------------------------
	Def.Quad{
		InitCommand=cmd(halign,1;x,240;y,0;zoomto,330,32;diffuse,color("#ffe5e5"));
	};
};