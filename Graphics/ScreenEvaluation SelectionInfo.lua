return LoadFont("Common normal") .. {
	InitCommand=cmd(zoom,0.5;shadowlength,1;strokecolor,color("#00000033");maxwidth,WideScale(512,640));
	BeginCommand=function(self)
		local Selection, text = nil, "";
		if GAMESTATE:IsCourseMode() then
			Selection = GAMESTATE:GetCurrentCourse();
			text = Selection:GetDisplayMainTitle();
		else
			Selection = GAMESTATE:GetCurrentSong();
			text = Selection:GetDisplayMainTitle() .." / ".. Selection:GetDisplayArtist();
		end;
		self:settext(text);
	end;
};