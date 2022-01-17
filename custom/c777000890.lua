--Dragonborn Fighter
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
	c:EnableReviveLimit()
	--(1)Destroy Replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.desreptg)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--(2)Return to Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.redtg)
	e2:SetOperation(s.redop)
	c:RegisterEffect(e2)
end
--Link Summon
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DRAGON,lc,sumtype,tp)
end
--(1)Destroy Replace
function s.repfilter(c,e,tp)
	return c:IsLocation(LOCATION_MZONE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetLinkedGroup()
		return not c:IsReason(REASON_REPLACE) and g:IsExists(s.repfilter,1,nil,e,tp)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetLinkedGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.repfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
--(2)Return to Extra Deck
function s.redtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToExtra() end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.redfilter(c)
  return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.redop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
  if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) 
  and Duel.IsExistingMatchingCard(s.redfilter,tp,LOCATION_REMOVED,0,1,nil) 
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.redfilter),tp,LOCATION_REMOVED,0,1,2,nil)
  Duel.SendtoDeck(g1,nil,2,REASON_EFFECT)
  local g2=Duel.GetOperatedGroup()
  if g2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
  local ct=g2:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
  if ct>0 then
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
  end
  end
end