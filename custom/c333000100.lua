--Festos Tools - Sparky Gauntlets
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x311))
 --Atk up
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(800)
    e1:SetCondition(s.ctcon)
    c:RegisterEffect(e1)
	--Def up
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(500)
    e2:SetCondition(s.ctcon)
    c:RegisterEffect(e2)
	 --actlimit
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_EQUIP)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,1)
    e3:SetValue(1)
    e3:SetCondition(s.actcon)
    c:RegisterEffect(e3)
    --Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	end
--unstopable atk
function s.ctcon(e)
    return e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
function s.actcon(e)
    return Duel.GetAttacker()==e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():IsType(TYPE_NORMAL)
end
--destroy
function s.descon(e)
    return e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
function s.cosfilter(c)
    return c:IsRace(RACE_MACHINE)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cosfilter,tp,LOCATION_HAND,0,1,nil,tp) and 
	Duel.IsCanRemoveCounter(tp,1,0,0x311,6,REASON_COST) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cosfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.RemoveCounter(tp,1,0,0x311,6,REASON_COST)
	Duel.Destroy(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.Destroy(g,REASON_EFFECT)
end
