--Timerx Fusion
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Fusion Summon
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=s.mfilter,extrafil=s.fextra,stage2=s.stage2})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
--(1)Fusion Summon
function s.mfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToGrave())
		or (c:IsOriginalType(TYPE_MONSTER) and c:IsLocation(LOCATION_DECK) )
end
function s.checkmat(tp,sg,fc)
	return (fc:IsSetCard(0x305) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK)) and sg:IsExists(Card.IsSetCard,1,nil,0x305)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil),s.checkmat
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0x305)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--(2.2)Register The Hint
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end