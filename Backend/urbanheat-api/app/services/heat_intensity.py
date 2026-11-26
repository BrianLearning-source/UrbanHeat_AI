"""
Provider untuk Surface Heat Intensity Index.

Saat ini menggunakan DummyHeatIntensityProvider.
Ketika model ML selesai, provider ini dapat diganti
tanpa mengubah endpoint API.
"""

from dataclasses import dataclass
from typing import Protocol

@dataclass(frozen=True)
class HeatIntensityValue:
    lst_celsius: float
    model_version: str
    source: str
    is_dummy: bool

class HeatIntensityProvider(Protocol):

    def get_citywide_lst(self) -> HeatIntensityValue:
        ...

class DummyHeatIntensityProvider:
    """
    Nilai sementara untuk menguji integrasi
    Backend FastAPI dengan Flutter.
    """

    VALUE_CELSIUS = 33.4

    model_version = "dummy-heat-intensity-0.1"
    source = "dummy"
    is_dummy = True

    def get_citywide_lst(self) -> HeatIntensityValue:

        return HeatIntensityValue(
            lst_celsius=self.VALUE_CELSIUS,
            model_version=self.model_version,
            source=self.source,
            is_dummy=self.is_dummy,
        )