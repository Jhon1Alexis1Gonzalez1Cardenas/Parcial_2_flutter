from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ProductoBase(BaseModel):
    nombre: str = Field(..., max_length=120)
    codigo: str = Field(..., max_length=50)
    descripcion: Optional[str] = Field(default=None, max_length=500)
    precio: float = Field(..., gt=0, description="Precio unitario, mayor que 0")
    cantidad: int = Field(..., ge=0, description="Unidades disponibles, 0 o más")
    categoria: str = Field(..., max_length=80)

    @field_validator("nombre", "codigo", "categoria")
    @classmethod
    def no_vacio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("no puede estar vacío")
        return v

    @field_validator("descripcion")
    @classmethod
    def limpiar_descripcion(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return None
        v = v.strip()
        return v or None


class ProductoCreate(ProductoBase):
    pass


class ProductoUpdate(ProductoBase):
    """PUT reemplaza el producto completo, por eso tiene los mismos campos."""


class ProductoOut(ProductoBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
