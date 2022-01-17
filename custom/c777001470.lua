--Silver Fangs Dragon Maiden
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Inmune
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetOperation(s.inmop)
	c:RegisterEffect(e1)
end
--(1)Immune
function s.cfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetRace())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.inmop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  --inmune
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(s.inmtg)
  e1:SetValue(s.inmfilter)
  e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
  e1:SetOwnerPlayer(tp)
  Duel.RegisterEffect(e1,tp)
end
function s.inmtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x307)
end
function s.inmfilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end