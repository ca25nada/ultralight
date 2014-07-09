return Def.ActorFrame{
	Def.Quad{
		Name="Horizontal";
		InitCommand=cmd(draworder,-350;x,48;y,14;zoomto,SCREEN_CENTER_X,32;diffuse,color("1,0.6,0.6,0.05");blend,Blend.Add;vertalign,bottom;fadeleft,0.5;faderight,0.5);
		OffCommand=cmd(visible,false);
	};

	Def.Quad{
		InitCommand=cmd(halign,0;draworder,-250;x,0-(SCREEN_WIDTH-240)+SCREEN_CENTER_X*0.225;y,15;zoomto,(SCREEN_WIDTH-330)-(SCREEN_CENTER_X*0.225),2;diffuse,color("1,1,1,1");blend,Blend.Add;halign,left;vertalign,bottom);
		OffCommand=cmd(visible,false);
		CodeMessageCommand=function(self,params)
			self:finishtweening();
			if params.Name == "ScoreStat" then
				self:bouncebegin(0.375)
				self:addy(-SCREEN_HEIGHT)
			end;
			if params.Name == "ScoreStatOff" then
				self:bouncebegin(0.375)
				self:y(15)
			end;
		end;
	};

	Def.Quad{
		InitCommand=cmd(halign,1;draworder,-1;x,240;y,-1;zoomto,330,28;blend,Blend.Add;diffusealpha,0.25);
		OnCommand=cmd(diffuseshift;effectcolor1,color("1,1,1,0.3");effectcolor2,color("1,1,1,0"););
	};

};