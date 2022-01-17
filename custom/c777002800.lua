--HI3rd APHO, Silver Wing
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,aux.FilterSummonCode(777000050),1,1)
	c:EnableReviveLimit()
	--(1)Alt. Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--(2)Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--(3)Set Gem of Honkai
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	--(4)Send all S/T your opponent controls to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetCountLimit(1)
	e4:SetCondition(s.des2con)
	e4:SetTarget(s.des2tg)
	e4:SetOperation(s.des2op)
	c:RegisterEffect(e4)
	--(5)Halve ATK
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.atktg)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	--(6)Can attack all monsters
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_ATTACK_ALL)
	e6:SetCondition(s.sixthcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--(7)Pierce
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_PIERCE)
	e7:SetCondition(s.sixthcon)
	c:RegisterEffect(e7)
end
--(1)Alt. Special Summon procedure
function s.hspfilter(c,tp,sc)
	return c:IsCode(777000050) and c:GetEquipGroup():IsExists(Card.IsOriginalType,1,nil,TYPE_TOKEN)
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
--(2)Change Position
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.filter(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
		local g2=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #g2>0 then
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end	
end
--(3)Set Gem of Honkai
function s.setfilter(c)
	return (aux.IsCodeListed(c,777000010) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
--(4)Send all S/T your opponent controls to GY
function s.des2con(e,tp,eg,ep,ev,re,r,rp)	
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,777000100)
end
function s.togyfilter(c)
	return c:GetSequence()<5
end
function s.des2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.togyfilter,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.togyfilter,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.des2op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.togyfilter,tp,0,LOCATION_SZONE,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
--(5)Halve ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)	
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,777000020)
end
function s.atktg(e,c)
	return c~=e:GetHandler()
end
function s.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
--(6)Can attack all monsters
--(7)Pierce
function s.sixthcon(e,tp,eg,ep,ev,re,r,rp)	
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,777000030)
end