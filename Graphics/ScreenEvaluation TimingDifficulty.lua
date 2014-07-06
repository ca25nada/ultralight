return LoadFont("Common Normal") .. {

	AltText="";
	BeginCommand=function(self)
		text=GetTimingDifficulty();
		self:settextf("Timing Difficulty "..text);
	end;
};