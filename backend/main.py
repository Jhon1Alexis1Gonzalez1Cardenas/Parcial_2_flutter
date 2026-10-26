from typing import List

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from sqlalchemy.orm import Session

import models
import schemas
from database import Base, engine, get_db

# Crea las tablas si no existen
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="API de Inventario",
    description="Segundo parcial práctico - Electiva Profesional I",
    version="1.0.0",
)

# CORS abierto para desarrollo (Flutter web / pruebas desde otros orígenes)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def _buscar_o_404(db: Session, producto_id: int) -> models.Producto:
    producto = db.get(models.Producto, producto_id)
    if producto is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No existe un producto con id {producto_id}",
        )
    return producto


def _validar_codigo_unico(db: Session, codigo: str, excluir_id: int | None = None) -> None:
    consulta = select(models.Producto).where(models.Producto.codigo == codigo)
    existente = db.execute(consulta).scalars().first()
    if existente is not None and existente.id != excluir_id:
        raise HTTPException(
            status_code=422,
            detail=f"El código '{codigo}' ya está registrado",
        )


@app.get("/api/productos", response_model=List[schemas.ProductoOut])
def listar_productos(db: Session = Depends(get_db)):
    return db.execute(select(models.Producto).order_by(models.Producto.id)).scalars().all()


@app.get("/api/productos/{producto_id}", response_model=schemas.ProductoOut)
def obtener_producto(producto_id: int, db: Session = Depends(get_db)):
    return _buscar_o_404(db, producto_id)


@app.post(
    "/api/productos",
    response_model=schemas.ProductoOut,
    status_code=status.HTTP_201_CREATED,
)
def crear_producto(datos: schemas.ProductoCreate, db: Session = Depends(get_db)):
    _validar_codigo_unico(db, datos.codigo)
    producto = models.Producto(**datos.model_dump())
    db.add(producto)
    db.commit()
    db.refresh(producto)
    return producto


@app.put("/api/productos/{producto_id}", response_model=schemas.ProductoOut)
def actualizar_producto(
    producto_id: int, datos: schemas.ProductoUpdate, db: Session = Depends(get_db)
):
    producto = _buscar_o_404(db, producto_id)
    _validar_codigo_unico(db, datos.codigo, excluir_id=producto_id)
    for campo, valor in datos.model_dump().items():
        setattr(producto, campo, valor)
    db.commit()
    db.refresh(producto)
    return producto


@app.delete("/api/productos/{producto_id}")
def eliminar_producto(producto_id: int, db: Session = Depends(get_db)):
    producto = _buscar_o_404(db, producto_id)
    db.delete(producto)
    db.commit()
    return {"mensaje": "Producto eliminado correctamente", "id": producto_id}
