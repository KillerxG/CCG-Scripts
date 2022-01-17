--SAO Alicization Arc - Leafa
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Material
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x297),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
    --(1)Recover LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	--(2)Revive
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(3)Gain LP
	local e3=Effect.CreateEffect(c)	
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.rec2tg)
	e3:SetOperation(s.rec2op)
	c:RegisterEffect(e3)
end
--(1)Recover LP
function s.mfilter(c)
	return not c:IsSetCard(0x297)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) 
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and #mg>0 and not mg:IsExists(s.mfilter,1,nil)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local rec=bc:GetBaseAttack()
	if rec<0 then rec=0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
--(2)Revive
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and rp==1-tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1297,2,REASON_COST) end
  Duel.RemoveCounter(tp,1,0,0x1297,2,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
--(3)Gain LP
function s.recfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x297) and c:GetAttack()>0
end
function s.rec2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.rec2op(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
	local rec=Duel.Recover(tp,tc:GetAttack()/2,REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsFaceup() and rec>0 then 
	  local e1=Effect.CreateEffect(c)
	  e1:SetType(EFFECT_TYPE_SINGLE)
	  e1:SetCode(EFFECT_UPDATE_ATTACK)
	  e1:SetValue(rec/2)
	  e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
	  c:RegisterEffect(e1)
	end
  end
end