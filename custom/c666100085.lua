--Kurai Seishin - Astreus
--Scripted by Imp
--effect idea by Misaki
local s,id=GetID()
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    --Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--(1)Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--(2)Tribute any number of monsters, destroy that many cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--(3)return
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.retreg)
	c:RegisterEffect(e3)
end
--Can treat a Spirit monster as a Tuner
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_SPIRIT,scard,sumtype,tp)
end
--(2)Tribute any number of monsters, destroy that many cards 
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,false,nil,e) end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local cg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,#g,false,false,nil,e)
	e:SetLabel(#cg)
	Duel.Release(cg,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,e:GetLabel(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local n=e:GetLabel()
	if n>#g then n=#g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=g:Select(tp,n,n,nil)
	if #tg>0 then 
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
--(3)return
function s.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetDescription(1104)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE|RESET_PHASE|PHASE_END)
	e0:SetCondition(aux.SpiritReturnCondition)
	e0:SetTarget(s.rettg)
	e0:SetOperation(s.retop)
	c:RegisterEffect(e0)
	local e00=e0:Clone()
	e00:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	c:RegisterEffect(e00)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e)  and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) then
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc  and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		--Cannot activate its effects
		local e000=Effect.CreateEffect(e:GetHandler())
		e000:SetDescription(3302)
		e000:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e000:SetType(EFFECT_TYPE_SINGLE)
		e000:SetCode(EFFECT_CANNOT_TRIGGER)
		e000:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e000)
        end
     Duel.SpecialSummonComplete()
		end
	end
	end