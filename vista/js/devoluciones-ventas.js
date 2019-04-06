'use stric'


new class DevolucionVenta {
    constructor() {
        this.tablaDevoluciones;
        this.id_cliente;
        this.id_venta;
        this.filaActual;

        let instances = M.Datepicker.init($('#devolucion-fecha'), {
            format: 'yyyy-mm-dd',
            i18n: util.datePickerES,
            defaultDate: new Date()
        });

        this.filasPorPagina = 7;

        $('#devolucion-fecha').value = moment(new Date()).format('YYYY-MM-DD'); // <-- observe uno de los usos que se le puede dar a moment.js

        this.inicializarClientes();
        M.FormSelect.init($('#devolucion-venta'));
        this.inicializarTabla(this.verificarCantidad);

        $('#devolucion-cliente').addEventListener('change', event => {
            if (this.tablaDevoluciones) {
                this.tablaDevoluciones.clearData();
            }
            this.id_cliente = $('#devolucion-cliente').value;
            //console.log(this.id_cliente);
            this.crearListaVentas();

            $('#devolucion-venta').addEventListener('change', event => {
                this.id_venta = $('#devolucion-venta').value;
                this.crearLineasDeDevolucion();
            });
        });


        $('#devolucion-cancelar').addEventListener('click', event => {
            this.cancelarDevolucion();
        });

        $('#devolucion-registrar').addEventListener('click', event => {
            this.registrarDevolucion();
        });


    }

    inicializarTabla(_verificarCantidad) {
        this.tablaDevoluciones = new Tabulator("#tabla-devluciones-ventas", {
            ajaxURL: util.URL,
            ajaxParams: {
                clase: 'DevolucionVenta',
                accion: 'listar_ventas',
                id_venta: 0,
            },
            ajaxConfig: 'POST',
            ajaxContentType: 'json',
            layout: 'fitColumns',
            responsiveLayout: 'hide',
            tooltips: true,
            history: true,
            pagination: 'local',
            paginationSize: 5,
            movableColumns: true,
            height: "200px",
            resizableRows: true,
            columns: [{
                    title: "Cantidad Vendida",
                    field: "cantidad",
                    align: 'center'
                },
                {
                    title: "Cantidad a devolver",
                    field: "cantidad_devolver",
                    width: 80,
                    editor: "number",
                    editorParams: {
                        min: 0,
                        max: 1000
                    },
                    align: "right",
                    cellClick: (e, cell) => {
                        // this.filaActual = cell.getRow();
                        // console.log(this.filaActual);
                    },
                    cellEdited: function(celda) {
                        this.filaActual = celda.getRow();
                        _verificarCantidad(celda, this.filaActual);
                    }
                },
                {
                    title: "Producto",
                    field: "producto",
                    align: 'center'
                },
                { field: 'id_producto', visible: false },
                { field: 'precio', visible: false }

            ],
            index: 'id_producto',
            rowAdded: (row) => this.filaActual = row
        });
    }

    crearLineasDeDevolucion() {

        this.tablaDevoluciones.setData(util.URL, {
            clase: 'DevolucionVenta',
            accion: 'listar_ventas',
            id_venta: this.id_venta
        }).then(

        ).catch(

        );
    }

    prueva() {
        util.fetchData(util.URL, {
            'body': {
                clase: 'DevolucionVenta',
                accion: 'listar_ventas',
                id_venta: this.id_venta
            }

        }).then(lista => {
            console.log(lista);
            console.log(typeof(lista[0]))
        })
    }

    crearListaVentas() {
        util.fetchData(util.URL, {
            'body': {
                'clase': 'Venta',
                'accion': 'listar',
                'id_cliente': this.id_cliente
            }

        }).then(lista => {
            if (lista.ok) {
                util.crearLista('#devolucion-venta', lista.lista, 'id_venta', 'id_venta_fecha', 'Seleccione una venta');
            } else {
                util.mensaje(lista.mensaje, 'EL cliente no tiene ventas asociadas');
            }


        }).catch(error => {
            util.mensaje(error, 'Sin acceso a la lista de ventas');
        });
    }

    /**
     * Intenta recuperar la lista de clientes y si es posible, continúa intentando recuperar el siguiente
     * número de factura. Si también lo logra ejecuta crearListaProductos, para que continúe el proceso
     * de inicialización de la facturación
     */
    inicializarClientes() {

        util.cargarLista({ // llenar los elementos de la lista desplegable de clientes
            clase: 'Cliente',
            accion: 'listar',
            listaSeleccionable: '#devolucion-cliente',
            clave: 'id_cliente',
            valor: 'nombre',
            primerItem: 'Seleccione un cliente'
        }).then(() => {
            // $('#devolucion-cliente').value = '';
            // M.FormSelect.init($('#devolucion-cliente'));

            // util.siguiente('devolucion-ventas', 'id_devolucion_venta').then(data => {
            //     if (data.ok) {
            //         $('#devolucion-numero').value = data.siguiente;
            //         M.updateTextFields();
            //         this.crearListaProductos();
            //     } else {
            //         throw new Error(data.mensaje);
            //     }
            // }).catch(error => {
            //     util.mensaje(error, 'ID de pagos de ventas indeterminado');
            // });
        }).catch(error => {
            util.mensaje(error, 'Sin acceso a la lista de clientes');
        });
    }

    verificarCantidad(cel, fila) {
        if (cel.getValue() > fila.getData().cantidad) {
            M.toast({ html: 'No puede devolver mas productos de los que compro' });
            cel.setValue(0);
        }
    }

    registrarDevolucion() {

        if ($('#devolucion-venta').value === 'Seleccione una venta') {
            M.toast({ html: 'Debe seleccionar una venta' });
            return;
        }
        let detalles = this.obtenerDetallesValidos();

        if (detalles.length === 0) {
            M.toast({ html: 'No ha ingresado devoluciones validas' });
            return;
        }
        console.log(detalles);

        if (!moment($('#devolucion-fecha').value).isValid()) {
            M.toast({ html: 'Formato de fecha incorrecto' });
            return;
        }


        let devolucion = {
            id_venta: this.id_venta,
            fecha_devolucion: $('#devolucion-fecha').value,
            detalle: detalles
        };

        util.fetchData(util.URL, {
            'method': 'POST',
            'body': {
                clase: 'DevolucionVenta',
                accion: 'insertar',
                devolucion: devolucion
            }
        }).then(data => {
            // si todo sale bien se retorna el ID de la venta registrada
            if (data.ok) {
                M.toast({ html: `Devolucion incertada con exito` });
                this.tablaDevoluciones.clearData();
                $('#devolucion-venta').value = '';
                M.FormSelect.init($('#devolucion-cliente'));
            } else {
                throw new Error(data.mensaje);
            }
        }).catch(error => {
            util.mensaje(error, 'Fallo al intentar registrar una nueva venta');
        });

    }

    obtenerDetallesValidos() {
        let detalles_devolucion = [];
        this.tablaDevoluciones.getData().forEach(element => {

            if (element.cantidad_devolver === undefined || element.cantidad_devolver === 0 || element.cantidad_devolver === '') {

            } else {
                detalles_devolucion.push(element);
            };

        });
        return detalles_devolucion;
    }


    cancelarDevolucion() {
        this.tablaDevoluciones.clearData();
        //M.FormSelect.init($('#devolucion-venta'));
        $('#devolucion-venta').value = 0;
        //dispatchEvent

    }
}