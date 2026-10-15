package com.medibook.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Opens JDBC connections to the MySQL database.
 * The connection settings are read from db.properties kept on the
 * class path (WEB-INF/classes/db.properties once deployed).
 */
public final class DBUtil {

    private static final Properties CONFIG = new Properties();
    private static String url;
    private static String username;
    private static String password;
    private static String configError = null;

    static {
        try (InputStream in = DBUtil.class.getResourceAsStream("/db.properties")) {
            if (in == null) {
                configError = "db.properties was not found on the class path.";
            } else {
                CONFIG.load(in);
            }
        } catch (Exception e) {
            configError = "db.properties could not be read: " + e.getMessage();
        }

        url = value("db.url",
                "jdbc:mysql://localhost:3306/medibook?useSSL=false"
                        + "&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata"
                        + "&characterEncoding=UTF-8");
        username = value("db.username", "root");
        password = value("db.password", "");

        String driver = value("db.driver", "com.mysql.cj.jdbc.Driver");
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            configError = "JDBC driver " + driver
                    + " not found. Put mysql-connector-j-x.x.x.jar into TOMCAT/lib or the webapp.";
        }
    }

    private DBUtil() {
    }

    /** @return null when the driver and properties loaded fine. */
    public static String getConfigError() {
        return configError;
    }

    public static Connection getConnection() throws SQLException {
        if (configError != null) {
            throw new SQLException(configError);
        }
        try {
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
            throw new SQLException("Could not connect to MySQL (" + e.getMessage()
                    + "). Check that the MySQL service is running and that the database "
                    + "'medibook' exists.", e);
        }
    }

    /** Quietly closes whatever JDBC object is handed to it. */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable c : resources) {
            if (c != null) {
                try {
                    c.close();
                } catch (Exception ignored) {
                    // nothing useful to do while closing
                }
            }
        }
    }

    private static String value(String key, String fallback) {
        String v = CONFIG.getProperty(key);
        return (v == null || v.trim().isEmpty()) ? fallback : v.trim();
    }
}
