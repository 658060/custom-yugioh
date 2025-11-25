--Inzektor Arma-Weevil
s, id = GetID()
function s.initial_effect(c)
	-- xyz summon
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_INSECT), 4, 2, nil, 0, 5)
	c:EnableReviveLimit()

	-- negate and destroy
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(Cost.DetachFromSelf(1))
end

s.listed_series = { SET_INZEKTOR }

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
