--FGO Avenger, Jeanne d'Arc Alter
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--(1)Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--(2)Destroy monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	--(2.1)Register summons
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetLabelObject(e2)
	e2a:SetOperation(s.regop)
	c:RegisterEffect(e2a)
	--(3)SQ Counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetTarget(s.pcttg)
	e3:SetOperation(s.pctop)
	c:RegisterEffect(e3)
	--(3)SQ Counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+CATEGORY_COUNTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
end
s.listed_names={777002210}
--(1)Destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsPosition(POS_FACEUP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP)
	local atk=math.floor(g:GetFirst():GetBaseAttack())
	if atk<0 then atk=0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=math.floor(tc:GetBaseAttack())
		if atk<0 then atk=0 end
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
--(2)Destroy monster
function s.filter(c,tp,e)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) 
		and (not e or c:IsRelateToEffect(e))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.filter,nil,tp,nil)
	if chk==0 then return #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=e:GetLabelObject()
	if #g==0 then return end 
	local bg=g:FilterSelect(tp,s.filter,1,1,nil,tp,e)
	if #bg>0 and Duel.Destroy(bg,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end
--(2.1)Register summons
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=eg:Filter(s.filter,nil,tp)
	if #tg>0 then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
--(3)SQ Counter
--(4)SQ Counter
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0x294) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
  if tc and tc:IsFaceup() and tc:IsSetCard(0x294) then
    tc:AddCounter(0x1294,3)
  end
end