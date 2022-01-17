--Girly Force - Calling
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Take 2 cards from the deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.tricost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--(1)Take 2 cards from the deck
function s.trifilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL)
end
function s.tricost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.trifilter,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.trifilter,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.filter2(c,e,tp,mft,sft,code)
	return  not c:IsCode(code) and 
		((mft>0 and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x293) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (sft>0 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x293) and not c:IsCode(id) and c:IsSSetable()))
end
function s.filter(c,e,tp,mft,sft)
	return  c:IsAbleToHand() and
	((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x293)) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsSetCard(0x293)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,e,tp,mft,sft,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then sft=sft-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local c2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft,c1:GetFirst():GetCode())
	if c1 and c2 then
		Duel.SendtoHand(c1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c1)
		if c2:GetFirst():IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(c2,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			Duel.SSet(tp,c2)
		end
	end
end