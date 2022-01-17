--Kurai Seishin - Asmodeus
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    --Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	c:EnableReviveLimit()
    --(1)Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--(2)Destroy 2+ of your monsters, and if you do, for every 2 destroyed, draw 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e3)
	--(3)return
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.retreg)
	c:RegisterEffect(e4)
end
--Can treat a Spirit monster as a Tuner
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_SPIRIT,scard,sumtype,tp)
end
--(1)Immune
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
--(2)Destroy 2+ of your monsters, and if you do, for every 2 destroyed, draw 1
function s.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsReleasable(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,2,nil,e) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD,0,2,99,nil,e)
	local ct=Duel.Release(g,REASON_EFFECT)
	if ct>1 then
		Duel.Draw(tp,math.floor(ct/2),REASON_EFFECT)
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