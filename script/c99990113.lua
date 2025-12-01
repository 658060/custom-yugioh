--Emperor Behe-moth
local s, id = GetID()
function s.initial_effect(c)
	-- if banished, banish insect from GY to return to GY
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	-- e1:SetCountLimit(1, { id, 0 })
	e1:SetCost(s.cost1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
  -- if sent to GY, special then bounce an insect
	local e2 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
  -- quick effect fusion summon
 	local params={
    fusfilter=s.fusfilter3,
    matfilter=Card.IsAbleToRemove,
    extrafil=s.fextra3,
    extraop=Fusion.BanishMaterial,
    extratg=s.extratg3
  }
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e3)
end

s.listed_series = { 0xa056 }

-- if banished, banish insect from GY to return to GY
function s.filter1(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
function s.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.filter1, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local rmc = Duel.SelectMatchingCard(tp, s.filter1, tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
	Duel.Remove(rmc, POS_FACEUP, REASON_COST)
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.SendtoGrave(c, REASON_EFFECT)
end

-- if sent to GY, special summon, then bounce and insect
function s.filter2(c)
	return c:IsRace(RACE_INSECT)
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
  if Duel.SpecialSummon(c, REASON_EFFECT) then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local bc = Duel.SelectMatchingCard(tp, filter2, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil):GetFirst()
    Duel.SendtoHand(bc, nil, REASON_EFFECT)
  end
end

-- quick effect fusion summon
function s.fusfilter3(c)
  return c:IsRace(RACE_INSECT)
end
function s.fextra3()
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg3()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end
