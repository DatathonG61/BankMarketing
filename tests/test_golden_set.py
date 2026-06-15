"""Testes do golden set de avaliacao (E4).

Valida apenas o arquivo ``data/golden_set/evaluation_cases.jsonl``. Nao
depende de ``policies.py``, ``contracts.py``, ``data.py`` ou ``app.py``
(ainda nao implementados pelos demais responsaveis). Quando o vocabulario
compartilhado existir em ``contracts.py``, o catalogo de ofertas abaixo deve
passar a ser importado de la em vez de redefinido aqui (ver pendencias em
``docs/golden-set-criteria.md``).
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GOLDEN_SET_PATH = ROOT / "data" / "golden_set" / "evaluation_cases.jsonl"

REQUIRED_FIELDS = {
    "case_id",
    "category",
    "description",
    "context",
    "expected_offers",
    "forbidden_offers",
    "rationale",
    "source",
}

VALID_CATEGORIES = {"tipico", "borda", "adversarial"}
VALID_SOURCES = {"documentado", "hipotese"}

# Catalogo de ofertas conforme ref_docs/PLANO.md (offer_catalog definitivo
# de E2 ainda nao publicado por Gabriel).
VALID_OFFERS = {"sem_oferta", "cartao_credito", "investimento", "renegociacao"}


def _load_cases() -> list[dict]:
    with GOLDEN_SET_PATH.open(encoding="utf-8") as f:
        return [json.loads(line) for line in f if line.strip()]


def test_golden_set_file_exists():
    assert GOLDEN_SET_PATH.exists()


def test_golden_set_has_at_least_20_cases():
    cases = _load_cases()
    assert len(cases) >= 20


def test_golden_set_case_ids_are_unique():
    cases = _load_cases()
    case_ids = [case["case_id"] for case in cases]
    assert len(case_ids) == len(set(case_ids))


def test_golden_set_cases_have_required_fields():
    cases = _load_cases()
    for case in cases:
        assert set(case.keys()) == REQUIRED_FIELDS, case["case_id"]


def test_golden_set_categories_are_valid():
    cases = _load_cases()
    for case in cases:
        assert case["category"] in VALID_CATEGORIES, case["case_id"]


def test_golden_set_sources_are_valid():
    cases = _load_cases()
    for case in cases:
        assert case["source"] in VALID_SOURCES, case["case_id"]


def test_golden_set_expected_offers_non_empty_and_valid():
    cases = _load_cases()
    for case in cases:
        expected = case["expected_offers"]
        assert len(expected) > 0, case["case_id"]
        assert set(expected) <= VALID_OFFERS, case["case_id"]


def test_golden_set_forbidden_offers_are_valid():
    cases = _load_cases()
    for case in cases:
        forbidden = case["forbidden_offers"]
        assert set(forbidden) <= VALID_OFFERS, case["case_id"]


def test_golden_set_expected_and_forbidden_offers_do_not_overlap():
    cases = _load_cases()
    for case in cases:
        overlap = set(case["expected_offers"]) & set(case["forbidden_offers"])
        assert not overlap, case["case_id"]


def test_golden_set_has_at_least_one_documented_case():
    cases = _load_cases()
    documented = [case for case in cases if case["source"] == "documentado"]
    assert len(documented) >= 1


def test_golden_set_categories_cover_all_types():
    cases = _load_cases()
    categories = {case["category"] for case in cases}
    assert VALID_CATEGORIES <= categories
