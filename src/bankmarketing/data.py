"""Carga e preparação da base Bank Marketing.

Este módulo centraliza o acesso aos dados brutos do Kaggle e à tabela de
modelagem processada (`data/processed/modeling_table.parquet`), garantindo
a remoção de vazamento temporal e a transformação de códigos sentinelas.
"""

from __future__ import annotations

import json
import logging
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

logger = logging.getLogger(__name__)

ROOT = Path(__file__).resolve().parents[2]
RAW_CSV = ROOT / "data" / "kaggle" / "bank-additional-full.csv"
PROCESSED_DIR = ROOT / "data" / "processed"
MODELING_TABLE_PATH = PROCESSED_DIR / "modeling_table.parquet"

# Constantes de metadados da base
DATASET_SOURCE = "henriqueyamahata/bank-marketing"
DATASET_ORIGINAL = "UCI Machine Learning Repository — Bank Marketing"
DATASET_FILE = "bank-additional-full.csv"
DATASET_VERSION = "with social/economic context"
DATASET_LICENSE = "CC BY 4.0"

METADATA_KEY = "bankmarketing.metadata"
METADATA_KEY_BYTES = METADATA_KEY.encode("utf-8")


def _encode_metadata(metadata: dict[str, str]) -> bytes:
    """Serializa metadados para armazenamento no schema do Parquet."""
    return json.dumps(metadata, ensure_ascii=False, sort_keys=True).encode("utf-8")


def _decode_metadata(raw: bytes) -> dict[str, str]:
    """Desserializa metadados do schema do Parquet."""
    return json.loads(raw.decode("utf-8"))


def build_modeling_table(raw_csv: Path | str = RAW_CSV) -> pd.DataFrame:
    """Constrói a tabela de modelagem a partir do CSV bruto.

    Transformações aplicadas:
        - Remove ``duration`` (leakage temporal).
        - Cria a flag ``foi_contatado_antes`` a partir do sentinela ``pdays=999``.
        - Mantém os valores ``"unknown"`` como categoria explícita.

    Args:
        raw_csv: caminho para ``bank-additional-full.csv``.

    Returns:
        DataFrame pronto para modelagem.
    """
    raw_csv = Path(raw_csv)
    if not raw_csv.exists():
        raise FileNotFoundError(f"Base bruta não encontrada: {raw_csv}")

    df = pd.read_csv(raw_csv, sep=";")

    # 1. Leakage temporal: duration só é conhecido após a ligação.
    if "duration" in df.columns:
        df = df.drop(columns=["duration"])

    # 2. Sentinela pdays=999 significa "nunca contatado antes".
    df["foi_contatado_antes"] = df["pdays"] != 999

    logger.info(
        "Modeling table construída: %d linhas x %d colunas (sem 'duration')",
        len(df),
        len(df.columns),
    )
    return df


def save_modeling_table(
    df: pd.DataFrame | None = None,
    path: Path | str = MODELING_TABLE_PATH,
    metadata: dict[str, str] | None = None,
) -> Path:
    """Salva a tabela de modelagem em formato Parquet com metadados no schema.

    Args:
        df: DataFrame a salvar. Se ``None``, reconstrói a partir da base bruta.
        path: caminho de destino.
        metadata: metadados de proveniência. Se ``None``, usa ``get_dataset_metadata()``.

    Returns:
        Caminho do arquivo salvo.
    """
    if df is None:
        df = build_modeling_table()
    if metadata is None:
        metadata = get_dataset_metadata()

    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)

    table = pa.Table.from_pandas(df, preserve_index=False)
    schema_metadata: dict[bytes, bytes] = {METADATA_KEY_BYTES: _encode_metadata(metadata)}
    if table.schema.metadata:
        schema_metadata.update(table.schema.metadata)
    table = table.replace_schema_metadata(schema_metadata)

    pq.write_table(table, path)
    logger.info("Modeling table salva em %s com metadados", path)
    return path


def load_modeling_table(path: Path | str = MODELING_TABLE_PATH) -> pd.DataFrame:
    """Carrega a tabela de modelagem processada e seus metadados.

    Args:
        path: caminho para o arquivo Parquet.

    Returns:
        DataFrame de modelagem com os metadados em ``df.attrs["bankmarketing.metadata"]``.
    """
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(
            f"Tabela de modelagem não encontrada em {path}. "
            "Execute bankmarketing.data.save_modeling_table() primeiro."
        )

    table = pq.read_table(path)
    df = table.to_pandas()

    metadata: dict[str, str] | None = None
    raw_metadata = table.schema.metadata.get(METADATA_KEY_BYTES)
    if raw_metadata is not None:
        metadata = _decode_metadata(raw_metadata)
        df.attrs["bankmarketing.metadata"] = metadata

    if metadata is not None:
        logger.info(
            "Modeling table carregada de %s (%d linhas x %d colunas) — "
            "source=%s, version=%s, license=%s, leakage_removed=%s",
            path,
            len(df),
            len(df.columns),
            metadata.get("source"),
            metadata.get("version"),
            metadata.get("license"),
            metadata.get("leakage_removed"),
        )
    else:
        logger.warning("Modeling table carregada sem metadados de proveniência: %s", path)
    return df


def get_dataset_metadata() -> dict[str, str]:
    """Retorna metadados rastreáveis da fonte de dados."""
    return {
        "source": DATASET_SOURCE,
        "original": DATASET_ORIGINAL,
        "file": DATASET_FILE,
        "version": DATASET_VERSION,
        "license": DATASET_LICENSE,
        "n_rows": "41188",
        "n_features_raw": "20",
        "target": "y",
        "leakage_removed": "duration",
    }


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    save_modeling_table()
