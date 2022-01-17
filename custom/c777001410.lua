--Silver Fangs Angel
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.lkfilter)
	--(2)Set Silver Fangs S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--(1)Special Summon
function s.lkfilter(c)
	return not (c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSetCard(0x307))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=Duel.GetLinkedZone(tp)&0x1f
	if chk==0 then return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=Duel.GetLinkedZone(tp)&0x1f
	if zone~=0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
--(2)Set Silver Fangs S/T
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_LINK and c:GetReasonCard():IsSetCard(0x307)
end
function s.setfilter(c)
  return (c:IsSetCard(0x307) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and not c:IsType(TYPE_LINK) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp)
  and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(500)
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
  if tc then
    Duel.SSet(tp,tc) 
	Duel.ConfirmCards(1-tp,tc) 
	Duel.Recover(p,d,REASON_EFFECT)	
  end
end
