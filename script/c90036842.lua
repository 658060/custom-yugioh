--Inzektor Hive
local s, id = GetID()
function s.initial_effect(c)
	--activate
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--equip from deck
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1, { id, 0 })
	e2:SetRange(LOCATION_FZONE)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetTarget(s.target)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--protect from destruction & banishment
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1, { id, 1 })
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(s.bcost)
	e3:SetOperation(s.bactivate)
	c:RegisterEffect(e3)
	--face-up inzektor monster effects and activations cannot be negated
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(EFFECT_TYPE_FIELD)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetValue(s.cannotfilter)
	c:RegisterEffect(e4)
	local e4a = Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4a:SetRange(LOCATION_FZONE)
	e4a:SetValue(s.cannotfilter)
	c:RegisterEffect(e4a)
end
s.listed_series = { SET_INZEKTOR }

-- EFFECT 1
function s.filter(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and not c:IsForbidden()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsControler(tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsSetCard(SET_INZEKTOR)
			and chkc:IsFaceup()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK | LOCATION_HAND | LOCATION_GRAVE, 0, 1, nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	Duel.SelectTarget(tp, s.filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK | LOCATION_HAND | LOCATION_GRAVE)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local ec =
		Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK | LOCATION_HAND | LOCATION_GRAVE, 0, 1, 1, nil, tp)
			:GetFirst()
	if ec then
		s.equipop(tc, e, tp, ec)
	end
end

function s.equipop(c, e, tp, ec)
	if not c:EquipByEffectAndLimitRegister(e, tp, ec, nil, true) then
		return
	end
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	e1:SetReset(RESET_EVENT | RESETS_STANDARD)
	ec:RegisterEffect(e1)
end

function s.eqlimit(e, c)
	return c:GetControler() == e:GetHandlerPlayer()
end

-- EFFECT 2
function s.bfilter(c, tp)
	return c:IsControler(tp) and c:IsSetCard(SET_INZEKTOR) and c:IsFaceup()
end

function s.bcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.bfilter, tp, LOCATION_ONFIELD, 0, 1, c, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local gyc = Duel.SelectMatchingCard(tp, s.bfilter, tp, LOCATION_ONFIELD, 0, 1, 1, c, tp)
	Duel.SendtoGrave(gyc, REASON_EFFECT)
end

function s.bactivate(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	-- protect from destruction
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_ONFIELD, 0)
	e1:SetTarget(function(e, c)
		return c:IsSetCard(SET_INZEKTOR) and c:IsFaceup() and c:IsMonster()
	end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- protect from banishment
	local e2 = e1:Clone()
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	c:RegisterEffect(e2)
end

function s.removelimit(e, tp, re, r, rp)
	return rp == 1 - e:GetHandlerPlayer() and r == REASON_EFFECT
end

function s.cannotfilter(e, ct)
	local p = e:GetHandler():GetControler()
	local te, tp, loc =
		Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
	return p == tp
		and te:IsMonsterEffect()
		and te:GetHandler():IsSetCard(SET_INZEKTOR)
		and (loc & LOCATION_ONFIELD) ~= 0
end
