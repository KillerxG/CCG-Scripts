--
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	Card.Alias(c,237)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
    --(1)
	
end