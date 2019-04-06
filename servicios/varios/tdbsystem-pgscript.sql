
-- TDBSystem (Base de datos para el Sistema "Tienda de Barrio"), versión 0.6
-- Un simple modelo de bases de datos para fines académicos
-- Cree una base de datos Postgres en blanco y corra este script sobre ella.

-- Enseguida, se usa DDL (Data Definition Language) para crear la base de datos

DROP TABLE IF EXISTS categorias_productos CASCADE;
DROP TABLE IF EXISTS presentaciones_productos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS bajas_productos;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS pagos_clientes;
DROP TABLE IF EXISTS personal CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS pagos_proveedores;
DROP TABLE IF EXISTS ventas CASCADE;
DROP TABLE IF EXISTS detalles_ventas;
DROP TABLE IF EXISTS devoluciones_ventas CASCADE;
DROP TABLE IF EXISTS detalles_devoluciones_ventas;
DROP TABLE IF EXISTS compras CASCADE;
DROP TABLE IF EXISTS detalles_compras;
DROP TABLE IF EXISTS devoluciones_compras CASCADE;
DROP TABLE IF EXISTS detalles_devoluciones_compras;

DROP VIEW IF EXISTS lista_productos CASCADE;

DROP FUNCTION IF EXISTS insertar_producto CASCADE;
DROP FUNCTION IF EXISTS insertar_venta CASCADE;
DROP FUNCTION IF EXISTS insertar_presentacion CASCADE;
DROP FUNCTION IF EXISTS insertar_categoria CASCADE;
DROP FUNCTION IF EXISTS maximo;
DROP FUNCTION IF EXISTS insertar_pago_cliente;
DROP FUNCTION IF EXISTS insertar_baja_producto;
DROP FUNCTION IF EXISTS insertar_compra;

DROP TYPE IF EXISTS tipo_detalle CASCADE;
DROP TYPE IF EXISTS tipo_detalle2 CASCADE;

CREATE TABLE categorias_productos (
	id_categoria_producto SMALLSERIAL NOT NULL,
	nombre varchar NOT NULL UNIQUE,
	PRIMARY KEY(id_categoria_producto)
);

CREATE TABLE presentaciones_productos (
	id_presentacion_producto SMALLSERIAL NOT NULL,
	descripcion varchar NOT NULL UNIQUE,
	PRIMARY KEY(id_presentacion_producto)
);

CREATE TABLE productos (
	id_producto SERIAL NOT NULL,
	nombre varchar NOT NULL UNIQUE,
	precio numeric NOT NULL DEFAULT 0,
	iva numeric NOT NULL DEFAULT 0.0,
	cantidad_disponible int2 NOT NULL DEFAULT 0,
	cantidad_minima int2 NOT NULL DEFAULT 1,
	cantidad_maxima int2 NOT NULL DEFAULT 1,
	id_presentacion_producto int2 NOT NULL,
	id_categoria_producto int2 NOT NULL,
	PRIMARY KEY(id_producto),
	CONSTRAINT ref_producto__categoria_producto FOREIGN KEY (id_categoria_producto)
		REFERENCES categorias_productos(id_categoria_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_producto__presentacion_producto FOREIGN KEY (id_presentacion_producto)
		REFERENCES presentaciones_productos(id_presentacion_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE bajas_productos (
	id_baja_producto SERIAL NOT NULL,
	tipo_baja varchar NOT NULL,
	fecha date NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	precio numeric NOT NULL DEFAULT 0,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_baja_producto),
	CONSTRAINT tipos_bajas CHECK (tipo_baja IN ('Donación', 'Daño', 'Pérdida', 'Descomposición', 'Destrucción', 'Exclusión')),
	CONSTRAINT ref_baja_productos__producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE clientes (
	id_cliente varchar NOT NULL,
	nombre varchar NOT NULL,
	telefonos varchar,
	direccion varchar,
	con_credito bool NOT NULL,
	PRIMARY KEY(id_cliente)
);

CREATE TABLE pagos_clientes (
	id_pago_cliente SERIAL NOT NULL,
	id_cliente varchar NOT NULL,
	valor_pago numeric NOT NULL DEFAULT 0,
	fecha_pago date NOT NULL,
	PRIMARY KEY(id_pago_cliente),
	CONSTRAINT ref_pago_cliente__cliente FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE personal (
	id_persona varchar NOT NULL,
	nombre varchar NOT NULL,
	telefono varchar NOT NULL,
	direccion varchar NOT NULL,
	perfil varchar NOT NULL,
	contrasena varchar NOT NULL,
	PRIMARY KEY(id_persona),
	CONSTRAINT tipo_perfil CHECK (perfil IN('Administrador', 'Vendedor'))
);

CREATE TABLE proveedores (
	id_proveedor varchar NOT NULL,
	nombre varchar NOT NULL,
	telefono varchar NOT NULL,
	correo varchar,
	PRIMARY KEY(id_proveedor)
);

CREATE TABLE pagos_proveedores (
	id_pago_proveedor SERIAL NOT NULL,
	id_proveedor varchar NOT NULL,
	valor_pago numeric NOT NULL DEFAULT 0,
	fecha_pago date NOT NULL,
	PRIMARY KEY(id_pago_proveedor),
	CONSTRAINT ref_pago_proveedor__proveedor FOREIGN KEY (id_proveedor)
		REFERENCES proveedores(id_proveedor)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE ventas (
	id_venta SERIAL NOT NULL,
	fecha_venta date NOT NULL,
	total_credito numeric NOT NULL DEFAULT 0,
	total_contado numeric NOT NULL DEFAULT 0,
	id_cliente varchar NOT NULL,
	id_vendedor varchar NOT NULL,
	PRIMARY KEY(id_venta),
	CONSTRAINT ref_venta__cliente FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_venta__personal FOREIGN KEY (id_vendedor)
		REFERENCES personal(id_persona)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_ventas (
	id_detalle_venta SERIAL NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	valor_producto numeric NOT NULL DEFAULT 0,
	descuento numeric NOT NULL DEFAULT 0,
	iva numeric NOT NULL DEFAULT 0,
	id_venta int4 NOT NULL,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_detalle_venta),
	CONSTRAINT ref_detalle_venta_a_venta FOREIGN KEY (id_venta)
		REFERENCES ventas(id_venta)
	MATCH SIMPLE
	ON DELETE CASCADE
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_detalle_venta__producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE CASCADE
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

-- COMMENT ON COLUMN detalles_ventas.valor_producto IS 'debe permitir cálculo y entrada directa';

CREATE TABLE devoluciones_ventas (
	id_devolucion_venta SERIAL NOT NULL,
	id_venta int4 NOT NULL,
	fecha date NOT NULL,
	PRIMARY KEY(id_devolucion_venta),
	CONSTRAINT ref_devolucion_venta__venta FOREIGN KEY (id_venta)
		REFERENCES ventas(id_venta)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_devoluciones_ventas (
	id_detalle_devolucion_venta SERIAL NOT NULL,
	id_devolucion_venta int4 NOT NULL,
	id_producto int4 NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	PRIMARY KEY(id_detalle_devolucion_venta),
	CONSTRAINT ref_detalle_devolucion__devolucion_venta FOREIGN KEY (id_devolucion_venta)
		REFERENCES devoluciones_ventas(id_devolucion_venta)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE compras (
	id_compra SERIAL NOT NULL,
	fecha_compra date NOT NULL,
	fecha_recibido date NOT NULL,
	total_credito numeric NOT NULL DEFAULT 0,
	total_contado numeric NOT NULL DEFAULT 0,
	id_proveedor varchar NOT NULL,
	PRIMARY KEY(id_compra),
	CONSTRAINT ref_compra__proveedor FOREIGN KEY (id_proveedor)
		REFERENCES proveedores(id_proveedor)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_compras (
	id_detalle_compra SERIAL NOT NULL,
	cantidad_pedida int2 NOT NULL DEFAULT 0,
	cantidad_recibida int2 NOT NULL DEFAULT 0,
	valor_producto numeric NOT NULL DEFAULT 0,
	iva numeric DEFAULT 0,
	id_compra int4 NOT NULL,
	id_producto int4 NOT NULL,
	PRIMARY KEY(id_detalle_compra),
	CONSTRAINT ref_detalle_compra__compra FOREIGN KEY (id_compra)
		REFERENCES compras(id_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE,
	CONSTRAINT ref_detalle_compra__presentacion_producto FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE devoluciones_compras (
	id_devolucion_compra SERIAL NOT NULL,
	id_compra int4 NOT NULL,
	fecha_devolucion date NOT NULL,
	PRIMARY KEY(id_devolucion_compra),
	CONSTRAINT ref_devolucion_pedido_a_pedido FOREIGN KEY (id_compra)
		REFERENCES compras(id_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

CREATE TABLE detalles_devoluciones_compras (
	id_detalle_devolucion_compra SERIAL NOT NULL,
	id_devolucion_compra int4 NOT NULL,
	id_producto int4 NOT NULL,
	cantidad int2 NOT NULL DEFAULT 0,
	PRIMARY KEY(id_detalle_devolucion_compra),
	CONSTRAINT ref_detalle_devolucion_pedido__devolucion_pedido FOREIGN KEY (id_devolucion_compra)
		REFERENCES devoluciones_compras(id_devolucion_compra)
	MATCH SIMPLE
	ON DELETE NO ACTION
	ON UPDATE CASCADE
	NOT DEFERRABLE
);

-- A continuación un poco de Data Manipulation Language (DML) para disponer de algunas pruebas

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL001', 'Juan José Hernández Hernández', '8760001', 'Calle 10 # 11-11', true)
	ON CONFLICT DO NOTHING;	
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL002', 'Miguel Angel García García', '8760002', 'Calle 11 # 11-12', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL003', 'Juan Sebastián García García', '8760003', 'Calle 12 # 11-13', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL004', 'Juan David García Hernández', '8760004', 'Calle 13 # 11-14', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL005', 'Samuel David García García', '8760005', 'Calle 13 # 12-14', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL006', 'Juan Pablo García García', '8760006', 'Calle 13 # 12-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL007', 'Andrés Felipe García Martínez', '8760007', 'Calle 10 # 12-15', true)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL008', 'Juan Esteban Hernández Hernández', '8760008', 'Calle 12 # 11-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL009', 'Juan Diego Flores García', '8760009', 'Calle 10 # 11-15', false)
	ON CONFLICT DO NOTHING;		

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES ('CL010', 'Angel David García Hernández', '8760010', 'Calle 9 # 11-15', false)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL011','Francisco Diaz Diaz','8530000','Cra. 4 #18-32',true)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL012','Luciana Garcia Jimenez','8534523','Cra. 1#13-18',true)
	ON CONFLICT DO NOTHING;

INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL013','Sofia Lopez Trejos','8532310','Cra. 5 #16-52',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL014','Melissa Mesa Marin','8538975','Cra. 7 #20-25',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL015','Nicole Torres Marin','8539632','Cra. 6 #18-41',true)
	ON CONFLICT DO NOTHING;
	
INSERT INTO clientes(
	id_cliente, nombre, telefonos, direccion, con_credito)
	VALUES('CL016','Sol Carvajal Mejia','8530000','Cra.1 #13-20',true)
	ON CONFLICT DO NOTHING;
	
-------------------------------------	

INSERT INTO categorias_productos(nombre) VALUES ('Lacteos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Cárnicos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Frutas') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Verduras') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Cereales') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Aseo personal') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Aseo del hogar') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Condimentos') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Bebidas') ON CONFLICT DO NOTHING;
INSERT INTO categorias_productos(nombre) VALUES ('Licores') ON CONFLICT DO NOTHING;

INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 1000 cc') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 12 unidades') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 500 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 1 kg') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 2.5 lt.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 1 lt.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Botella no retornable x 600 ml.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Bolsa x 5 kg. aprox.') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Unidad') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja x 250 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja x 500 gramos') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Paquete x 3 Unidades') ON CONFLICT DO NOTHING;
INSERT INTO presentaciones_productos(descripcion) VALUES ('Caja') ON CONFLICT DO NOTHING;

-------------------------------------	

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Leche Colanta', 2000, 19, 3, 20, 1, 1) 
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lecha entera Celema', 1900, 49, 2, 15, 1, 1)
	 ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mandarinas', 3000, 59, 3, 10, 2, 3)
	 ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lentejas', 1000, 10, 5, 30, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Arroz Doña Pepa', 1200, 39, 5, 25, 3, 5)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Maíz trillado', 900, 69, 3, 10, 4, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Lechuga', 1500, 79, 3, 10, 3, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Kiwi', 2000, 39, 2, 9, 12, 3)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Maracuya', 3000, 39, 3, 10, 12, 3)
	ON CONFLICT DO NOTHING;
								  
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Cereal Madagascar', 3000, 1, 3, 10, 3, 5)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Cafe Monumental', 4500, 29, 5, 10, 3, 4)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mantequilla Colanta', 3800, 29, 3, 10, 9, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Jabon Ariel', 7800, 19, 3, 15, 4, 7)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Manzanas', 4500, 39, 3, 15, 12, 3)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Arroz Buen Dia', 1500, 19, 10, 30, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Frijol del Costal', 1500, 29, 5, 20, 3, 5)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Mantequilla Don Oleo', 3500, 19, 10, 20, 9, 4)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Crema de leche Colanta', 2200, 19, 10, 40, 3, 1)
	ON CONFLICT DO NOTHING;
	
INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Jabon en polvo Josefina', 4000, 19, 5, 20, 4, 7)
	ON CONFLICT DO NOTHING;

INSERT INTO productos(nombre, precio, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
	VALUES('Crema dental Colgate', 1800, 19, 10, 20, 9, 6)
	ON CONFLICT DO NOTHING;
	
-------------------------------------	

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('001','Jorge Pérez','8530001','Cra.3#10-34','Administrador','827ccb0eea8a706c4c34a16891f84e7b')
	ON CONFLICT DO NOTHING;
	
INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('002','Valeria Mejia Zapata','8536345','Cra.5#19-37','Vendedor','827ccb0eea8a706c4c34a16891f84e7b')
	ON CONFLICT DO NOTHING;
	
INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('003','Juan Bermudez Duque','8531235','Cra.1#11-23','Vendedor','827ccb0eea8a706c4c34a16891f84e7b')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('004','Carlos Franco','3237059840','Calle 15 #30-17','Administrador','akm12')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('005','Edgar Velez','3157059840','Calle 25 #32-17','Vendedor','bkm13')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('006','Cristian Aristi','3183059840','Calle 95 #90-17','Vendedor','ckm14')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('007','Jose Londoño','3111059840','Calle 65 #10-27','Vendedor','dkm15')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('008','Juan Duran','3104059840','Calle 65 #50-57','Vendedor','ekm16')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('009','Maria Gomez','3110059840','Calle 65 #30-10','Vendedor','fkm17')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('010','Liliana Franco','3112059840','Calle 65 #30-40','Administrador','jkm18')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('011','Ana Solarte','3135459840','Calle 65 #12-11','Vendedor','hkm19')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('012','Josefa Franco','3106059840','Calle 65 #20-17','Vendedor','ikm10')
	ON CONFLICT DO NOTHING;

INSERT INTO personal(id_persona, nombre, telefono, direccion, perfil, contrasena)
	VALUES('013','Jenny Franco','3114059840','Calle 65 #10-17','Administrador','jkm21')
	ON CONFLICT DO NOTHING;

-------------------------------------	

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR01','Distribuidora Donde Pancho','7852212','dondepancho@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR02','Distribuidora Nuevo Sol','7852546','nuevosol@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR03','Lacteos Doña Vaca','7852345','vaca12@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR04','Granos La Cosecha','7852897','cose@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR05','Embutidos Don Chorizo','7652431','donchorizo@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR06','Fruteria Su Media Naranja','7552431','mimedianaranja@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR07','Productos y Productos SA','7752431','elproducto@gmail.com')
	ON CONFLICT DO NOTHING;

INSERT INTO proveedores(id_proveedor, nombre, telefono, correo)
	VALUES('PR08','Distribuidora ComaRico','7152431','comaricobien@gmail.com')
	ON CONFLICT DO NOTHING;
	
INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P005', 'Jader Raúl Gomez', '8783400', 'jadergomez@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P006', 'Juan Carmona', '8926241', 'juancarmona@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P007', 'Juan Diego Castaño', '8451201', 'diegocastño@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P008', 'Juliana Reyes', '8120167', 'julianareyes@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P009', 'Andres Calamaro', '8791203', 'andrescalamaro@gmail.com')
	ON CONFLICT DO NOTHING;	

INSERT INTO proveedores(
	id_proveedor, nombre, telefono, correo)
	VALUES ('P010', 'Jaime Soto', '8916060', 'jaimesoto@gmail.com')
	ON CONFLICT DO NOTHING;		
								  
-- A continuación algunas instrucciones DML disponibles mediante vistas o procedimientos almacenados
								  
CREATE OR REPLACE VIEW lista_productos AS										  
	SELECT 	c.id_categoria_producto,
				c.nombre categoria,
				pp.id_presentacion_producto,
				pp.descripcion presentacion,
				p.id_producto,
				p.nombre nombre,	
				p.nombre || ' ' || pp.descripcion descripcion_producto,
				iva porcentaje_iva,
				p.precio,
				p.cantidad_disponible,									  
				p.cantidad_minima,									  
				p.cantidad_maxima									  
			FROM productos p
				INNER JOIN categorias_productos c ON p.id_categoria_producto = c.id_categoria_producto
				INNER JOIN presentaciones_productos pp ON p.id_presentacion_producto = pp.id_presentacion_producto
			ORDER BY p.nombre, pp.descripcion;

CREATE OR REPLACE FUNCTION insertar_presentacion(descripcion_presentacion character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idpresentacion integer;
BEGIN
	idpresentacion = 0;
	
	INSERT INTO presentaciones_productos(descripcion) VALUES (descripcion_presentacion)
		RETURNING id_presentacion_producto into idpresentacion;
	RETURN idpresentacion;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_categoria(nombre_categoria character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idcategoria integer;
BEGIN
	idcategoria = 0;
	
	INSERT INTO categorias_productos(nombre) VALUES (nombre_categoria)
		RETURNING id_categoria_producto into idcategoria;
	RETURN idcategoria;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_producto(
	nombre_producto character varying,
	precio_producto numeric,
	porcentaje_iva numeric,
	disponible integer,
	minimo integer,
	maximo integer,
	id_presentacion integer,
	id_categoria integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idproducto integer;
BEGIN
	idproducto = 0;
	
	INSERT INTO productos(
		nombre, precio, iva, cantidad_disponible, cantidad_minima, cantidad_maxima, id_presentacion_producto, id_categoria_producto)
		VALUES (nombre_producto, precio_producto, porcentaje_iva, disponible, minimo, maximo, id_presentacion, id_categoria)
		RETURNING id_producto into idproducto;
	RETURN idproducto;
END;
$BODY$;

-- determina cuál es el máximo valor de una columna de tipo entero en cualquier tabla
CREATE OR REPLACE FUNCTION maximo(
	tabla character varying,
	columna character varying)
	RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      existe boolean;
	  ultimo integer;
	  sql varchar;
BEGIN
    -- https://www.postgresql.org/docs/current/functions-string.html#FUNCTIONS-STRING-FORMAT
	EXECUTE format('SELECT COUNT(*) > 0 FROM information_schema.columns WHERE table_name = %L and column_name = %L',
				   tabla, columna) INTO existe;
	IF existe THEN
		EXECUTE format('SELECT MAX(%s) FROM %s', columna, tabla) INTO ultimo;
		IF ultimo IS NULL THEN
			ultimo = 0;
		END IF;
		RETURN ultimo;
	ELSE
		RAISE EXCEPTION 'Tabla o columna errónea: % | %', tabla, columna;
	END IF;
END;
$BODY$;

-- Un bloque anónimo para la creación controlada de un tipo necesario para la inserción de detalles de ventas/compras

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_detalle') THEN
        CREATE TYPE tipo_detalle AS (
			cantidad integer, 
			cantidad_pedida integer, 
			cantidad_recibida integer, 
			producto varchar, 
			valor numeric, 
			iva_porcentaje numeric, 
			iva_valor numeric, 
			subtotal numeric
		);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_detalle2') THEN
        CREATE TYPE tipo_detalle2 AS (
			cantidad NUMERIC,
			cantidad_devolver NUMERIC,
			id_producto INTEGER,
			precio NUMERIC
		);
    END IF;
END$$;

-- la función que registra la venta, los detalles de venta y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_venta(datos_venta JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	idventa INTEGER;
	idproducto INTEGER;
	fecha DATE;
	cliente VARCHAR;
	vendedor VARCHAR;
	total NUMERIC;
	iva NUMERIC;
	paga NUMERIC;
	credito NUMERIC;
	linea_venta RECORD;
BEGIN
	idventa = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_venta', excepto el array 'detalle'
	SELECT (datos_venta#>>'{fecha}')::DATE FROM json_each(datos_venta) WHERE key = 'fecha' INTO fecha;
	SELECT (datos_venta#>>'{cliente}')::VARCHAR FROM json_each(datos_venta) WHERE key = 'cliente' INTO cliente;
	SELECT (datos_venta#>>'{vendedor}')::VARCHAR FROM json_each(datos_venta) WHERE key = 'vendedor' INTO vendedor;
	SELECT (datos_venta#>>'{total}')::FLOAT FROM json_each(datos_venta) WHERE key = 'total' INTO total;
	SELECT (datos_venta#>>'{iva}')::FLOAT FROM json_each(datos_venta) WHERE key = 'iva' INTO iva;
	SELECT (datos_venta#>>'{paga}')::FLOAT FROM json_each(datos_venta) WHERE key = 'paga' INTO paga;
	
	credito = total - paga;
	
	INSERT INTO ventas(fecha_venta, total_credito, total_contado, id_cliente, id_vendedor)
		VALUES (fecha, credito, paga, cliente, vendedor) 
		RETURNING id_venta INTO idventa;
	
	IF idventa > 0 THEN
		-- recorre las filas correspondientes a cada detalle de venta
		FOR linea_venta IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_venta) WHERE key = 'detalle')
			) LOOP
			
			i = strpos(linea_venta.producto, '-') - 1;
			idproducto = substr(linea_venta.producto, 1, i);
			
			-- por cada detalle, inserta una línea de venta. Esta versión NO maneja descuentos (0.0)
			INSERT INTO detalles_ventas(cantidad, valor_producto, descuento, iva, id_venta, id_producto)
				VALUES (linea_venta.cantidad, linea_venta.valor, 0.0, linea_venta.iva_valor, idventa, idproducto);
			
			-- en productos, sustraer la cantidad vendida de la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible - linea_venta.cantidad 
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN idventa;
END;
$BODY$;

-- la función que registra la compra, los detalles de compra y afecta el stock de productos

CREATE OR REPLACE FUNCTION insertar_compra(datos_compra JSON)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	i INTEGER;
	idcompra INTEGER;
	idproducto INTEGER;
	fechacompra DATE;
	fecharecibido DATE;
	proveedor VARCHAR;
	total NUMERIC;
	iva NUMERIC;
	paga NUMERIC;
	credito NUMERIC;
	linea_compra RECORD;
BEGIN
	idcompra = 0;
	-- transfiere a variables las propiedades del objeto JSON 'datos_compra', excepto el array 'detalle'
	SELECT (datos_compra#>>'{fecha_compra}')::DATE FROM json_each(datos_compra) WHERE key = 'fecha_compra' INTO fechacompra;
	SELECT (datos_compra#>>'{fecha_recibido}')::DATE FROM json_each(datos_compra) WHERE key = 'fecha_recibido' INTO fecharecibido;
	SELECT (datos_compra#>>'{proveedor}')::VARCHAR FROM json_each(datos_compra) WHERE key = 'proveedor' INTO proveedor;
	SELECT (datos_compra#>>'{total}')::FLOAT FROM json_each(datos_compra) WHERE key = 'total' INTO total;
	SELECT (datos_compra#>>'{iva}')::FLOAT FROM json_each(datos_compra) WHERE key = 'iva' INTO iva;
	SELECT (datos_compra#>>'{paga}')::FLOAT FROM json_each(datos_compra) WHERE key = 'paga' INTO paga;
	
	credito = total - paga;
	
	INSERT INTO compras(fecha_compra, fecha_recibido, total_credito, total_contado, id_proveedor)
		VALUES (fechacompra, fecharecibido, credito, paga, proveedor)
		RETURNING id_compra INTO idcompra;
	
	IF idcompra > 0 THEN
		-- recorre las filas correspondientes a cada detalle de compra
		FOR linea_compra IN
			-- expande el array de objetos 'detalle' a un conjunto de filas de tipo 'tipo_detalle'
			SELECT * FROM json_populate_recordset(null::tipo_detalle, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_compra) WHERE key = 'detalle')
			) LOOP
			
			i = strpos(linea_compra.producto, '-') - 1;
			idproducto = substr(linea_compra.producto, 1, i);
			
			-- por cada detalle, inserta una línea de compra. Esta versión NO maneja descuentos (0.0)
			INSERT INTO detalles_compras(cantidad_pedida, cantidad_recibida, valor_producto, iva, id_compra, id_producto)
				VALUES (linea_compra.cantidad_pedida, linea_compra.cantidad_recibida, linea_compra.valor, linea_compra.iva_valor, idcompra, idproducto);
			
			-- en productos, aumentar la cantidad comprada a la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible + linea_compra.cantidad_recibida
				WHERE id_producto = idproducto;
		END LOOP;
	END IF;
	
	RETURN idcompra;
END;
$BODY$;


------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insertar_devolucion(datos_devolucion JSON)
	RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	id_devolucion INTEGER;
	id_venta_actual INTEGER;
	fecha_devolucion DATE;
	linea_devolucion RECORD;
BEGIN
	-- transfiere a variables las propiedades del objeto JSON 'datos_compra', excepto el array 'detalle'
	SELECT (datos_devolucion#>>'{id_venta}')::INTEGER FROM json_each(datos_devolucion) WHERE key = 'id_venta' INTO id_venta_actual;
	SELECT (datos_devolucion#>>'{fecha_devolucion}')::DATE FROM json_each(datos_devolucion) WHERE key = 'fecha_devolucion' INTO fecha_devolucion;
	--SELECT (datos_devolucion#>>'{id_venta}')::RECORD FROM json_each(datos_devolucion) WHERE key = 'id_venta' INTO linea_devolucion;
	
	INSERT INTO devoluciones_ventas(id_venta,fecha)
		VALUES (id_venta_actual, fecha_devolucion)
		RETURNING id_devolucion_venta into id_devolucion;

	IF id_devolucion > 0 THEN
		-- recorre las filas correspondientes a cada detalle de compra
		FOR linea_devolucion IN

			SELECT * FROM json_populate_recordset(null::tipo_detalle2, (
				-- recupera el JSON correspondiente a la propiedad 'detalle'
				SELECT value FROM json_each(datos_devolucion) WHERE key = 'detalle')
			) LOOP

				INSERT INTO detalles_devoluciones_ventas(id_devolucion_venta,id_producto,cantidad)
				VALUES (id_devolucion,linea_devolucion.id_producto,linea_devolucion.cantidad_devolver);
			
			-- en productos, aumentar la cantidad comprada a la cantidad_disponible 
			UPDATE productos SET cantidad_disponible = cantidad_disponible + linea_devolucion.cantidad_devolver
				WHERE id_producto = linea_devolucion.id_producto;
			UPDATE ventas SET total_credito = total_credito - linea_devolucion.cantidad_devolver*linea_devolucion.precio
				WHERE id_venta = id_venta_actual;
		END LOOP;
	END IF;
	
	RETURN id_venta_actual;
		
END;
$BODY$;
------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW lista_ventas AS
	SELECT sum(det.cantidad) cantidad_vendida,det.id_producto,det.id_venta
	FROM detalles_ventas det
	GROUP BY det.id_producto,det.id_venta;
	


-------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION insertar_pago_cliente(cliente character varying, valor numeric, fecha date)
	RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idpago integer;
BEGIN
	idpago = 0;
	INSERT INTO pagos_clientes(id_cliente, valor_pago, fecha_pago) VALUES (cliente, valor, fecha)
	RETURNING id_pago_cliente into idpago;
	RETURN idpago;
END;
$BODY$;

CREATE OR REPLACE FUNCTION insertar_baja_producto(
	tipobaja character varying,
	fechabaja date,
	idproducto integer,
	cantidadbaja integer,
	precioproducto numeric)
	RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$
   DECLARE
      idbaja integer;
BEGIN
	idbaja = 0;

	INSERT INTO bajas_productos(
		tipo_baja, fecha, id_producto, cantidad, precio)
		VALUES (tipobaja, fechabaja, idproducto, cantidadbaja, precioproducto) 
		RETURNING id_baja_producto into idbaja;
	
	-- en productos, sustraer la cantidad de baja, de la cantidad_disponible 
	UPDATE productos SET cantidad_disponible = cantidad_disponible - cantidadbaja 
		WHERE id_producto = idproducto;
		
	RETURN idbaja;
END;
$BODY$;
