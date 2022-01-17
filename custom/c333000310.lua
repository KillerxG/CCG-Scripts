--Flamy Elementale LV4
local s,id=GetID()
function s.initial_effect(c)
	--burn from hand, if added from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--Damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)	
	e2:SetCondition(s.condtion)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	-- more damage yeaah
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,id+2)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
	--Reveal itself as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
	--If it was previously in deck
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and rc:IsCode(333000300)
end
	--Activation legality
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	local dmg=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dmg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
	--BURN
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
-- damage effect + reduct atk
function s.c2filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x310) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function s.condtion(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.c2filter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	local dmg=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dmg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT) then
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil,e,tp)
	local atk=(Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND))*300
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		if atk>0 then
		e1:SetValue(-atk)
		else
		e1:SetValue(atk)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
end
end
end
-- more damage yeahhh
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	for rc in aux.Next(eg) do
		if rc:IsStatus(STATUS_OPPO_BATTLE) then
			if rc:IsRelateToBattle() then
				if rc:IsControler(tp) and rc:IsSetCard(0x310) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then return true end
			else
				if rc:IsPreviousControler(tp) and rc:GetPreviousSetCardOnField()==0x310 and 
				Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then return true end
			end
		end
	end
	return false
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local dmg=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*100
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dmg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end