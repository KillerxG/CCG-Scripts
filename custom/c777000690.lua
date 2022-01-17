--Draconic Witch - Zero
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Search "Draconic"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--(2)Search Ritual Cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.rthcon)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
	--(3)Type Dragon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ADD_RACE)
	e4:SetCondition(s.con)
	e4:SetValue(RACE_DRAGON)
	c:RegisterEffect(e4)
end
--(1)Search "Draconic"
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x300) and not c:IsCode(id) and c:IsAbleToHand()
		and (check==0 or Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,c,e,tp))
end
function s.banfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsAbleToRemoveAsCost() or c:IsAbleToRemove()) 
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,1)
	if chk==0 then return (a or b) end
	if b and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil) ---- banish
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil) ---- banish
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) and e:GetLabel()~=1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.ConfirmCards(1-tp,g)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or e:GetLabel()~=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(2)Search Ritual Cards
function s.cfilter(c,tp)
	return c:IsRace(RACE_DRAGON)
end
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.rthfilter(c)
	return (c:IsRitualMonster() or c:IsRitualSpell()) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(3)Type Dragon
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_MZONE)
end