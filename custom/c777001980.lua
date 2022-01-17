--Warbeast Combat
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --(1)Double the ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--(2)Direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.datg)
	c:RegisterEffect(e2)	
end
--(1)Double the ATK
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x308) and c:IsType(TYPE_TOKEN)
end
function s.val(e,c)
	return c:GetAttack()*2
end
--(2)Direct attack
function s.datg(e,c)
	return c:IsSetCard(0x308) and c:IsFaceup()
end