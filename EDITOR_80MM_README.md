# Editor de Texto para Impresora 80mm

## Descripción
Editor de texto completo diseñado específicamente para impresoras térmicas de 80mm. Permite crear documentos formateados con vista previa en tiempo real y capacidad de impresión directa.

## Características

### 🎨 Formato de Texto
- **Negrita**: Resalta texto importante
- **Tamaño de fuente**: Pequeño (10pt), Normal (12pt), Grande (16pt)
- **Alineación**: Izquierda, Centro, Derecha
- **Separadores**: Líneas simples (-) y dobles (=)

### 📝 Editor
- Campo de texto multilínea
- Controles de formato intuitivos
- Agregar elementos con Enter o botón
- Lista de elementos con vista previa

### 🔄 Gestión de Elementos
- **Editar**: Botón de editar (lápiz) para modificar elementos existentes
- **Reordenar**: Botones de subir/bajar
- **Eliminar**: Botón de eliminar individual
- **Vista previa**: Actualización en tiempo real
- **Cancelar edición**: Botón para cancelar el modo de edición

### 🖨️ Impresión
- Vista previa exacta del ticket
- Formato optimizado para 80mm (72mm de ancho)
- 48 caracteres por línea
- Impresión directa con el paquete `printing`

## Uso

### 1. Acceder al Editor
Desde la pantalla principal de Checklist, presiona el botón flotante **"Editor 80mm"**.

### 2. Crear Contenido
1. Escribe el texto en el campo de entrada
2. Selecciona el formato deseado:
   - Activa/desactiva **Negrita**
   - Elige el **tamaño de fuente**
   - Selecciona la **alineación**
3. Presiona **Agregar** o Enter

### 3. Agregar Separadores
- **Línea**: Agrega una línea de guiones (-)
- **Doble**: Agrega una línea de signos igual (=)

### 4. Organizar Elementos
- Usa las flechas ⬆️⬇️ para reordenar
- Usa 🗑️ para eliminar elementos
- Usa ✏️ para editar elementos existentes

### 4.1. Editar un Elemento
1. Haz clic en el botón **✏️ Editar** del elemento que deseas modificar
2. El elemento se cargará en el editor con su formato actual
3. El título cambiará a **"Editando elemento"**
4. El botón cambiará a **"Actualizar"** con un ícono de check ✓
5. Modifica el texto y/o el formato según necesites
6. Presiona **"Actualizar"** para guardar los cambios
7. O presiona **"Cancelar"** para descartar los cambios

### 5. Vista Previa
El panel derecho muestra exactamente cómo se verá el ticket impreso, con:
- Fuente monoespaciada (Courier)
- Ancho de 48 caracteres
- Formato aplicado

### 6. Imprimir
Presiona el icono 🖨️ en la barra superior para:
- Generar el PDF
- Abrir el diálogo de impresión
- Seleccionar la impresora
- Imprimir el documento

## Especificaciones Técnicas

### Dimensiones
- **Ancho del ticket**: 72mm (80mm nominal)
- **Caracteres por línea**: 48
- **Altura**: Dinámica según contenido

### Tamaños de Fuente
- **Pequeño**: 10pt
- **Normal**: 12pt
- **Grande**: 16pt

### Formato PDF
- Generado con el paquete `pdf`
- Optimizado para impresoras térmicas
- Tamaño de página dinámico

## Ejemplos de Uso

### Recibo de Venta
```
        TIENDA EJEMPLO          (Centro, Grande, Negrita)
------------------------------------------------
Fecha: 02/01/2026 18:20         (Izquierda, Normal)
------------------------------------------------
Producto 1              $10.00  (Izquierda, Normal)
Producto 2              $25.00  (Izquierda, Normal)
------------------------------------------------
Total:                  $35.00  (Derecha, Grande, Negrita)
================================================
      ¡Gracias por su compra!   (Centro, Normal)
```

### Lista de Tareas
```
      TAREAS DEL DÍA            (Centro, Grande, Negrita)
================================================
1. Revisar correos              (Izquierda, Normal)
2. Llamar a cliente             (Izquierda, Normal)
3. Preparar presentación        (Izquierda, Normal)
------------------------------------------------
Total: 3 tareas                 (Izquierda, Pequeño)
```

### Ticket de Evento
```
        ENTRADA VIP             (Centro, Grande, Negrita)
================================================
Evento: Concierto Rock          (Izquierda, Normal)
Fecha: 15/01/2026               (Izquierda, Normal)
Hora: 20:00                     (Izquierda, Normal)
Asiento: A-15                   (Izquierda, Grande)
------------------------------------------------
Código: ABC123XYZ               (Centro, Normal)
================================================
```

## Estructura del Código

### Archivos
- `lib/impresora.dart`: Pantalla principal de checklist
- `lib/text_editor_80mm.dart`: Editor de texto completo

### Clases Principales
- `TextEditorPage`: Widget principal del editor
- `TextElement`: Modelo de datos para elementos de texto
- `TextAlignment`: Enum para alineación
- `FontSize`: Enum para tamaños de fuente

### Métodos Clave
- `_addElement()`: Agrega un nuevo elemento
- `_addSeparator()`: Agrega líneas separadoras
- `_buildPreviewText()`: Genera la vista previa
- `_printDocument()`: Genera y imprime el PDF

## Dependencias
```yaml
dependencies:
  flutter:
    sdk: flutter
  pdf: ^3.10.0
  printing: ^5.11.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  intl: ^0.18.0
```

## Notas Técnicas
- El editor usa un diseño de dos paneles (Row con Expanded)
- La vista previa se actualiza automáticamente con cada cambio
- Los elementos se almacenan en una lista local (no persistente)
- El formato se aplica durante la generación del PDF
- Compatible con impresoras térmicas estándar de 80mm

## Mejoras Futuras
- [ ] Guardar plantillas en Firebase
- [ ] Cargar plantillas predefinidas
- [ ] Agregar imágenes/logos
- [ ] Códigos QR personalizados
- [ ] Exportar a otros formatos
- [ ] Historial de documentos
- [ ] Compartir plantillas

## Autor
Josías Jofré Pol
Contacto: +56967279093
