package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    private static final String URL =
        "jdbc:mysql://mysql-26b5bccf-coloniagatos-3a63.b.aivencloud.com:23916/alquiler_vehiculos?sslMode=REQUIRED&connectionTimeZone=America/Argentina/Buenos_Aires";

    private static final String USER = "avnadmin";

    private static final String PASSWORD = "AVNS_oKSsNHp4vGtV7Wmf8cS";

    public static Connection conectar() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL no encontrado", e);
        }

        return DriverManager.getConnection(
            URL,
            USER,
            PASSWORD
        );
    }
}