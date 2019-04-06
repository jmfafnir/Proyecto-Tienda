<?php

class DevolucionVenta implements Persistible {

    /**
     * Devuelve una cadena JSON que contiene el resultado de seleccionar la información básica de ventas
     * Se usa PDO. Ver https://diego.com.es/tutorial-de-pdo
     */
    public function seleccionar($param) {
        throw new Exception("Sin implementar 'seleccionar'");
    }

    public function actualizar($param) {
        throw new Exception("Sin implementar 'actualizar'");
    }

    public function eliminar($param) {
        throw new Exception("Sin implementar 'eliminar'");
    }

    public function listar($param) {
        throw new Exception("Sin implementar 'eliminar'");
    }

    public function listar_ventas($param) {
        extract($param);

        // $sql = "SELECT det.id_detalle_venta,det.cantidad,pro.id_producto,pro.precio,pro.nombre,pro.id_presentacion_producto,pre.descripcion
        // FROM detalles_ventas det JOIN productos pro ON det.id_producto = pro.id_producto JOIN presentaciones_productos pre ON pro.id_presentacion_producto = pre.id_presentacion_producto 
        // WHERE det.id_venta = :id_venta_actual";
        $sql = "SELECT(det.cantidad_vendida-detd.cantidad) cantidad,pro.id_producto,pro.id_categoria_producto,pro.descripcion_producto,pro.precio,
        detd.id_detalle_devolucion_venta,detd.cantidad cantidad_devuelta,det.cantidad_vendida 
        FROM lista_ventas det JOIN lista_productos pro ON det.id_producto = pro.id_producto 
        LEFT JOIN detalles_devoluciones_ventas detd ON det.id_producto = detd.id_producto
        WHERE det.id_venta = :id_venta_actual";

        $instruccion = $conexion->pdo->prepare($sql);
        if($instruccion){
            $instruccion->bindParam(':id_venta_actual', $id_venta);
        }

        if ($instruccion->execute()) {
            $lista = $instruccion->fetchAll(PDO::FETCH_ASSOC);
           // if (count($lista)) {
                $newlista=[];
                foreach ($lista as $clave => $valor){
                    $aux = 0;
                    if($valor['cantidad'] === null ){
                        $aux = $valor['cantidad_vendida'];
                    }else{
                        $aux = $valor['cantidad'];
                    }
                    $newlista[$clave]=[
                        'cantidad'=>$aux,
                        'id_producto'=>$valor['id_producto'],
                        'precio'=>$valor['precio'],
                        'producto'=>$valor['descripcion_producto']
                    ];
                };
                
                echo json_encode($newlista);
            // } else {
            //     echo json_encode(['ok' => FALSE, 'mensaje' => 'La venta no tiene detalles asociados']);
            // }
        } else {
            $conexion->errorInfo($instruccion);
            echo json_encode(['ok' => FALSE, 'mensaje' => 'Imposible consultar el listado de detalles ventas']);
        }

    }

    public function insertar($param) {
        extract($param);
        // error_log(print_r($venta, 1));

        $sql = "SELECT * FROM insertar_devolucion(:datos_devolucion)";
        $instruccion = $conexion->pdo->prepare($sql);

        if ($instruccion) {
            $datosDevolucion = json_encode($devolucion);
            $instruccion->bindParam(':datos_devolucion', $datosDevolucion);

            if ($instruccion->execute()) {
                echo $conexion->errorInfo($instruccion);
            } else {
                echo $conexion->errorInfo($instruccion);
            }
        } else {
            echo json_encode(['ok' => FALSE, 'mensaje' => 'Falló en el registro de la devolucion']);
        }
    }
}