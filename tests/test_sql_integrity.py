from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
QUERY_DIR = PROJECT_ROOT / "pipeline_dimensional_data" / "queries"


def read_query(name):
    return (QUERY_DIR / name).read_text(encoding="utf-8").lower()


def test_update_fact_does_not_insert_unknown_surrogate_key_values():
    update_fact = read_query("update_fact.sql")

    assert "coalesce(dc.customer_sk" not in update_fact
    assert "coalesce(de.employee_sk" not in update_fact
    assert "coalesce(dp.product_sk" not in update_fact
    assert "coalesce(dcat.category_sk" not in update_fact
    assert "coalesce(dsup.supplier_sk" not in update_fact
    assert "coalesce(dsh.shipper_sk" not in update_fact
    assert "coalesce(dt.territory_sk" not in update_fact
    assert "coalesce(dr.region_sk" not in update_fact


def test_update_fact_filters_out_rows_with_missing_required_dimension_keys():
    update_fact = read_query("update_fact.sql")

    required_filters = [
        "dc.customer_sk  is not null",
        "de.employee_sk  is not null",
        "dp.product_sk   is not null",
        "dcat.category_sk is not null",
        "dsup.supplier_sk is not null",
        "dsh.shipper_sk  is not null",
        "dt.territory_sk is not null",
        "dr.region_sk    is not null",
    ]
    for required_filter in required_filters:
        assert required_filter in update_fact


def test_update_fact_error_checks_all_fact_dimension_lookups():
    update_fact_error = read_query("update_fact_error.sql")

    expected_missing_messages = [
        "missing customerid=",
        "missing employeeid=",
        "missing productid=",
        "missing categoryid=",
        "missing supplierid=",
        "missing shipperid=",
        "missing territoryid=",
        "missing regionid=",
    ]
    for message in expected_missing_messages:
        assert message in update_fact_error

    expected_null_checks = [
        "dc.customer_sk   is null",
        "de.employee_sk   is null",
        "dp.product_sk    is null",
        "dcat.category_sk is null",
        "dsup.supplier_sk is null",
        "dsh.shipper_sk   is null",
        "dt.territory_sk  is null",
        "dr.region_sk     is null",
    ]
    for null_check in expected_null_checks:
        assert null_check in update_fact_error