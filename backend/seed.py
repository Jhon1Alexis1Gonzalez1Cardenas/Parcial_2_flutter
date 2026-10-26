"""Carga 10 productos de prueba. Solo inserta si la tabla está vacía.

Uso:  python seed.py
"""
from sqlalchemy import func, select

import models as models
from database import Base, SessionLocal, engine

PRODUCTOS = [
    ("Arroz Diana 1kg", "ARR-001", "Arroz blanco premium", 4200, 80, "Granos"),
    ("Aceite Gourmet 1L", "ACE-001", "Aceite vegetal", 12500, 45, "Despensa"),
    ("Leche Alquería 1L", "LEC-001", "Leche entera larga vida", 4800, 120, "Lácteos"),
    ("Huevos AA x30", "HUE-001", "Cubeta de huevos", 19500, 25, "Lácteos"),
    ("Café Sello Rojo 500g", "CAF-001", "Café molido tostado", 17800, 60, "Bebidas"),
    ("Gaseosa Colombiana 1.5L", "GAS-001", "Bebida gaseosa", 5600, 90, "Bebidas"),
    ("Jabón Rey 3 und", "JAB-001", "Jabón de barra para ropa", 6900, 70, "Aseo"),
    ("Papel Higiénico x12", "PAP-001", "Papel higiénico doble hoja", 21900, 35, "Aseo"),
    ("Pan Tajado Bimbo", "PAN-001", "Pan blanco tajado", 6500, 40, "Panadería"),
    ("Atún Van Camps 160g", "ATU-001", None, 7400, 55, "Enlatados"),
]


def main() -> None:
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        total = db.execute(select(func.count(models.Producto.id))).scalar_one()
        if total > 0:
            print(f"La tabla ya tiene {total} productos. No se insertó nada.")
            return
        for nombre, codigo, descripcion, precio, cantidad, categoria in PRODUCTOS:
            db.add(
                models.Producto(
                    nombre=nombre,
                    codigo=codigo,
                    descripcion=descripcion,
                    precio=precio,
                    cantidad=cantidad,
                    categoria=categoria,
                )
            )
        db.commit()
        print(f"Se insertaron {len(PRODUCTOS)} productos de prueba.")


if __name__ == "__main__":
    main()
