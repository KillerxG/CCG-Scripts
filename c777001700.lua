--Thunder Force Beast
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Material
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x301),5,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Attach Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	--(3)Banish monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_EQUIP+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
--Xyz Material
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0x301) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
end
--(1)Special Summon
function s.spfilter(c,tp)
	return c:IsControler(1-tp) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsXyzSummonable() and eg:IsExists(s.spfilter,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsXyzSummonable() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.XyzSummon(tp,c,nil)
	end
end
--(2)Attach Material
function s.attfilter1(c,e)
	return c:IsSetCard(0x301) and not c:IsImmuneToEffect(e)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter1,tp,LOCATION_DECK,0,1,nil,e)
		and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.attfilter2(c,e)
	return ((c:IsFaceup() and not c:IsType(TYPE_TOKEN)) or (c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x301) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and not c:IsImmuneToEffect(e)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local exg=Duel.SelectMatchingCard(tp,s.attfilter1,tp,LOCATION_DECK,0,1,1,nil,e)
	if #exg==0 then return end
	Duel.Overlay(c,exg)
	--Attach 1 other card
	local g=Duel.GetMatchingGroup(s.attfilter2,tp,LOCATION_GRAVE,LOCATION_MZONE,c,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		Duel.Overlay(c,tc,true)
	end
end
--(3)Banish monster
function s.banfilter(c,e)
	return c:IsAbleToRemove()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.banfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.banfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end