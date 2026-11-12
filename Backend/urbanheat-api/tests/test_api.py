from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)
VALID = {"latitude": -7.9797, "longitude": 112.6304, "date": "2026-11-12"}


def test_health():
    r = client.get("/health")
    assert r.status_code == 200 and r.json()["status"] == "ok"


def test_predict_ok_and_shape():
    r = client.post("/v1/predict", json=VALID)
    assert r.status_code == 200
    body = r.json()
    assert body["risk_level"] in {"LOW", "MODERATE", "ELEVATED", "HIGH"}
    assert sum(f["percentage"] for f in body["factors"]) == 100
    # base + kontribusi = prediksi (sifat SHAP)
    total = body["base_value_celsius"] + sum(f["contribution_celsius"] for f in body["factors"])
    assert abs(total - body["predicted_lst_celsius"]) < 0.05


def test_predict_is_consistent():
    a = client.post("/v1/predict", json=VALID).json()
    b = client.post("/v1/predict", json=VALID).json()
    assert a["predicted_lst_celsius"] == b["predicted_lst_celsius"]


def test_out_of_study_area():
    r = client.post("/v1/predict", json={**VALID, "latitude": -6.2, "longitude": 106.8})
    assert r.status_code == 422 and r.json()["error"]["code"] == "OUT_OF_STUDY_AREA"


def test_invalid_input():
    r = client.post("/v1/predict", json={**VALID, "latitude": "abc"})
    assert r.status_code == 422 and r.json()["error"]["code"] == "INVALID_INPUT"


def test_missing_field():
    r = client.post("/v1/predict", json={"latitude": -7.98})
    assert r.status_code == 422


def test_hotspots_and_area():
    assert len(client.get("/v1/hotspots").json()["hotspots"]) == 3
    assert client.get("/v1/areas/MC-204").status_code == 200
    r = client.get("/v1/areas/XX-000")
    assert r.status_code == 404 and r.json()["error"]["code"] == "AREA_NOT_FOUND"


MITIGATION_FIELDS = {"category", "title", "target", "impact", "description", "badge", "details",
                     "category_code", "related_feature"}


def test_mitigation_matches_flutter_entity():
    # Cari beberapa lokasi sampai ada saran mitigasi, lalu cek field-nya lengkap.
    seen = 0
    for i in range(30):
        body = client.post("/v1/predict", json={**VALID, "latitude": -7.95 - i * 0.002}).json()
        for m in body["mitigations"]:
            assert set(m) == MITIGATION_FIELDS
            seen += 1
    assert seen > 0


def test_dimensions_present():
    body = client.post("/v1/predict", json=VALID).json()
    assert len(body["dimensions"]) == 4
    assert set(body["dimensions"][0]) == {"title", "subtitle", "badge", "description"}
    assert client.get("/v1/areas/MC-204").json()["dimensions"]
