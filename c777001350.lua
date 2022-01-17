--Silver Fangs Red Knight
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Material
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
    c:EnableReviveLimit()
    --(1)Excavate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.excacon)
    e1:SetTarget(s.excatg)
    e1:SetOperation(s.excaop)
    c:RegisterEffect(e1)
	--(1)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
end
--Link Material
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x307,lc,sumtype,tp)
end
--(1)Excavate
function s.excacon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.excafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x307) and c:GetLink()>0
end
function s.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
  local ct=lg:GetSum(Card.GetLink)
  if chk==0 then 
    if ct<=0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
    local g=Duel.GetDecktopGroup(tp,ct)
    return g:FilterCount(Card.IsAbleToHand,nil)>0
  end
  Duel.SetTargetPlayer(tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x307) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.excaop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
  local ct=lg:GetSum(Card.GetLink)
  if ct<=0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
  Duel.ConfirmDecktop(p,ct)
  local g=Duel.GetDecktopGroup(p,ct)
  if g:GetCount()>0 then
    local sg=g:Filter(s.thfilter,nil)
    if sg:GetCount()>0 then
      if sg:GetFirst():IsAbleToHand() then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-p,sg)
        Duel.ShuffleHand(p)
      else
        Duel.SendtoGrave(sg,REASON_EFFECT)
      end
    end
    Duel.ShuffleDeck(p)
		--(1.1)Lock Summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
		--(1.2)Lizard check
		aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
  end
end
--(1.1)Lock Summon
function s.splimit(e,c)
	return not (c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsLocation(LOCATION_EXTRA)
end
--(1.2)Lizard check
function s.lizfilter(e,c)
	return not (c:IsOriginalType(TYPE_LINK) and c:IsOriginalAttribute(ATTRIBUTE_LIGHT))
end
--(2)Special Summon
function s.spfilter1(c,e,tp,zone)
	return c:IsSetCard(0x307) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		Duel.Recover(p,d,REASON_EFFECT)	
	end
end