--Genshin Impact - Paimon
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon Method
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Prevent Target Attack/Effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.imcon)
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--Change Attribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
--Link Summon Method
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x291,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
--Prevent Target Attack/Effect
function s.imfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x291)
end
function s.imcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(s.imfilter,1,nil)
end
--Change Attribute
function s.cfilter(c,tp)
	return c:IsFaceup() 
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.cfilter,nil,tp)
	local aat=aux.AnnounceAnotherAttribute(g,tp)
	e:SetLabel(aat)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil,tp)
	for tc in aux.Next(g) do
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(e:GetLabel())
	e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e4)
	end
end