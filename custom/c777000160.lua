--Azur Lane Battle Area
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(0)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Enable GY effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--(2)Send to GY or attach an Azur Lane monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	--(3)To Hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
--(2)Send to GY or attach an Azur Lane monster
function s.gepdfilter(c,e,tp,ft)
	return c:IsSetCard(0x298) and c:IsType(TYPE_MONSTER) and (c:IsAbleToGrave()
		or Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e))
end
function s.attfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x298) and not c:IsImmuneToEffect(e)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gepdfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
function s.numbfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x298)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.SelectMatchingCard(tp,s.gepdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		local spchk=ft>0 and tc:IsAbleToGrave()
		local attchk=Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE,0,1,nil,e)
		local op=0
		if spchk and attchk then
			op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		elseif spchk then
			op=0
		elseif attchk then
			op=1
		end
		local success_chk=0
		if op==0 and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
			success_chk=1
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local oc=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
			if oc then
				success_chk=1
				Duel.HintSelection(Group.FromCards(oc))
				Duel.Overlay(oc,tc)
			end
		end
		local ng=Duel.GetMatchingGroup(s.numbfilter,tp,LOCATION_MZONE,0,1,nil)
		if success_chk==1 and Duel.IsBattlePhase() and #ng>0 then
			Duel.BreakEffect()
			for sc in aux.Next(ng) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(sc:GetAttack()*2)
				sc:RegisterEffect(e1)
			end
		end
	end
end
--(3)To Hand
function s.tdfilter(c)
	return c:IsSetCard(0x298) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end