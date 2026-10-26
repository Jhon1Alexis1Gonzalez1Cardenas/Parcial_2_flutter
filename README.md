# Inventario Rojo — API REST + Flutter

Segundo parcial práctico de **Electiva Profesional I — Desarrollo de Aplicaciones Móviles** (UCEVA, Ingeniería de Sistemas).

**Estudiante:** Jhon Alexis Gonzalez Cardenas

Solución para la gestión de inventario de productos de un establecimiento comercial. Está compuesta por dos proyectos:

| Carpeta     | Descripción                                                                  |
|-------------|------------------------------------------------------------------------------|
| `backend/`  | API REST en Python (FastAPI) con base de datos SQLite persistente.           |
| `frontend/` | Aplicación móvil en Flutter que consume la API mediante el paquete **Dio**.  |

---

## Tecnologías

**Backend**
- Python 3
- FastAPI (framework de la API y documentación Swagger automática)
- SQLAlchemy 2 (ORM)
- SQLite (base de datos en archivo, persistencia real)
- Pydantic (validación de datos)
- Uvicorn (servidor)

**Frontend**
- Flutter / Dart
- `dio` — peticiones HTTP
- `go_router` — navegación
- `flutter_dotenv` — configuración de la URL base de la API

---

## Base de datos

Motor: **SQLite** (archivo `backend/inventario.db`, se crea automáticamente al iniciar la API).

Tabla `productos`:

| Campo         | Tipo    | Descripción                                    |
|---------------|---------|------------------------------------------------|
| `id`          | Entero  | Identificador único y autogenerado (PK).       |
| `nombre`      | Texto   | Nombre del producto (obligatorio).             |
| `codigo`      | Texto   | Código único del producto (obligatorio, único).|
| `descripcion` | Texto   | Descripción adicional (opcional).              |
| `precio`      | Decimal | Precio unitario (mayor que 0).                 |
| `cantidad`    | Entero  | Unidades disponibles (0 o más).                |
| `categoria`   | Texto   | Categoría del producto (obligatoria).          |

El script `seed.py` registra **10 productos de prueba**.

---

## Endpoints de la API

Base: `http://localhost:8000` — Documentación interactiva (Swagger): `http://localhost:8000/docs`

| Método | Endpoint               | Funcionalidad                  | Respuestas              |
|--------|------------------------|--------------------------------|-------------------------|
| GET    | `/api/productos`       | Listar todos los productos     | 200                     |
| GET    | `/api/productos/{id}`  | Consultar el detalle           | 200, 404                |
| POST   | `/api/productos`       | Registrar un nuevo producto    | 201, 422                |
| PUT    | `/api/productos/{id}`  | Actualizar un producto         | 200, 404, 422           |
| DELETE | `/api/productos/{id}`  | Eliminar un producto           | 200, 404                |

**Validaciones:** campos obligatorios no vacíos, `codigo` único (también al editar), `precio > 0` y `cantidad >= 0`. Los errores de validación devuelven **422** y los productos inexistentes **404**.

### Ejemplos de peticiones y respuestas

**GET `/api/productos/1`** → `200 OK`
```json
{
  "nombre": "Arroz Diana 1kg",
  "codigo": "ARR-001",
  "descripcion": "Arroz blanco premium",
  "precio": 4200.0,
  "cantidad": 80,
  "categoria": "Granos",
  "id": 1
}
```

**POST `/api/productos`** → `201 Created`

Petición:
```json
{
  "nombre": "Chocolatina Jet",
  "codigo": "CHO-001",
  "descripcion": "Chocolatina de leche",
  "precio": 1500,
  "cantidad": 50,
  "categoria": "Dulces"
}
```
Respuesta:
```json
{
  "nombre": "Chocolatina Jet",
  "codigo": "CHO-001",
  "descripcion": "Chocolatina de leche",
  "precio": 1500.0,
  "cantidad": 50,
  "categoria": "Dulces",
  "id": 11
}
```

**PUT `/api/productos/11`** → `200 OK` (se envía el producto completo)
```json
{
  "nombre": "Chocolatina Jet",
  "codigo": "CHO-001",
  "descripcion": "Chocolatina de leche",
  "precio": 1800,
  "cantidad": 40,
  "categoria": "Dulces"
}
```

**DELETE `/api/productos/11`** → `200 OK`
```json
{
  "mensaje": "Producto eliminado correctamente",
  "id": 11
}
```

**Errores**

`GET /api/productos/9999` → `404 Not Found`
```json
{ "detail": "No existe un producto con id 9999" }
```

`POST` con un código repetido → `422 Unprocessable Content`
```json
{ "detail": "El código 'CHO-001' ya está registrado" }
```

`POST` con `"precio": 0` → `422 Unprocessable Content`
```json
{
  "detail": [
    {
      "type": "greater_than",
      "loc": ["body", "precio"],
      "msg": "Input should be greater than 0",
      "input": 0
    }
  ]
}
```

---

## Instalación y ejecución

### Requisitos
- Python 3.10 o superior
- Flutter SDK (con un emulador Android o un celular físico)

### 1. Backend (API)

En PowerShell (Windows), desde la raíz del repositorio:

```powershell
cd backend
py -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python seed.py                      # carga los 10 productos de prueba
python -m uvicorn main:app --host 0.0.0.0 --reload
```

> Si PowerShell bloquea la activación del entorno, ejecuta antes:
> `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

En Linux / macOS: `python3 -m venv venv && source venv/bin/activate`, y el resto igual.

La API queda en `http://localhost:8000` y Swagger en `http://localhost:8000/docs`.
Para reiniciar los datos de prueba, borra `backend/inventario.db` y vuelve a ejecutar `python seed.py`.

### 2. Frontend (Flutter)

```powershell
cd frontend
flutter pub get
flutter run
```

La URL de la API se configura en el archivo `frontend/.env` (clave `API_BASE_URL`, cargada con `flutter_dotenv`):

| Dónde se ejecuta la app | `API_BASE_URL`                          |
|-------------------------|------------------------------------------|
| Emulador Android        | `http://10.0.2.2:8000/api`               |
| Celular físico          | `http://IP_DE_TU_PC:8000/api`            |
| Windows / Chrome        | `http://localhost:8000/api`              |

Para el celular físico, el teléfono y el PC deben estar en la misma red Wi-Fi y el firewall debe permitir el puerto 8000.
El archivo `.env` solo contiene la URL base (no hay contraseñas ni secretos); `.env.example` sirve de referencia.

El proyecto permite tráfico HTTP en Android (`usesCleartextTraffic`) únicamente para el desarrollo local contra la API.

---

## Funcionalidades de la app

- **Dashboard:** nombre e identidad visual de la app, tarjetas con el total de productos, el total de unidades y el valor económico del inventario (suma de `precio × cantidad`), y acceso a la gestión de productos. Los indicadores se calculan con datos reales de la API y se actualizan al modificar productos.
- **Listar:** nombre, precio y cantidad de cada producto.
- **Consultar:** detalle completo de un producto.
- **Registrar:** formulario con validación; el código se genera automáticamente (editable) y la categoría se elige de las existentes o se agrega una nueva.
- **Editar:** formulario precargado con los datos del producto (PUT).
- **Eliminar:** con confirmación del usuario (DELETE).
- **Estados de interfaz:** carga, error con botón de reintento y ausencia de registros; mensajes claros al completar o fallar una operación.
- **Navegación:** `go_router` con menú inferior (Dashboard, Productos, Nuevo).
- **Tema:** interfaz en tonos rojos.

### Estructura del proyecto Flutter

```
frontend/lib/
├── config/      configuración (URL desde .env) y formato de números
├── models/      Producto y ResumenInventario
├── services/    DioClient, ProductoService (única capa que hace peticiones HTTP) y manejo de errores
├── routes/      rutas de go_router
├── themes/      tema en tonos rojos
├── views/       pantallas (dashboard, lista, detalle, formulario) y menú inferior
├── widgets/     componentes reutilizables (tarjetas, estados de carga/error/vacío)
└── main.dart
```

Las vistas no realizan peticiones HTTP directamente: usan `ProductoService`, que traduce los errores de Dio (sin conexión, tiempo agotado, 404, 422, 5xx) a mensajes claros para el usuario.

---

## Despliegue

Despliegue opcional **no realizado**: la API y la app se ejecutan de manera local.

<!-- Si se despliega, agregar aquí la URL pública HTTPS de la API. -->
