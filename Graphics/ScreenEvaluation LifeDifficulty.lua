return LoadFont("Common Normal") .. {
	AltText="";
	BeginCommand=function(self)
		text=GetLifeDifficulty();
		self:settextf("Life Difficulty "..text);
	end;
};