--Emperor Behe-moth
local s, id = GetID()
function s.initial_effect(c)
	-- if banished, banish insect from GY to return to GY
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, { id, 0 })
	e1:SetCost(s.cost1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- if sent to GY, return banished insects to hand to special summon
	local e2 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, {id, 1})
  e2:SetCondition(s.cond2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
  -- quick effect xyz summon
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
  e3:SetTarget(s.tg3)
  e3:SetOperation(s.op3)
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

-- if sent to GY, return banished insects to hand to special summon
function s.cond2(e, tp, eg, ep, ev, re, r, rp)
  return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end
function s.filter2(c)
	return c:IsRace(RACE_INSECT)
end
function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local c = e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED) and c:IsAbleToHand()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(s.filter2, tp, LOCATION_REMOVED, 0, 1, c)
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local bc = Duel.SelectTarget(tp, s.filter2, tp, LOCATION_REMOVED, 0, 1, 2, c)
	if #bc > 0 then
		Duel.SetOperationInfo(0, CATEGORY_TOHAND, bc, 1, 0, 0)
	end
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local bc = Duel.GetTargetCards(e)
	if Duel.SendtoHand(bc, nil, REASON_EFFECT) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end

-- quick effect xyz summon
function s.filter3(c)
  return c:IsXyzSummonable() and c:IsRace(RACE_INSECT)
end
function s.tg3(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter3, tp, LOCATION_EXTRA, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function s.op3(e, tp, eg, ep, ev, re, r, rp)
  local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,sg:GetFirst())
	end
end
