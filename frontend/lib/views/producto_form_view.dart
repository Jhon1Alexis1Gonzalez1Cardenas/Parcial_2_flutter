import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estado_vista.dart';

/// Formulario para registrar un producto nuevo o editar uno existente.
/// Si [productoId] es null, registra (POST); si no, precarga y actualiza (PUT).
///
/// - El código se genera automáticamente (se puede regenerar o escribir a mano).
/// - La categoría se elige de las que ya existen en el inventario, o se crea
///   una nueva con la opción "Nueva categoría…".
class ProductoFormView extends StatefulWidget {
  const ProductoFormView({super.key, this.productoId});

  final int? productoId;

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  static const _opcionNuevaCategoria = '__nueva_categoria__';
  static const _caracteresCodigo = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final _service = ProductoService();
  final _formKey = GlobalKey<FormState>();
  final _azar = Random.secure();

  final _nombre = TextEditingController();
  final _codigo = TextEditingController();
  final _categoriaNueva = TextEditingController();
  final _precio = TextEditingController();
  final _cantidad = TextEditingController();
  final _descripcion = TextEditingController();

  /// Categorías que ya existen en los productos registrados.
  List<String> _categorias = [];

  /// Códigos ya usados por otros productos (para no repetirlos).
  Set<String> _codigosExistentes = {};

  String? _categoriaSeleccionada;

  bool get _esEdicion => widget.productoId != null;

  /// Se muestra el campo de texto de categoría cuando no hay categorías
  /// registradas todavía o cuando se eligió "Nueva categoría…".
  bool get _crearCategoria =>
      _categorias.isEmpty || _categoriaSeleccionada == _opcionNuevaCategoria;

  bool _cargando = true;
  bool _guardando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _codigo,
      _categoriaNueva,
      _precio,
      _cantidad,
      _descripcion,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  /// Carga las categorías y códigos existentes (GET /productos) y, si es
  /// edición, precarga el producto (GET /productos/{id}).
  Future<void> _cargarDatos() async {
    try {
      final productos = await _service.listar();

      final categorias = productos.map((p) => p.categoria).toSet().toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      final codigos = productos
          .where((p) => p.id != widget.productoId)
          .map((p) => p.codigo)
          .toSet();

      Producto? editado;
      if (_esEdicion) {
        editado = await _service.obtener(widget.productoId!);
      }
      if (!mounted) return;

      _categorias = categorias;
      _codigosExistentes = codigos;

      if (editado != null) {
        _nombre.text = editado.nombre;
        _codigo.text = editado.codigo;
        _categoriaSeleccionada = editado.categoria;
        _precio.text = editado.precio == editado.precio.roundToDouble()
            ? editado.precio.toStringAsFixed(0)
            : editado.precio.toString();
        _cantidad.text = editado.cantidad.toString();
        _descripcion.text = editado.descripcion ?? '';
      } else {
        _codigo.text = _generarCodigoUnico();
      }

      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorCarga = mensajeDeError(e);
      });
    }
  }

  void _reintentarCarga() {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    _cargarDatos();
  }

  // ------------------------- Código aleatorio -------------------------------

  /// Genera un código tipo PRD-K7M2QX que no esté en uso.
  String _generarCodigoUnico() {
    String codigo;
    do {
      final sufijo = List.generate(
        6,
        (_) => _caracteresCodigo[_azar.nextInt(_caracteresCodigo.length)],
      ).join();
      codigo = 'PRD-$sufijo';
    } while (_codigosExistentes.contains(codigo));
    return codigo;
  }

  void _generarCodigo() {
    _codigo.text = _generarCodigoUnico();
  }

  // --------------------------- Validaciones ---------------------------------

  String? _validarObligatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  String? _validarCodigo(String? valor) {
    final codigo = (valor ?? '').trim();
    if (codigo.isEmpty) return 'Campo obligatorio';
    if (_codigosExistentes.contains(codigo))
      return 'Este código ya está en uso';
    return null;
  }

  String? _validarPrecio(String? valor) {
    final numero = double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
    if (numero == null || numero <= 0) return 'Ingresa un precio mayor a 0';
    return null;
  }

  String? _validarCantidad(String? valor) {
    final numero = int.tryParse((valor ?? '').trim());
    if (numero == null || numero < 0)
      return 'Ingresa un número entero (0 o más)';
    return null;
  }

  // ------------------------------ Guardar -----------------------------------

  /// Categoría que se enviará a la API. Si la nueva ya existe (sin importar
  /// mayúsculas), se reutiliza la existente para no duplicarla.
  String _categoriaFinal() {
    if (!_crearCategoria) return _categoriaSeleccionada!;
    final nueva = _categoriaNueva.text.trim();
    for (final existente in _categorias) {
      if (existente.toLowerCase() == nueva.toLowerCase()) return existente;
    }
    return nueva;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final descripcion = _descripcion.text.trim();
    final producto = Producto(
      id: widget.productoId,
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim(),
      categoria: _categoriaFinal(),
      precio: double.parse(_precio.text.trim().replaceAll(',', '.')),
      cantidad: int.parse(_cantidad.text.trim()),
      descripcion: descripcion.isEmpty ? null : descripcion,
    );

    try {
      if (_esEdicion) {
        await _service.actualizar(producto);
      } else {
        await _service.crear(producto);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Producto actualizado correctamente'
                : 'Producto registrado correctamente',
          ),
        ),
      );
      if (_esEdicion) {
        context.pop(true); // vuelve al detalle indicando que hubo cambios
      } else {
        context.go('/productos');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeDeError(e)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // -------------------------------- UI --------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) return const EstadoCargando();
    if (_errorCarga != null) {
      return EstadoError(mensaje: _errorCarga!, onReintentar: _reintentarCarga);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.label_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: _validarObligatorio,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _codigo,
            decoration: InputDecoration(
              labelText: 'Código (único)',
              prefixIcon: const Icon(Icons.qr_code_2),
              helperText: 'Se genera solo; puedes cambiarlo o regenerarlo',
              suffixIcon: IconButton(
                tooltip: 'Generar código aleatorio',
                icon: const Icon(Icons.autorenew),
                onPressed: _generarCodigo,
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: _validarCodigo,
          ),
          const SizedBox(height: 16),
          if (_categorias.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              items: [
                for (final categoria in _categorias)
                  DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  ),
                const DropdownMenuItem<String>(
                  value: _opcionNuevaCategoria,
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Nueva categoría…'),
                    ],
                  ),
                ),
              ],
              onChanged: (valor) =>
                  setState(() => _categoriaSeleccionada = valor),
              validator: (valor) =>
                  valor == null ? 'Selecciona una categoría' : null,
            ),
            const SizedBox(height: 16),
          ],
          if (_crearCategoria) ...[
            TextFormField(
              controller: _categoriaNueva,
              decoration: InputDecoration(
                labelText: _categorias.isEmpty
                    ? 'Categoría'
                    : 'Nombre de la nueva categoría',
                prefixIcon: const Icon(Icons.add_circle_outline),
                helperText: 'Se guardará y quedará disponible para seleccionar',
              ),
              textInputAction: TextInputAction.next,
              validator: _validarObligatorio,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _precio,
            decoration: const InputDecoration(
              labelText: 'Precio unitario',
              prefixIcon: Icon(Icons.attach_money),
              helperText: 'Usa punto para decimales (ej: 1500.50)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            textInputAction: TextInputAction.next,
            validator: _validarPrecio,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cantidad,
            decoration: const InputDecoration(
              labelText: 'Cantidad disponible',
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            validator: _validarCantidad,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descripcion,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _esEdicion ? 'Guardar cambios' : 'Registrar producto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
