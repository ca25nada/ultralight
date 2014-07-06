return Def.ActorFrame{
	Font("mentone","24px")..{
		InitCommand=cmd(NoStroke;zoom,0.65;halign,1);
		SetGradeCommand=function(self,params)
			local sGrade = params.Grade or 'Grade_None';
			local gradeString = THEME:GetString("Grade",ToEnumShortString(sGrade))
			self:settext(gradeString)
			self:diffuse(CustomGradeColor(sGrade))

		end;
	};
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,100;x,-280;y,7;zoomto,8,24;diffuse,color("#ffcccc"););
		SetGradeCommand=function(self,params)
			local song = params.Song
			local sGrade = params.Grade or 'Grade_None';

			--local gradeString = THEME:GetString("Grade",ToEnumShortString(sGrade))
			self:diffuse(CustomGradeColor(sGrade))
			--self:diffuse(color(tostring(math.random(1,100)/100)..','..tostring(math.random(1,100)/100)..','..tostring(math.random(1,100)/100)..','..tostring(math.random(50,100)/100)))
		end;
	};
	Def.Quad{
		InitCommand=cmd(halign,1;draworder,100;x,-280;y,7;zoomto,8,24;blend,Blend.Add;diffusealpha,0.25);
		OnCommand=cmd(effectclock,"beat";diffuseshift;effectcolor1,color("1,1,1,0.8");effectcolor2,color("1,1,1,0.2"););
		SetGradeCommand=function(self,params)
			local sGrade = params.Grade or 'Grade_None';
			self:diffusealpha(0)
			if sGrade ~= 'Grade_None' and sGrade ~= 'Grade_Failed' then
				self:diffusealpha(0.2)
			end;
		end;
	};
}