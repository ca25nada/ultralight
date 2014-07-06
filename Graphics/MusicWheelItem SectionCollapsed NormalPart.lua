return Def.ActorFrame {
	Def.Actor{
		Name="GroupMesageController_Col";
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

	-- light thing
	Def.Quad{
		InitCommand=cmd(draworder,101;x,-80;zoomto,8,24;diffuse,HSVA(0,0.2,1,0.5);diffusebottomedge,HSVA(0,0.2,0.925,0));
	};

	-- bottom line
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,-15;zoomto,330,2;diffuse,color("#ffffff"));
	};
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,105;x,240;y,16;zoomto,330,2;diffuse,color("#ffffff"));
	};
	-----------------------------------
	Def.Quad{
		InitCommand=cmd(halign,1;x,240;y,0;zoomto,330,32;diffuse,color("#ffe5e5"));
	};
};