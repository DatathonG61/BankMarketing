from bankmarketing.data import (
    build_modeling_table,
    get_dataset_metadata,
    load_modeling_table,
    save_modeling_table,
)


def test_build_modeling_table_removes_duration():
    df = build_modeling_table()
    assert "duration" not in df.columns, "duration (leakage temporal) deve ser removida"


def test_build_modeling_table_creates_contacted_flag():
    df = build_modeling_table()
    assert "foi_contatado_antes" in df.columns
    assert df["foi_contatado_antes"].dtype == bool


def test_build_modeling_table_shape():
    df = build_modeling_table()
    assert len(df) == 41188
    # 20 features originais - duration (1) + foi_contatado_antes (1) = 20 + target
    assert len(df.columns) == 21


def test_save_and_load_modeling_table(tmp_path):
    path = tmp_path / "modeling_table.parquet"
    save_modeling_table(path=path)
    df = load_modeling_table(path=path)
    assert "duration" not in df.columns
    assert len(df) == 41188


def test_modeling_table_parquet_contains_metadata(tmp_path):
    path = tmp_path / "modeling_table.parquet"
    expected_meta = get_dataset_metadata()
    save_modeling_table(path=path, metadata=expected_meta)
    df = load_modeling_table(path=path)

    assert "bankmarketing.metadata" in df.attrs
    assert df.attrs["bankmarketing.metadata"]["leakage_removed"] == "duration"
    assert df.attrs["bankmarketing.metadata"]["source"] == expected_meta["source"]


def test_dataset_metadata():
    meta = get_dataset_metadata()
    assert meta["leakage_removed"] == "duration"
    assert meta["target"] == "y"
