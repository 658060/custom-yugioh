-- Behe-moth
local s, id = GetID()
function s.initial_effect(c)
	-- xyz summon
	Xyz.AddProcedure(c, nil, 5, 2)
	c:EnableReviveLimit()
	-- search a behe-moth and pop 1
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SEARCH + CATEGORY_DESTROY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetCountLimit(1, { id, 0 })
	e1:SetCondition(s.cond1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- quick effect return banished insect to GY
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(1))
	e1:SetCountLimit(1, { id, 1 })
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
end

s.listed_series = { 0xa056 }

-- search a behe-moth and pop 1
function s.cfilter(c)
	return not (c:IsFaceup() and c:IsRace(RACE_INSECT))
end
function s.filter1(c)
	return c:IsSetCard(0xa056) and c:IsAbleToHand()
end
function s.cond1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.filter1, tp, LOCATION_DECK, 0, 1, nil)
end
function s.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
	Duel.SendtoHand(g, nil, REASON_EFFECT)
	local g2 = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
	if not g2.isExists(s.cfilter, 1, nil) then
		if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
			local g3 = Duel.SelectMatchingCard(tp, function(_)
				return true
			end, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
			if #g3 > 0 then
				Duel.Destroy(g3, REASON_EFFECT)
			end
		end
	end
end

-- quick effect return banished insect to GY
function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsRemoved() and chkc:IsRelateToEffect(e)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(
			aux.FilterBoolFunctionEx(Card.IsRace, RACE_INSECT),
			tp,
			LOCATION_REMOVED,
			0,
			1,
			nil
		)
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOGRAVE)
	local g =
		Duel.SelectTarget(tp, aux.FilterBoolFunctionEx(Card.IsRace, RACE_INSECT), tp, LOCATION_REMOVED, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, tp, LOCATION_REMOVED)
end
function s.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetTargetCards(e)
	Duel.SendtoGrave(tc, REASON_EFFECT)
end
