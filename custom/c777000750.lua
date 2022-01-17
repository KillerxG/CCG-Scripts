--Draconic Fire Wizard
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Treated as a Fusion monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(TYPE_FUSION)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetLabel(0)
	c:RegisterEffect(e3)
	--(3)Fusion Summon
	local params = {aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.FALSE,s.fextra,Fusion.ShuffleMaterial,nil}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e4:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e4)
	--(4)Type Dragon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ADD_RACE)
	e5:SetCondition(s.con)
	e5:SetValue(RACE_DRAGON)
	c:RegisterEffect(e5)
end
--(2)Special Summon
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (check==0 or Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,c,e,tp))
end
function s.banfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsAbleToRemoveAsCost() or c:IsAbleToRemove()) 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0) and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,1) and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (a or b) end
	if b and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_EXTRA,0,1,nil) ---- banish
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil) ---- banish
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and e:GetLabel()~=1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or e:GetLabel()~=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--(3)Fusion Summon
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil)
end
--(4)Type Dragon
function s.con(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_MZONE)
end