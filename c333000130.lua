--Festos Tools - Minos Shield
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x311))
		--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
	--DEF increase
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	e2:SetCondition(s.valcon)
	c:RegisterEffect(e2)
	--new equip target and make it one target possible
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.cost)
	e3:SetCondition(s.condtion)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
	--Add counter
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetOperation(s.acop)
    c:RegisterEffect(e4)
end
--gain atk/def
function s.con(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
-- cannot be destroyed
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
function s.valcon(e,re,r,rp)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
-- swap equips
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x311,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x311,2,REASON_COST)
end
function s.condtion(e)
	return e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x311) and c:IsFaceup() and c~=e:GetHandler():GetEquipTarget()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		--only targetable
		--unique attack
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_ONLY_BE_ATTACKED)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetCondition(s.atkcon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
		--eff target
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e4:SetRange(LOCATION_SZONE)
		e4:SetTargetRange(0,1)
		e4:SetTarget(s.efftg)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetValue(aux.tgoval)
		c:RegisterEffect(e4)
	end
end
--only targetable
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()~=nil
end
function s.efftg(e,c)
	return c~=e:GetHandler():GetEquipTarget() and c:GetOwner()==e:GetHandler():GetEquipTarget():GetOwner()
end
-- add counter
function s.acfilter(c)
    return c:IsSetCard(0x311) and c:IsFaceup()
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(s.acfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(0x311,1)
    Duel.RDComplete()
end
end