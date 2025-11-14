import pytest
from django.urls import reverse
from django.test import Client

@pytest.mark.django_db
def test_home():
    client = Client()
    response = client.get("/")
    assert response.status_code == 200
    assert b"Hello from Jenkins Django Demo!" in response.content
