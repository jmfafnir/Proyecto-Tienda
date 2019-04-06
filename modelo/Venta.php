<?php

class Venta implements Persistible {

    /**
     * Devuelve una cadena JSON que contiene el resultado de seleccionar la información básica de ventas
     * Se usa PDO. Ver https://diego.com.es/tutorial-de-pdo
     */
    public function seleccionar($param) {
        extract($param);
        // error_log(print_r($param, TRUE)); // quitar comentario para ver lo que se recibe del front-end

        $sql = "SELECT id_venta, fecha_venta, total_credito, total_contado, id_cliente, id_vendedor
                   FROM ventas
                   WHERE id_cliente = :cliente
                ORDER BY fecha_venta";
        // prepara la instrucción SQL para ejecutarla, luego recibir los parámetros de filtrado
        $q = $conexion->pdo->prepare($sql);
        $q->execute([':cliente' => $cliente]);
        $filas = $q->fetchAll(PDO::FETCH_ASSOC); // devuelve un array que contiene todas las filas del conjunto de resultados
        echo json_encode($filas); // las filas resultantes son enviadas en formato JSON al frontend
    }

    public function actualizar($param) {
        throw new Exception("Sin implementar 'actualizar'");
    }

    public function eliminar($param) {
        throw new Exception("Sin implementar 'eliminar'");
    }

    
    public function listar($param) {
        extract($param);

        $sql = "SELECT * FROM ventas WHERE id_cliente = :id_cliente_actual ORDER BY id_venta";
        
        $instruccion = $conexion->pdo->prepare($sql);
        if($instruccion){
            $instruccion->bindParam(':id_cliente_actual', $id_cliente);
        }

        if ($instruccion->execute()) {
            $lista = $instruccion->fetchAll(PDO::FETCH_ASSOC);
            if (count($lista)) {
                 $listaMinima=[];
                 
                foreach ($lista as $clave => $valor){
                    $listaMinima[$clave] = ['id_venta'=>$valor['id_venta'],
                    'id_venta_fecha'=>'#venta '.$valor['id_venta'].' fecha:'.$valor['fecha_venta']];
                    
                };

                echo json_encode(['ok' => TRUE, 'lista' => $listaMinima]);
            } else {
                echo json_encode(['ok' => FALSE, 'mensaje' => 'El cliente no tiene ventas asociadas']);
            }
        } else {
            $conexion->errorInfo($instruccion);
            echo json_encode(['ok' => FALSE, 'mensaje' => 'Imposible consultar el listado de ventas']);
        }

    }

    public function insertar($param) {
        extract($param);
        // error_log(print_r($venta, 1));

        $sql = "SELECT * FROM insertar_venta(:datos_venta)";
        $instruccion = $conexion->pdo->prepare($sql);

        if ($instruccion) {
            $datosVenta = json_encode($venta);
            $instruccion->bindParam(':datos_venta', $datosVenta);

            if ($instruccion->execute()) {
                $fila = $instruccion->fetch(PDO::FETCH_ASSOC); // si la inserción fue exitosa, recuperar el ID retornado
                $info = $conexion->errorInfo($instruccion, FALSE);
                $info['ok'] = $fila['insertar_venta'] > 0;
                $info['id_venta'] = $fila['insertar_venta'] + 1; // agregar el nuevo ID a la info que se envía al front-end
                echo json_encode($info);
            } else {
                echo $conexion->errorInfo($instruccion);
            }
        } else {
            echo json_encode(['ok' => FALSE, 'mensaje' => 'Falló en el registro de la nueva venta']);
        }
    }

    public function seleccionar2($param) {
        extract($param);
        // error_log(print_r($param, TRUE)); // quitar comentario para ver lo que se recibe del front-end

        $sql = "SELECT id_venta, fecha_venta, total_credito, total_contado, id_cliente, id_vendedor
                   FROM ventas
                ORDER BY fecha_venta";
        // prepara la instrucción SQL para ejecutarla, luego recibir los parámetros de filtrado
        $q = $conexion->pdo->prepare($sql);
        if ($q->execute()){
            $filas = $q->fetchAll(PDO::FETCH_ASSOC); // devuelve un array que contiene todas las filas del conjunto de resultados
            echo json_encode($filas); // las filas resultantes son enviadas en formato JSON al frontend  
        }

    }
}