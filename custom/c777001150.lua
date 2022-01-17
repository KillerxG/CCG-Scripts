--Ruler of Timerx - Chronos
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
    --(1)Disable type of Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--(2)Ritual Summon Limit
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--(3)Attack All
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--(4)Special Summon condition
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(s.spconlimit)
	c:RegisterEffect(e4)
	--(5)Treat Fusion as Timerx
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_EXTRA,0)
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
	e5:SetValue(0x305)
	c:RegisterEffect(e5)
end
s.listed_names={777000850}
--Ritual Material Limit
function s.mat_filter(c)
	return c:IsLocation(LOCATION_PUBLIC+LOCATION_HAND) or (c:IsCode(id) and c:IsLocation(LOCATION_DECK))
end
--(1)Disable type of Summon
function s.cfilter(c)
	return c:IsSetCard(0x305) and c:IsType(TYPE_FUSION) and c:IsAbleToExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SendtoDeck(g,nil,0,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.SelectOption(tp,1057,1056,1063,1073,1074,1076))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ct=nil
	if opt==0 then ct=TYPE_RITUAL end
	if opt==1 then ct=TYPE_FUSION end
	if opt==2 then ct=TYPE_SYNCHRO end
	if opt==3 then ct=TYPE_XYZ end
	if opt==4 then ct=TYPE_PENDULUM end
	if opt==5 then ct=TYPE_LINK end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetLabel(ct)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.distg)
	e2:SetLabel(ct)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(e:GetLabel())
end
function s.distg(e,c)
	return c:IsType(e:GetLabel())
end
--(2)Ritual Summon Limit
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_RITUAL==SUMMON_TYPE_RITUAL
end
--(4)Special Summon condition
function s.spconlimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and (se:GetHandler():IsSetCard(0x313) or se:GetHandler():IsSetCard(0x307))
end